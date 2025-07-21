#include "CPerformanceOPTest.h"

#include <Graphics/CDrawInfo.h>
#include <Graphics/CFrameRenderer.h>
#include <Graphics/CRTXGIController.h>

#include <Camera/CCamera.h>
#include <Camera/CLookUpTraceCamera.h>
#ifdef USE_VIEWER_CAMERA
#include <Camera/CViewerCamera.h>
#endif // USE_VIEWER_CAMERA

#include <LoadWorker/CLoadWorker.h>
#include <Projection/CProjection.h>
#include <Message/Console.h>
#include <Interface/IGUIEngine.h>
#include <Timeline/CTimelineController.h>
#include <Scene/CSceneController.h>

#include "../../GUIApp/GUI/CGraphicsEditingWindow.h"
#include "../../GUIApp/Model/CFileModifier.h"

#include "../../ImageEffect/CBloomEffect.h"

#ifdef USE_NETWORK
#include <Network/CUDPSocket.h>
#include <Network/DMX/CDMXDataHandler.h>
#endif

#include "../../Component/CCameraSwitcherComponent.h"

namespace app
{
	CPerformanceOPTest::CPerformanceOPTest() :
		m_SceneController(std::make_shared<scene::CSceneController>()),
		m_CameraSwitchToggle(true),
		m_MainCamera(nullptr),
#ifdef USE_VIEWER_CAMERA
		m_ViewCamera(std::make_shared<camera::CViewerCamera>()),
#else
		m_ViewCamera(std::make_shared<camera::CCamera>()),
#endif // USE_VIEWER_CAMERA
		m_CurrentLookUpCamera(nullptr),
		m_LookUpCameraA(std::make_shared<camera::CLookUpTraceCamera>()),
		m_LookUpCameraB(std::make_shared<camera::CLookUpTraceCamera>()),
		m_LookUpSwitchToggle(true),
		m_Projection(std::make_shared<projection::CProjection>()),
		m_DrawInfo(std::make_shared<graphics::CDrawInfo>()),
#ifdef USE_GUIENGINE
		m_GraphicsEditingWindow(std::make_shared<gui::CGraphicsEditingWindow>()),
#endif // USE_GUIENGINE
#ifdef USE_NETWORK
		m_UDPSocket(std::make_shared<network::CUDPSocket>("192.168.0.252", 6454)),
		m_DMXHandler(std::make_shared<network::CDMXDataHandler>()),
#endif // USE_NETWORK

		m_FileModifier(std::make_shared<CFileModifier>()),
		m_TimelineController(std::make_shared<timeline::CTimelineController>()),
		m_BloomEffect(std::make_shared<imageeffect::CBloomEffect>("MainResultPass"))
	{
		//
		m_ViewCamera->SetCenter(glm::vec3(0.0f, 1.0f, 0.0f));
		m_ViewCamera->SetPos(glm::vec3(0.0f, 1.0f, 5.0f));
		m_MainCamera = m_ViewCamera;

		//
		m_CurrentLookUpCamera = m_LookUpCameraA;

		//
		m_DrawInfo->GetLightCamera()->SetPos(glm::vec3(-2.358f, 15.6f, -0.59f));
		m_DrawInfo->GetLightProjection()->SetNear(2.0f);
		m_DrawInfo->GetLightProjection()->SetFar(100.0f);

		m_SceneController->SetDefaultPass("MainResultPass");

#ifdef USE_GUIENGINE
		m_GraphicsEditingWindow->SetDefaultPass("MainResultPass", "");
#endif
	}

	bool CPerformanceOPTest::Release(api::IGraphicsAPI* pGraphicsAPI)
	{
		return true;
	}

