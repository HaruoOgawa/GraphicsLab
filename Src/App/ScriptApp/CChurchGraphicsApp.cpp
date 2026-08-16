#include "CChurchGraphicsApp.h"

#include <Graphics/CDrawInfo.h>
#include <Graphics/CFrameRenderer.h>
#include <Graphics/CRTXGIController.h>
#include <Graphics/PostProcess/CPostProcess.h>

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

#ifdef USE_NETWORK
#include <Network/CUDPSocket.h>
#include <Network/DMX/CDMXDataHandler.h>
#include <Network/CNDIReceiver.h>
#endif

#include "../../Component/CCameraSwitcherComponent.h"

namespace app
{
	CChurchGraphicsApp::CChurchGraphicsApp() :
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
		m_FileModifier(std::make_shared<CFileModifier>()),
		m_TimelineController(std::make_shared<timeline::CTimelineController>()),
		m_PostProcess(std::make_shared<graphics::CPostProcess>("MainResultPass"))
	{
		//
		m_ViewCamera->SetCenter(glm::vec3(2.5f, 3.0f, 0.0f));
		m_ViewCamera->SetPos(glm::vec3(2.5f, 3.0f, 12.0f));
		////
		//m_ViewCamera->SetCenter(glm::vec3(0.0f, 1.0f, 0.0f));
		//m_ViewCamera->SetPos(glm::vec3(0.0f, 1.0f, -5.0f));
		m_MainCamera = m_ViewCamera;

		//
		m_CurrentLookUpCamera = m_LookUpCameraA;

		//
		m_DrawInfo->GetLightCamera()->SetPos(glm::vec3(-2.358f, 15.6f, -0.59f));
		m_DrawInfo->GetLightProjection()->SetNear(2.0f);
		m_DrawInfo->GetLightProjection()->SetFar(100.0f);

		m_SceneController->SetDefaultPass("MainGeometryPass");

#ifdef USE_GUIENGINE
		m_GraphicsEditingWindow->SetDefaultPass("MainResultPass", "");
#endif
	}

	bool CChurchGraphicsApp::Release(api::IGraphicsAPI* pGraphicsAPI)
	{
		return true;
	}

	bool CChurchGraphicsApp::Initialize(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker)
	{
		pLoadWorker->AddScene(std::make_shared<resource::CSceneLoader>("Resources\\User\\Scene\\PBRTest.json", m_SceneController));
		//pLoadWorker->AddScene(std::make_shared<resource::CSceneLoader>("Resources\\User\\Scene\\ChurchGraphics.json", m_SceneController));

		// オフスクリーンレンダリング
		// GBufferを組み込んだレンダリングパイプラインではフレームバッファコピー周りがややこしく非効率なことになるのでMSAAは使わない
		// 代わりにFXAAのポストプロセスでアンチエイリアシングを行う
		{
			graphics::SRenderPassState State = graphics::SRenderPassState(7);
			State.InitColorList[3] = glm::vec4(1.0f, 1.0f, 1.0f, 1.0f);
			if (!pGraphicsAPI->CreateRenderPass("GBufferGenPass", api::ERenderPassFormat::COLOR_FLOAT_RENDERPASS, -1, -1, State)) return false;
		}

		{
			graphics::SRenderPassState State = graphics::SRenderPassState(1);

			// GBufferパスの深度をフォアグラウンドパスにコピーするので深度は初期化しない
			State.ClearDepth = false;

			if (!pGraphicsAPI->CreateRenderPass("GBufferLightPass", api::ERenderPassFormat::COLOR_FLOAT_RENDERPASS, -1, -1, State)) return false;
		}

		{
			graphics::SRenderPassState State = graphics::SRenderPassState(1);

			// GBufferパスの深度をフォアグラウンドパスにコピーするので深度は初期化しない
			State.ClearColor = false;
			State.ClearDepth = false;
			State.ClearStencil = false;

			if (!pGraphicsAPI->CreateRenderPass("MainGeometryPass", api::ERenderPassFormat::COLOR_FLOAT_RENDERPASS, -1, -1, State)) return false;
		}

		if (!pGraphicsAPI->CreateRenderPass("MainResultPass", api::ERenderPassFormat::COLOR_FLOAT_RENDERPASS, -1, -1)) return false;

		// ポストプロセス
		m_PostProcess->SetUseFXAA(true);
		m_PostProcess->SetUseBloom(true);
		if (!m_PostProcess->Initialize(pGraphicsAPI, pLoadWorker)) return false;

		m_MainFrameRenderer = std::make_shared<graphics::CFrameRenderer>(pGraphicsAPI, "", pGraphicsAPI->FindOffScreenRenderPass("MainResultPass")->GetFrameTextureList());
		if (!m_MainFrameRenderer->Create(pLoadWorker, "Resources\\Common\\MaterialFrame\\FrameTexture_MF.json")) return false;

		return true;
	}

