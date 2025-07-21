#pragma once

#include <memory>
#include <vector>
#include <Scriptable/CComponent.h>

namespace app { class CApp; }
namespace camera { class CLookUpTraceCamera; }

namespace scriptable
{
	class CCameraSwitcherComponent : public scriptable::CComponent
	{
		int m_CurrentID;

		std::shared_ptr<app::CApp> m_App;

		std::vector<std::shared_ptr<camera::CLookUpTraceCamera>> m_CameraList;
	public:
		CCameraSwitcherComponent(const std::string& ComponentName, const std::string& RegistryName, const std::shared_ptr<app::CApp>& App,
			const std::vector<std::shared_ptr<camera::CLookUpTraceCamera>>& CameraList);
		virtual ~CCameraSwitcherComponent() = default;

#ifdef USE_NETWORK
		virtual void OnReceiveDMXData(const network::SDMXFixture& Fixture, const std::vector<unsigned char>& DMXData) override;
#endif // USE_NETWORK
	};
}