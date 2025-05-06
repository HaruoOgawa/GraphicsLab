#pragma once

#include <Scriptable/CComponent.h>
#include <vector>
#include <glm/glm.hpp>

namespace object { 
	class C3DObject;
	class CNode;
}

namespace graphics {
	class CMesh;
	class CMaterial;
}

namespace component
{
	class CCDIKTest : public scriptable::CComponent
	{
		std::shared_ptr<object::CNode> m_TargetNode;

		std::vector<std::shared_ptr<object::CNode>> m_LinkList;
	public:
		CCDIKTest(const std::string& ComponentName, const std::string& RegistryName);
		virtual ~CCDIKTest();

		virtual bool OnLoaded(api::IGraphicsAPI* pGraphicsAPI, const std::shared_ptr<scene::CSceneController>& SceneController,
			const std::shared_ptr<object::C3DObject>& Object, const std::shared_ptr<object::CNode>& SelfNode) override;

		virtual bool Update(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<camera::CCamera>& Camera, const std::shared_ptr<projection::CProjection>& Projection,
			const std::shared_ptr<graphics::CDrawInfo>& DrawInfo, const std::shared_ptr<input::CInputState>& InputState) override;
	};
}