	bool CPerformanceOPTest::Initialize(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker)
	{
#ifdef USE_NETWORK
		if (!m_UDPSocket->Initialize()) return false;

		// DMX準備
		{
			// ライト
			network::SDMXFixture Fixture{};
			Fixture.DeviceName = "DefaultSpotLight";
			Fixture.ChannelNameList = { "R", "G", "B", "Dimmer", "Pan", "Tilt", "Angle", "Height" };

			m_DMXHandler->RegistDeviceFixture(1, 0, 0, Fixture);
		}

		{
			// CameraSwitcher
			network::SDMXFixture Fixture{};
			Fixture.DeviceName = "CameraSwitcher";
			Fixture.ChannelNameList = { 
				"ID", 
				
				// CameraA
				"CameraA_PosX_Byte_0", "CameraA_PosX_Byte_1", "CameraA_PosX_Byte_2", "CameraA_PosX_Byte_3",
				"CameraA_PosY_Byte_0", "CameraA_PosY_Byte_1", "CameraA_PosY_Byte_2", "CameraA_PosY_Byte_3",
				"CameraA_PosZ_Byte_0", "CameraA_PosZ_Byte_1", "CameraA_PosZ_Byte_2", "CameraA_PosZ_Byte_3",
				"CameraA_ZAngle_Byte_0", "CameraA_ZAngle_Byte_1", "CameraA_ZAngle_Byte_2", "CameraA_ZAngle_Byte_3",
				
				// CameraB
				"CameraB_PosX_Byte_0", "CameraB_PosX_Byte_1", "CameraB_PosX_Byte_2", "CameraB_PosX_Byte_3",
				"CameraB_PosY_Byte_0", "CameraB_PosY_Byte_1", "CameraB_PosY_Byte_2", "CameraB_PosY_Byte_3",
				"CameraB_PosZ_Byte_0", "CameraB_PosZ_Byte_1", "CameraB_PosZ_Byte_2", "CameraB_PosZ_Byte_3",
				"CameraB_ZAngle_Byte_0", "CameraB_ZAngle_Byte_1", "CameraB_ZAngle_Byte_2", "CameraB_ZAngle_Byte_3",
			};

			m_DMXHandler->RegistDeviceFixture(2, 0, 0, Fixture);
		}
#endif

		pLoadWorker->AddScene(std::make_shared<resource::CSceneLoader>("Resources\\Scene\\DMXTest.json", m_SceneController));
		//pLoadWorker->AddScene(std::make_shared<resource::CSceneLoader>("Resources\\Scene\\Sample.json", m_SceneController));
		//pLoadWorker->AddScene(std::make_shared<resource::CSceneLoader>("Resources\\Scene\\rtxgi.json", m_SceneController));

		// オフスクリーンレンダリング

		{
			graphics::SRenderPassState State = graphics::SRenderPassState(5);
			State.InitColorList[3] = glm::vec4(1.0f, 1.0f, 1.0f, 1.0f);
			// デファードとフォアグラウンド周りがややこしくなるのでいったんMSAAはコメントアウト
			//State.EnabledAA = true;
			//State.AASampleNum = 8;
			if (!pGraphicsAPI->CreateRenderPass("GBufferGenPass", api::ERenderPassFormat::COLOR_FLOAT_RENDERPASS, -1, -1, State)) return false;
		}

		{
			graphics::SRenderPassState State = graphics::SRenderPassState(1);
			// デファードとフォアグラウンド周りがややこしくなるのでいったんMSAAはコメントアウト
			//State.EnabledAA = true;
			//State.AASampleNum = 8;

			// GBufferパスの深度をフォアグラウンドパスにコピーするので深度は初期化しない
			State.ClearDepth = false;

			if (!pGraphicsAPI->CreateRenderPass("GBufferLightPass", api::ERenderPassFormat::COLOR_FLOAT_RENDERPASS, -1, -1, State)) return false;
		}
		
		{
			graphics::SRenderPassState State = graphics::SRenderPassState(1);
			// デファードとフォアグラウンド周りがややこしくなるのでいったんMSAAはコメントアウト
			//State.EnabledAA = true;
			//State.AASampleNum = 8;

			// GBufferパスの深度をフォアグラウンドパスにコピーするので深度は初期化しない
			State.ClearColor = false;
			State.ClearDepth = false;
			State.ClearStencil = false;

			if (!pGraphicsAPI->CreateRenderPass("MainResultPass", api::ERenderPassFormat::COLOR_FLOAT_RENDERPASS, -1, -1, State)) return false;
		}

		// ブルームエフェクト
		if (!m_BloomEffect->Initialize(pGraphicsAPI, pLoadWorker)) return false;

		m_MainFrameRenderer = std::make_shared<graphics::CFrameRenderer>(pGraphicsAPI, "", pGraphicsAPI->FindOffScreenRenderPass("MainResultPass")->GetFrameTextureList());
		if (!m_MainFrameRenderer->Create(pLoadWorker, "Resources\\MaterialFrame\\FrameTexture_MF.json")) return false;

		return true;
	}

	bool CPerformanceOPTest::ProcessInput(api::IGraphicsAPI* pGraphicsAPI)
	{
		return true;
	}

	bool CPerformanceOPTest::Resize(int Width, int Height)
	{
		m_Projection->SetScreenResolution(Width, Height);

		m_DrawInfo->GetLightProjection()->SetScreenResolution(Width, Height);

		return true;
	}

