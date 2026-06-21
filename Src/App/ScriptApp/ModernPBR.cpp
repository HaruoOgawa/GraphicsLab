#include "ModernPBR.h"

#include <Graphics/CDrawInfo.h>
#include <Graphics/CFrameRenderer.h>
#include <Graphics/PostProcess/CPostProcess.h>

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

namespace app
{
	ModernPBR::ModernPBR() :
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
		m_TimelineController(std::make_shared<timeline::CTimelineController>()),
		m_PostProcess(std::make_shared<graphics::CPostProcess>("MainResultPass"))
	{
		m_ViewCamera->SetCenter(glm::vec3(2.5f, 3.0f, 0.0f));
		m_ViewCamera->SetPos(glm::vec3(2.5f, 3.0f, 12.0f));
		m_MainCamera = m_ViewCamera;

		m_DrawInfo->GetLightCamera()->SetPos(glm::vec3(-2.358f, 15.6f, -0.59f));
		m_DrawInfo->GetLightProjection()->SetNear(2.0f);
		m_DrawInfo->GetLightProjection()->SetFar(100.0f);

		m_SceneController->SetDefaultPass("MainGeometryPass");

#ifdef USE_GUIENGINE
		m_GraphicsEditingWindow->SetDefaultPass("MainResultPass", "");
#endif
	}

	bool ModernPBR::Release(api::IGraphicsAPI* pGraphicsAPI)
	{
		return true;
	}

	bool ModernPBR::Initialize(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker)
	{
		pLoadWorker->AddScene(std::make_shared<resource::CSceneLoader>("Resources\\User\\Scene\\ModernPBR.json", m_SceneController));

		// オフスクリーンレンダリング
		// GBufferを組み込んだレンダリングパイプラインではフレームバッファコピー周りがややこしく非効率なことになるのでMSAAは使わない
		// 代わりにFXAAのポストプロセスでアンチエイリアシングを行う
		{
			graphics::SRenderPassState State = graphics::SRenderPassState(6);
			State.InitColorList[3] = glm::vec4(1.0f, 1.0f, 1.0f, 1.0f);
			State.Stencil = true;
			if (!pGraphicsAPI->CreateRenderPass("GBufferGenPass", api::ERenderPassFormat::COLOR_FLOAT_RENDERPASS, -1, -1, State)) return false;
		}

		{
			graphics::SRenderPassState State = graphics::SRenderPassState(1);
			State.Stencil = true;

			// GBufferパスの深度をフォアグラウンドパスにコピーするので深度は初期化しない
			State.ClearDepth = false;
			State.ClearStencil = false;

			if (!pGraphicsAPI->CreateRenderPass("GBufferLightPass", api::ERenderPassFormat::COLOR_FLOAT_RENDERPASS, -1, -1, State)) return false;
		}

		{
			graphics::SRenderPassState State = graphics::SRenderPassState(1);
			State.Stencil = true;

			// GBufferパスの深度をフォアグラウンドパスにコピーするので深度は初期化しない
			State.ClearColor = false;
			State.ClearDepth = false;
			State.ClearStencil = false;

			if (!pGraphicsAPI->CreateRenderPass("MainGeometryPass", api::ERenderPassFormat::COLOR_FLOAT_RENDERPASS, -1, -1, State)) return false;
		}

		{
			graphics::SRenderPassState State = graphics::SRenderPassState(1);
			State.Stencil = true;

			if (!pGraphicsAPI->CreateRenderPass("MainResultPass", api::ERenderPassFormat::COLOR_FLOAT_RENDERPASS, -1, -1, State)) return false;
		}

		// ShadomMap
		{
			graphics::SRenderPassState PassState{};
			PassState.ColorBuffer = true; // Shadowなのでいらないけど互換性でいるにしておく(Vulkan, WebGPUでFragmentShaderなしパターンにまだ対応していない)
			PassState.ColorTexture = true;
			PassState.DepthBuffer = true;
			PassState.DepthTexture = true;

			if (!pGraphicsAPI->CreateRenderPass("ShadowPass", api::ERenderPassFormat::COLOR_FLOAT_RENDERPASS, -1, -1, PassState)) return false;
		}

		// ポストプロセス
		m_PostProcess->SetUseFXAA(true);
		m_PostProcess->SetUseBloom(true);
		if (!m_PostProcess->Initialize(pGraphicsAPI, pLoadWorker)) return false;

		m_MainFrameRenderer = std::make_shared<graphics::CFrameRenderer>(pGraphicsAPI, "", pGraphicsAPI->FindOffScreenRenderPass("MainResultPass")->GetFrameTextureList());
		if (!m_MainFrameRenderer->Create(pLoadWorker, "Resources\\Common\\MaterialFrame\\FrameTexture_MF.json")) return false;

		// ShadowPass Texture
		const auto& ShadowPass = pGraphicsAPI->FindOffScreenRenderPass("ShadowPass");
		if (ShadowPass)
		{
			m_SceneController->AddFrameTexture(ShadowPass->GetDepthTexture());
		}

		return true;
	}

