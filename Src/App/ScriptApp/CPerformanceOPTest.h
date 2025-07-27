#pragma once
#include <memory>
#include <AppCore/CApp.h>

namespace graphics { 
	class CFrameRenderer; 
	class CPostProcess;
}
namespace gui { class CGraphicsEditingWindow; }
namespace timeline { class CTimelineController; }
namespace scene { class CSceneController; }
namespace camera { class CLookUpTraceCamera; }
namespace network { 
	class CUDPSocket; 
	class CDMXDataHandler;
	class CNDIReceiver;
}

namespace app
{
	class CFileModifier;

	class CPerformanceOPTest : public CApp
	{
		std::shared_ptr<scene::CSceneController> m_SceneController;

		bool m_CameraSwitchToggle;

		std::shared_ptr<camera::CCamera> m_MainCamera;
		std::shared_ptr<camera::CCamera> m_ViewCamera;

		std::shared_ptr<camera::CLookUpTraceCamera> m_CurrentLookUpCamera;
		std::shared_ptr<camera::CLookUpTraceCamera> m_LookUpCameraA;
		std::shared_ptr<camera::CLookUpTraceCamera> m_LookUpCameraB;
		bool m_LookUpSwitchToggle;

		std::shared_ptr<projection::CProjection> m_Projection;
		std::shared_ptr<graphics::CDrawInfo> m_DrawInfo;

		std::shared_ptr<graphics::CFrameRenderer> m_MainFrameRenderer;

		std::shared_ptr<CFileModifier> m_FileModifier;
#ifdef USE_GUIENGINE
		std::shared_ptr<gui::CGraphicsEditingWindow> m_GraphicsEditingWindow;
#endif // USE_GUIENGINE

		std::shared_ptr<timeline::CTimelineController> m_TimelineController;

		std::shared_ptr<graphics::CPostProcess> m_PostProcess;

#ifdef USE_NETWORK
		std::shared_ptr<network::CUDPSocket> m_UDPSocket;
		std::shared_ptr<network::CDMXDataHandler> m_DMXHandler;

		std::shared_ptr<network::CNDIReceiver> m_NDIReceiver;
#endif

	public:
		CPerformanceOPTest();
		virtual ~CPerformanceOPTest() = default;

		virtual bool Release(api::IGraphicsAPI* pGraphicsAPI) override;

		virtual bool Initialize(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker) override;
		virtual bool ProcessInput(api::IGraphicsAPI* pGraphicsAPI) override;
		virtual bool Resize(int Width, int Height) override;
		virtual bool Update(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<input::CInputState>& InputState) override;
		virtual bool LateUpdate(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker) override;
		virtual bool FixedUpdate(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker) override;

		virtual bool Draw(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<input::CInputState>& InputState,
			const std::shared_ptr<gui::IGUIEngine>& GUIEngine) override;

		virtual std::shared_ptr<graphics::CDrawInfo> GetDrawInfo() const override;

		// コンポーネント作成
		virtual std::shared_ptr<scriptable::CComponent> CreateComponent(const std::string& ComponentType, const std::string& ValueRegistry) override;

		// 起動準備完了
		virtual bool OnStartup(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<gui::IGUIEngine>& GUIEngine) override;

		// ロード完了イベント
		virtual bool OnLoaded(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<gui::IGUIEngine>& GUIEngine) override;

		// フォーカスイベント
		virtual void OnFocus(bool Focused, api::IGraphicsAPI* pGraphicsAPI, resource::CLoadWorker* pLoadWorker) override;

		// エラー通知イベント
		virtual void OnAssertError(const std::string& Message) override;

		// Getter
		virtual std::vector<std::shared_ptr<object::C3DObject>> GetObjectList() const override;
		virtual std::shared_ptr<scene::CSceneController> GetSceneController() const override;

		// DMXデータ受信イベント
		virtual void OnReceiveArtNetDMX(unsigned short Net, unsigned short SubNet, unsigned short Universe, const std::vector<unsigned char>& DataBuffer) override;

		// NDIデータ受信イベント
		virtual void OnReceiveNDIImage(const std::vector<unsigned char>& pixelData, int Width, int Height, api::ERenderPassFormat RenderPassFormat) override;

		// カスタムイベント発火
		virtual void OnRaisedEvent(const std::string& Type, const std::string& Params) override;
	};
}