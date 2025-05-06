#include "CDevApp.h"

#include <Graphics/CDrawInfo.h>
#include <Graphics/CFrameRenderer.h>

#include <Camera/CCamera.h>
#include <Camera/CTraceCamera.h>
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

#include "../../Component/CCDIKTest.h"

namespace app
{
	CDevApp::CDevApp() :
		m_PlayMode(EPlayMode::Play),
		m_LocalTime(0.0f),
		m_LocalDeltaTime(0.0f),
		m_SceneController(std::make_shared<scene::CSceneController>()),
		m_CameraSwitchToggle(true),
		m_MainCamera(nullptr),
#ifdef USE_VIEWER_CAMERA
		m_ViewCamera(std::make_shared<camera::CViewerCamera>()),
#else
		m_ViewCamera(std::make_shared<camera::CCamera>()),
#endif // USE_VIEWER_CAMERA
		m_TraceCamera(std::make_shared<camera::CTraceCamera>()),
		m_Projection(std::make_shared<projection::CProjection>()),
		m_DrawInfo(std::make_shared<graphics::CDrawInfo>()),
#ifdef USE_GUIENGINE
		m_GraphicsEditingWindow(std::make_shared<gui::CGraphicsEditingWindow>()),
#endif // USE_GUIENGINE
		m_FileModifier(std::make_shared<CFileModifier>()),
		m_TimelineController(std::make_shared<timeline::CTimelineController>())
	{
#ifdef _DEBUG
		m_PlayMode = EPlayMode::Stop;
#endif // _DEBUG

		m_ViewCamera->SetPos(glm::vec3(0.0f, 2.5f, 10.0f));
		m_ViewCamera->SetCenter(glm::vec3(0.0f, 2.5f, 0.0f));
		m_MainCamera = m_ViewCamera;

		m_DrawInfo->GetLightCamera()->SetPos(glm::vec3(5.0f, 5.0f, 5.0f));
		m_DrawInfo->GetLightProjection()->SetNear(2.0f);
		m_DrawInfo->GetLightProjection()->SetFar(100.0f);

		m_SceneController->SetDefaultPass("MainResultPass");

#ifdef USE_GUIENGINE
		m_GraphicsEditingWindow->SetDefaultPass("MainResultPass", "");
#endif
	}

	bool CDevApp::Release(api::IGraphicsAPI* pGraphicsAPI)
	{
		return true;
	}

	// USE_RCCPP

	bool CDevApp::Initialize(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker)
	{
		pLoadWorker->AddScene(std::make_shared<resource::CSceneLoader>("Resources\\Scene\\Sample.json", m_SceneController));
		//pLoadWorker->AddScene(std::make_shared<resource::CSceneLoader>("Resources\\Scene\\CCDIK.json", m_SceneController));
		//pLoadWorker->AddScene(std::make_shared<resource::CSceneLoader>("Resources\\Scene\\PhysicsTest.json", m_SceneController));

		// オフスクリーンレンダリング
		if (!pGraphicsAPI->CreateRenderPass("MainResultPass", api::ERenderPassFormat::COLOR_FLOAT_RENDERPASS, glm::vec4(0.0f, 0.0f, 0.0f, 1.0f), -1, -1, {})) return false;

		m_MainFrameRenderer = std::make_shared<graphics::CFrameRenderer>(pGraphicsAPI, "", pGraphicsAPI->FindOffScreenRenderPass("MainResultPass")->GetFrameTextureList());
		if (!m_MainFrameRenderer->Create(pLoadWorker, "Resources\\MaterialFrame\\FrameTexture_MF.json")) return false;

		return true;
	}

	bool CDevApp::ProcessInput(api::IGraphicsAPI* pGraphicsAPI)
	{
		return true;
	}

	bool CDevApp::Resize(int Width, int Height)
	{
		m_Projection->SetScreenResolution(Width, Height);

		m_DrawInfo->GetLightProjection()->SetScreenResolution(Width, Height);

		return true;
	}