	bool CPerformanceOPTest::Update(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<input::CInputState>& InputState)
	{
#ifdef USE_NETWORK
		if (!m_UDPSocket->Update(this)) return false;
#endif

		if (!m_FileModifier->Update(pLoadWorker)) return false;

		if (pLoadWorker->IsLoaded())
		{
			if (!m_TimelineController->Update(m_DrawInfo->GetDeltaSecondsTime(), InputState)) return false;
		}

		if (!m_SceneController->Update(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_MainCamera, m_Projection, m_DrawInfo, InputState, m_TimelineController)) return false;

		m_MainCamera->Update(m_DrawInfo->GetDeltaSecondsTime(), InputState);

		if (InputState->IsKeyUp(input::EKeyType::KEY_TYPE_SPACE))
		{
			m_CameraSwitchToggle = !m_CameraSwitchToggle;

			if (m_CameraSwitchToggle)
			{
				m_MainCamera = m_ViewCamera;
			}
			else
			{
				m_MainCamera = m_CurrentLookUpCamera;
			}
		}

		if (!m_BloomEffect->Update(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_MainCamera, m_Projection, m_DrawInfo, InputState)) return false;
		if (!m_MainFrameRenderer->Update(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_MainCamera, m_Projection, m_DrawInfo, InputState)) return false;

		return true;
	}

	bool CPerformanceOPTest::LateUpdate(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker)
	{
		if (!m_SceneController->LateUpdate(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_DrawInfo)) return false;

		return true;
	}

	bool CPerformanceOPTest::FixedUpdate(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker)
	{
		if (!m_SceneController->FixedUpdate(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_DrawInfo)) return false;

		return true;
	}