	bool CChurchGraphicsApp::ProcessInput(api::IGraphicsAPI* pGraphicsAPI)
	{
		return true;
	}

	bool CChurchGraphicsApp::Resize(int Width, int Height)
	{
		m_Projection->SetScreenResolution(Width, Height);

		m_DrawInfo->GetLightProjection()->SetScreenResolution(Width, Height);

		return true;
	}

	bool CChurchGraphicsApp::Update(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<input::CInputState>& InputState)
	{
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

		if (!m_PostProcess->Update(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_MainCamera, m_Projection, m_DrawInfo, InputState)) return false;
		if (!m_MainFrameRenderer->Update(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_MainCamera, m_Projection, m_DrawInfo, InputState)) return false;

		return true;
	}

	bool CChurchGraphicsApp::LateUpdate(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker)
	{
		if (!m_SceneController->LateUpdate(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_DrawInfo)) return false;

		return true;
	}

	bool CChurchGraphicsApp::FixedUpdate(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker)
	{
		if (!m_SceneController->FixedUpdate(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_DrawInfo)) return false;

		return true;
	}

	bool CChurchGraphicsApp::Draw(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<input::CInputState>& InputState,
		const std::shared_ptr<gui::IGUIEngine>& GUIEngine)
	{
		// MainResultPass 
		{
			if (!pGraphicsAPI->BeginRender("MainResultPass")) return false;
			if (!m_SceneController->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;
			if (!pGraphicsAPI->EndRender()) return false;
		}

		// ポストプロセス
		if (!m_PostProcess->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;

		// Main FrameBuffer
		{
			if (!pGraphicsAPI->BeginRender()) return false;

			if (!m_MainFrameRenderer->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;

			// GUIEngine
			std::function<bool(void)> DrawGUIEngine = [this, pLoadWorker, GUIEngine, pGraphicsAPI, pPhysicsEngine, InputState]() {
#ifdef USE_GUIENGINE
				if (pLoadWorker->IsLoaded())
				{
					gui::SGUIParams GUIParams = gui::SGUIParams(shared_from_this(), GetObjectList(), m_SceneController, m_FileModifier, m_TimelineController, pLoadWorker, {}, pPhysicsEngine);
					GUIParams.CameraMode = (m_CameraSwitchToggle) ? "ViewCamera" : "TraceCamera";
					GUIParams.Camera = m_MainCamera;
					GUIParams.InputState = InputState;
					GUIParams.ValueRegistryList.emplace(m_PostProcess->GetBloomFilter()->GetRegistryName(), m_PostProcess->GetBloomFilter());

					if (!GUIEngine->BeginFrame(pGraphicsAPI)) return false;
					if (!m_GraphicsEditingWindow->Draw(pGraphicsAPI, GUIParams, GUIEngine))
					{
						Console::Log("[Error] InValid GUI\n");
						return false;
					}
					if (!GUIEngine->EndFrame(pGraphicsAPI)) return false;
				}
#endif // USE_GUIENGINE

				return true;
				};

			if (!pLoadWorker->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;

			if (!pGraphicsAPI->EndRender(DrawGUIEngine)) return false;
		}

		return true;
	}

	std::shared_ptr<graphics::CDrawInfo> CChurchGraphicsApp::GetDrawInfo() const
	{
		return m_DrawInfo;
	}

	// コンポーネント作成
	std::shared_ptr<scriptable::CComponent> CChurchGraphicsApp::CreateComponent(const std::string& ComponentType, const std::string& ValueRegistry)
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
	bool CChurchGraphicsApp::OnStartup(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<gui::IGUIEngine>& GUIEngine)
	{
		const auto& TimelineFileName = m_SceneController->GetTimelineFileName();
		if (!TimelineFileName.empty()) pLoadWorker->AddLoadResource(std::make_shared<resource::CTimelineClipLoader>(TimelineFileName, m_TimelineController->GetClip()));

		return true;
	}

	// ロード完了イベント
	bool CChurchGraphicsApp::OnLoaded(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<gui::IGUIEngine>& GUIEngine)
	{
		//
		if (!m_SceneController->Create(pGraphicsAPI, pPhysicsEngine)) return false;

		//
		{
			auto EmptyTexture = pGraphicsAPI->CreateTexture(false);

			int pixelByteSize = 1280 * 1280 * 4;
			std::vector<unsigned char> emptyPixel;
			emptyPixel.resize(pixelByteSize, 0);

			EmptyTexture->Create(emptyPixel, 1280, 1280, 4, api::ERenderPassFormat::COLOR_BGRA);

			const auto& NDIObj = m_SceneController->FindObjectByName("NDIObj");
			if (NDIObj)
			{
				NDIObj->GetTextureSet()->Add2DTexture(EmptyTexture);

				for (const auto& Mesh : NDIObj->GetMeshList())
				{
					for (const auto& Primitive : Mesh->GetPrimitiveList())
					{
						for (const auto& Renderer : Primitive->GetRendererList())
						{
							std::get<1>(Renderer)->ReplaceTextureIndex("texImage", 0);
							std::get<1>(Renderer)->CreateRefTextureList(NDIObj->GetTextureSet());
						}
					}
				}
			}
		}

		m_PostProcess->GetBloomFilter()->OnLoaded(m_SceneController);

		if (!m_TimelineController->Initialize(shared_from_this())) return false;

#ifdef USE_GUIENGINE
		{
			gui::SGUIParams GUIParams = gui::SGUIParams(shared_from_this(), GetObjectList(), m_SceneController, m_FileModifier, m_TimelineController, pLoadWorker, {}, pPhysicsEngine);
			GUIParams.ValueRegistryList.emplace(m_PostProcess->GetBloomFilter()->GetRegistryName(), m_PostProcess->GetBloomFilter());

			if (!m_GraphicsEditingWindow->OnLoaded(pGraphicsAPI, GUIParams, GUIEngine)) return false;
		}
#endif
		return true;
	}

	// フォーカスイベント
	void CChurchGraphicsApp::OnFocus(bool Focused, api::IGraphicsAPI* pGraphicsAPI, resource::CLoadWorker* pLoadWorker)
	{
		if (Focused && pLoadWorker)
		{
			m_FileModifier->OnFileUpdated(pLoadWorker);
		}
	}

	// エラー通知イベント
	void CChurchGraphicsApp::OnAssertError(const std::string& Message)
	{
#ifdef USE_GUIENGINE
		m_GraphicsEditingWindow->AddLog(gui::EGUILogType::Error, Message);
#endif
	}

	// Getter
	std::vector<std::shared_ptr<object::C3DObject>> CChurchGraphicsApp::GetObjectList() const
	{
		std::vector<std::shared_ptr<object::C3DObject>> ObjectList;

		for (const auto& Object : m_SceneController->GetObjectList())
		{
			ObjectList.push_back(Object);
		}

		return ObjectList;
	}

	std::shared_ptr<scene::CSceneController> CChurchGraphicsApp::GetSceneController() const
	{
		return m_SceneController;
	}

	// カスタムイベント発火
	void CChurchGraphicsApp::OnRaisedEvent(const std::string& Type, const std::string& Params)
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