	bool CDevApp::Update(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<input::CInputState>& InputState)
	{
		// カメラはローカル時間の影響を受けたくないので先に計算
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
				m_MainCamera = m_TraceCamera;
			}
		}

		// 再生時間
		{
			float PrevLocalTime = m_LocalTime;

			if (m_PlayMode == EPlayMode::Play)
			{
				m_LocalTime += m_DrawInfo->GetDeltaSecondsTime();
			}

			m_LocalDeltaTime = m_LocalTime - PrevLocalTime;

			m_DrawInfo->SetSecondsTime(m_LocalTime);
			m_DrawInfo->SetDeltaSecondsTime(m_LocalDeltaTime);
		}

		if (!m_FileModifier->Update(pLoadWorker)) return false;

		if (pLoadWorker->IsLoaded())
		{
			if (!m_TimelineController->Update(m_DrawInfo->GetDeltaSecondsTime(), InputState)) return false;
		}

		// スロー再生する
		//float PrevSelta = m_DrawInfo->GetDeltaSecondsTime();
		//m_DrawInfo->SetDeltaSecondsTime(1.0f / 500.0f);

		if (!m_SceneController->Update(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_MainCamera, m_Projection, m_DrawInfo, InputState, m_TimelineController)) return false;

		// 再生速度を元に戻す
		//m_DrawInfo->SetDeltaSecondsTime(PrevSelta); 

		if (!m_MainFrameRenderer->Update(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_MainCamera, m_Projection, m_DrawInfo, InputState)) return false;

		return true;
	}

	bool CDevApp::LateUpdate(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker)
	{
		if (!m_SceneController->LateUpdate(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_DrawInfo)) return false;

		return true;
	}

	bool CDevApp::FixedUpdate(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker)
	{
		if (!m_SceneController->FixedUpdate(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_DrawInfo)) return false;

		return true;
	}

	bool CDevApp::Draw(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<input::CInputState>& InputState,
		const std::shared_ptr<gui::IGUIEngine>& GUIEngine)
	{
		// MainResultPass
		{
			if (!pGraphicsAPI->BeginRender("MainResultPass")) return false;
			if (!m_SceneController->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;
			if (!pGraphicsAPI->EndRender()) return false;
		}

		// Main FrameBuffer
		{
			if (!pGraphicsAPI->BeginRender()) return false;

			if (!m_MainFrameRenderer->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;

			// GUIEngine
#ifdef USE_GUIENGINE
			if (pLoadWorker->IsLoaded())
			{
				gui::SGUIParams GUIParams = gui::SGUIParams(shared_from_this(), GetObjectList(), m_SceneController, m_FileModifier, m_TimelineController, 
					pLoadWorker, {}, pPhysicsEngine);
				GUIParams.CameraMode = (m_CameraSwitchToggle) ? "ViewCamera" : "TraceCamera";
				GUIParams.Camera = m_MainCamera;
				GUIParams.InputState = InputState;

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

	std::shared_ptr<graphics::CDrawInfo> CDevApp::GetDrawInfo() const
	{
		return m_DrawInfo;
	}

	// 起動準備完了
	bool CDevApp::OnStartup(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<gui::IGUIEngine>& GUIEngine)
	{
		const auto& TimelineFileName = m_SceneController->GetTimelineFileName();
		if (!TimelineFileName.empty()) pLoadWorker->AddLoadResource(std::make_shared<resource::CTimelineClipLoader>(TimelineFileName, m_TimelineController->GetClip()));

		return true;
	}

	// ロード完了イベント
	bool CDevApp::OnLoaded(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<gui::IGUIEngine>& GUIEngine)
	{
		{
			const auto& Object = m_SceneController->FindObjectByName("CCDIKTest");
			if (Object)
			{
				const auto& Node = Object->FindNodeByName("Link.004");
				Node->AddComponent(std::make_shared<component::CCDIKTest>("CCDIKTest", ""));
			}
		}

		if (!m_SceneController->Create(pGraphicsAPI, pPhysicsEngine)) return false;

		if (!m_TimelineController->Initialize(shared_from_this())) return false;

#ifdef USE_GUIENGINE
		{
			gui::SGUIParams GUIParams = gui::SGUIParams(shared_from_this(), GetObjectList(), m_SceneController, m_FileModifier, m_TimelineController, 
				pLoadWorker, {}, pPhysicsEngine);

			if (!m_GraphicsEditingWindow->OnLoaded(pGraphicsAPI, GUIParams, GUIEngine)) return false;
		}
#endif

		// カメラ
		{
			const auto& Object = m_SceneController->FindObjectByName("CameraObject");
			if (Object)
			{
				const auto& Node = Object->FindNodeByName("CameraNode");

				if (Node)
				{
					m_TraceCamera->SetTargetNode(Node);
				}
			}
		}

		return true;
	}

	// フォーカスイベント
	void CDevApp::OnFocus(bool Focused, api::IGraphicsAPI* pGraphicsAPI, resource::CLoadWorker* pLoadWorker)
	{
		if (Focused && pLoadWorker)
		{
			m_FileModifier->OnFileUpdated(pLoadWorker);
		}
	}

	// エラー通知イベント
	void CDevApp::OnAssertError(const std::string& Message)
	{
#ifdef USE_GUIENGINE
		m_GraphicsEditingWindow->AddLog(gui::EGUILogType::Error, Message);
#endif
	}

	// Getter
	std::vector<std::shared_ptr<object::C3DObject>> CDevApp::GetObjectList() const
	{
		std::vector<std::shared_ptr<object::C3DObject>> ObjectList;

		for (const auto& Object : m_SceneController->GetObjectList())
		{
			ObjectList.push_back(Object);
		}

		return ObjectList;
	}

	std::shared_ptr<scene::CSceneController> CDevApp::GetSceneController() const
	{
		return m_SceneController;
	}

	// カメラモード変更イベント
	void CDevApp::OnChangeCameraMode(const std::string& Mode)
	{
		m_CameraSwitchToggle = !m_CameraSwitchToggle;

		if (m_CameraSwitchToggle)
		{
			m_MainCamera = m_ViewCamera;
		}
		else
		{
			m_MainCamera = m_TraceCamera;
		}
	}

	// シーン再生モード変更イベント
	void CDevApp::OnChangeScenePlayMode(const std::string& Mode)
	{
		if (Mode == "Play")
		{
			m_PlayMode = EPlayMode::Play;
		}
		else if (Mode == "Stop")
		{
			m_PlayMode = EPlayMode::Stop;

			m_LocalTime = 0.0f;
			m_LocalDeltaTime = 0.0f;

			m_SceneController->Reset();
		}
		else if (Mode == "Pause")
		{
			m_PlayMode = EPlayMode::Pause;
		}
	}
}