	bool CPerformanceOPTest::Draw(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<input::CInputState>& InputState,
		const std::shared_ptr<gui::IGUIEngine>& GUIEngine)
	{
		// GBufferGenPass
		{
			if (!pGraphicsAPI->BeginRender("GBufferGenPass")) return false;
			if (!m_SceneController->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;
			if (!pGraphicsAPI->EndRender()) return false;
		}
		
		// GBufferLightPass
		{
			// フォアグラウンドパス(GBufferLightPass)にデファードパスの深度をコピーする
			if (!pGraphicsAPI->CopyDepthBuffer("GBufferGenPass", "GBufferLightPass")) return false;

			if (!pGraphicsAPI->BeginRender("GBufferLightPass")) return false;
			if (!m_SceneController->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;
			if (!pGraphicsAPI->EndRender()) return false;
		}
		
		// MainResultPass
		{
			// フォアグラウンドパス(MainResultPass)にGBufferLightPassのカラー・深度をコピーする
			if (!pGraphicsAPI->CopyRenderPass("GBufferLightPass", "MainResultPass", true, true)) return false;

			if (!pGraphicsAPI->BeginRender("MainResultPass")) return false;
			if (!m_SceneController->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;
			if (!pGraphicsAPI->EndRender()) return false;
		}

		// BloomEffect
		if (!m_BloomEffect->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;

		// Main FrameBuffer
		{
			if (!pGraphicsAPI->BeginRender()) return false;

			if (!m_MainFrameRenderer->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;

			// GUIEngine
#ifdef USE_GUIENGINE
			if (pLoadWorker->IsLoaded())
			{
				gui::SGUIParams GUIParams = gui::SGUIParams(shared_from_this(), GetObjectList(), m_SceneController, m_FileModifier, m_TimelineController, pLoadWorker, {}, pPhysicsEngine);
				GUIParams.CameraMode = (m_CameraSwitchToggle) ? "ViewCamera" : "TraceCamera";
				GUIParams.Camera = m_MainCamera;
				GUIParams.InputState = InputState;
				GUIParams.ValueRegistryList.emplace(m_BloomEffect->GetRegistryName(), m_BloomEffect);

				if (!GUIEngine->BeginFrame(pGraphicsAPI)) return false;
				if (!m_GraphicsEditingWindow->Draw(pGraphicsAPI, GUIParams, GUIEngine))
				{
					Console::Log("[Error] InValid GUI\n");
					return false;
				}
				if (!GUIEngine->EndFrame(pGraphicsAPI)) return false;
			}
#endif // USE_GUIENGINE

			if (!pLoadWorker->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;

			if (!pGraphicsAPI->EndRender()) return false;
		}

		return true;
	}

	std::shared_ptr<graphics::CDrawInfo> CPerformanceOPTest::GetDrawInfo() const
	{
		return m_DrawInfo;
	}

	// コンポーネント作成
	std::shared_ptr<scriptable::CComponent> CPerformanceOPTest::CreateComponent(const std::string& ComponentType, const std::string& ValueRegistry)
	{
		if (ComponentType == "CameraSwitcher")
		{
			return std::make_shared<scriptable::CCameraSwitcherComponent>(ComponentType, ValueRegistry, shared_from_this(), 
				std::vector<std::shared_ptr<camera::CLookUpTraceCamera>>({
					m_LookUpCameraA,
					m_LookUpCameraB,
				}));
		}

		return nullptr;
	}

	// 起動準備完了
	bool CPerformanceOPTest::OnStartup(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<gui::IGUIEngine>& GUIEngine)
	{
		const auto& TimelineFileName = m_SceneController->GetTimelineFileName();
		if (!TimelineFileName.empty()) pLoadWorker->AddLoadResource(std::make_shared<resource::CTimelineClipLoader>(TimelineFileName, m_TimelineController->GetClip()));

		return true;
	}

	// ロード完了イベント
	bool CPerformanceOPTest::OnLoaded(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<gui::IGUIEngine>& GUIEngine)
	{
		if (!m_SceneController->Create(pGraphicsAPI, pPhysicsEngine)) return false;

		m_BloomEffect->OnLoaded(m_SceneController);

		if (!m_TimelineController->Initialize(shared_from_this())) return false;

#ifdef USE_GUIENGINE
		{
			gui::SGUIParams GUIParams = gui::SGUIParams(shared_from_this(), GetObjectList(), m_SceneController, m_FileModifier, m_TimelineController, pLoadWorker, {}, pPhysicsEngine);
			GUIParams.ValueRegistryList.emplace(m_BloomEffect->GetRegistryName(), m_BloomEffect);

			if (!m_GraphicsEditingWindow->OnLoaded(pGraphicsAPI, GUIParams, GUIEngine)) return false;
		}
#endif

		// DMXに照明灯体を渡す
		{
			const auto& Object = m_SceneController->FindObjectByName("LightList");
			if (Object)
			{
				for (int i = 0; i < 6; i++)
				{
					std::string Name = "SpotLight_" + std::to_string(i);
					const auto& SpotLight = Object->FindNodeByName(Name);
					
					for (const auto& Component : SpotLight->GetComponentList())
					{
						if (Component->GetComponentName() != "SpotLight") continue;

						m_DMXHandler->AddDevice("DefaultSpotLight", Component);
					}
				}
			}
		}

		// DMXにカメラスイッチャーを渡す
		{
			const auto& Object = m_SceneController->FindObjectByName("CameraSwitcher");
			if (Object)
			{
				const auto& ComponentList = Object->GetComponentList();
				if (!ComponentList.empty())
				{
					const auto& Component = ComponentList[0];

					m_DMXHandler->AddDevice("CameraSwitcher", Component);
				}
			}
		}

		return true;
	}

	// フォーカスイベント
	void CPerformanceOPTest::OnFocus(bool Focused, api::IGraphicsAPI* pGraphicsAPI, resource::CLoadWorker* pLoadWorker)
	{
		if (Focused && pLoadWorker)
		{
			m_FileModifier->OnFileUpdated(pLoadWorker);
		}
	}

	// エラー通知イベント
	void CPerformanceOPTest::OnAssertError(const std::string& Message)
	{
#ifdef USE_GUIENGINE
		m_GraphicsEditingWindow->AddLog(gui::EGUILogType::Error, Message);
#endif
	}

	// Getter
	std::vector<std::shared_ptr<object::C3DObject>> CPerformanceOPTest::GetObjectList() const
	{
		std::vector<std::shared_ptr<object::C3DObject>> ObjectList;

		for (const auto& Object : m_SceneController->GetObjectList())
		{
			ObjectList.push_back(Object);
		}

		return ObjectList;
	}

	std::shared_ptr<scene::CSceneController> CPerformanceOPTest::GetSceneController() const
	{
		return m_SceneController;
	}

	// DMXデータ受信イベント
	void CPerformanceOPTest::OnReceiveArtNetDMX(unsigned short Net, unsigned short SubNet, unsigned short Universe, const std::vector<unsigned char>& DataBuffer)
	{
		if (!m_DMXHandler) return;

		m_DMXHandler->DispatchDMXData(Net, SubNet, Universe, DataBuffer);
	}

	// カスタムイベント発火
	void CPerformanceOPTest::OnRaisedEvent(const std::string& Type, const std::string& Params)
	{
		if (Type == "CameraSwitch")
		{
			m_LookUpSwitchToggle = !m_LookUpSwitchToggle;

			if (m_LookUpSwitchToggle)
			{
				m_CurrentLookUpCamera = m_LookUpCameraA;
			}
			else
			{
				m_CurrentLookUpCamera = m_LookUpCameraB;
			}
		}
	}
}