	bool ModernPBR::ProcessInput(api::IGraphicsAPI* pGraphicsAPI)
	{
		return true;
	}

	bool ModernPBR::Resize(int Width, int Height)
	{
		m_Projection->SetScreenResolution(Width, Height);

		m_DrawInfo->GetLightProjection()->SetScreenResolution(Width, Height);

		return true;
	}

	bool ModernPBR::Update(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<input::CInputState>& InputState)
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
				m_MainCamera = m_TraceCamera;
			}
		}

		if (!m_PostProcess->Update(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_MainCamera, m_Projection, m_DrawInfo, InputState)) return false;
		if (!m_MainFrameRenderer->Update(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_MainCamera, m_Projection, m_DrawInfo, InputState)) return false;

		return true;
	}

	bool ModernPBR::LateUpdate(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker)
	{
		if (!m_SceneController->LateUpdate(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_DrawInfo)) return false;

		return true;
	}

	bool ModernPBR::FixedUpdate(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker)
	{
		if (!m_SceneController->FixedUpdate(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_DrawInfo)) return false;

		return true;
	}

	bool ModernPBR::Draw(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<input::CInputState>& InputState,
		const std::shared_ptr<gui::IGUIEngine>& GUIEngine)
	{
		// ShadowPass
		{
			if (!pGraphicsAPI->BeginRender("ShadowPass")) return false;
			// CameraとProjectionにはライト用の値を使用するように注意する
			if (!m_SceneController->Draw(pGraphicsAPI, m_DrawInfo->GetLightCamera(), m_DrawInfo->GetLightProjection(), m_DrawInfo)) return false;
			if (!pGraphicsAPI->EndRender()) return false;
		}

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

		// MainGeometryPass
		{
			// フォアグラウンドパス(MainGeometryPass)にGBufferLightPassのカラー・深度をコピーする
			if (!pGraphicsAPI->CopyRenderPass("GBufferLightPass", "MainGeometryPass", true, true)) return false;

			if (!pGraphicsAPI->BeginRender("MainGeometryPass")) return false;
			if (!m_SceneController->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;
			if (!pGraphicsAPI->EndRender()) return false;
		}

		// MainResultPass 
		{
			// ポストプロセスに渡すためにここではコピーだけを行う
			// パスを始めてしまうとせっかくコピーした内容がリセットされてしまう
			// MainGeometryPassとMainResultPassを分離したのはMainGeometryPassではカラー・デプスを初期化しないようにしているため、
			// その影響でうまくポストプロセスが効かなくなるから
			if (!pGraphicsAPI->CopyRenderPass("MainGeometryPass", "MainResultPass", true, true)) return false;
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

	std::shared_ptr<graphics::CDrawInfo> ModernPBR::GetDrawInfo() const
	{
		return m_DrawInfo;
	}

	// 起動準備完了
	bool ModernPBR::OnStartup(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<gui::IGUIEngine>& GUIEngine)
	{
		const auto& TimelineFileName = m_SceneController->GetTimelineFileName();
		if (!TimelineFileName.empty()) pLoadWorker->AddLoadResource(std::make_shared<resource::CTimelineClipLoader>(TimelineFileName, m_TimelineController->GetClip()));

		return true;
	}

	// ロード完了イベント
	bool ModernPBR::OnLoaded(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<gui::IGUIEngine>& GUIEngine)
	{
		if (!m_SceneController->Create(pGraphicsAPI, pPhysicsEngine)) return false;

		m_PostProcess->GetBloomFilter()->OnLoaded(m_SceneController);

		if (!m_TimelineController->Initialize(shared_from_this())) return false;

#ifdef USE_GUIENGINE
		{
			gui::SGUIParams GUIParams = gui::SGUIParams(shared_from_this(), GetObjectList(), m_SceneController, m_FileModifier, m_TimelineController, pLoadWorker, {}, pPhysicsEngine);
			GUIParams.ValueRegistryList.emplace(m_PostProcess->GetBloomFilter()->GetRegistryName(), m_PostProcess->GetBloomFilter());

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
	void ModernPBR::OnFocus(bool Focused, api::IGraphicsAPI* pGraphicsAPI, resource::CLoadWorker* pLoadWorker)
	{
		if (Focused && pLoadWorker)
		{
			m_FileModifier->OnFileUpdated(pLoadWorker);
		}
	}

	// エラー通知イベント
	void ModernPBR::OnAssertError(const std::string& Message)
	{
#ifdef USE_GUIENGINE
		m_GraphicsEditingWindow->AddLog(gui::EGUILogType::Error, Message);
#endif
	}

	// Getter
	std::vector<std::shared_ptr<object::C3DObject>> ModernPBR::GetObjectList() const
	{
		std::vector<std::shared_ptr<object::C3DObject>> ObjectList;

		for (const auto& Object : m_SceneController->GetObjectList())
		{
			ObjectList.push_back(Object);
		}

		return ObjectList;
	}

	std::shared_ptr<scene::CSceneController> ModernPBR::GetSceneController() const
	{
		return m_SceneController;
	}
}