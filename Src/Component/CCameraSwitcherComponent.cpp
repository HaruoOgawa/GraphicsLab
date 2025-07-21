#include "CCameraSwitcherComponent.h"
#include <AppCore/CApp.h>
#include <Camera/CLookUpTraceCamera.h>
#include <Binary/CBinaryReader.h>

namespace scriptable
{
	CCameraSwitcherComponent::CCameraSwitcherComponent(const std::string& ComponentName, const std::string& RegistryName, const std::shared_ptr<app::CApp>& App,
		const std::vector<std::shared_ptr<camera::CLookUpTraceCamera>>& CameraList) :
		CComponent(ComponentName, RegistryName),
		m_CurrentID(-1),
		m_App(App),
		m_CameraList(CameraList)
	{
	}
	
#ifdef USE_NETWORK
	void CCameraSwitcherComponent::OnReceiveDMXData(const network::SDMXFixture& Fixture, const std::vector<unsigned char>& DMXData)
	{
		if (Fixture.DeviceName == "CameraSwitcher")
		{
			if (Fixture.ChannelNameList.size() != 33) return;

			if (m_CameraList.size() != 2) return;

			binary::CBinaryReader Analyzer(DMXData);

			int PrevID = m_CurrentID;

			unsigned char IDByte = 0;
			if (!Analyzer.GetByte(IDByte)) return;
			m_CurrentID = static_cast<int>(IDByte);

			// カメラ情報反映
			for (auto& Camera : m_CameraList)
			{
				float PosX = 0.0f;
				if (!Analyzer.GetFloat(PosX)) return;

				float PosY = 0.0f;
				if (!Analyzer.GetFloat(PosY)) return;

				float PosZ = 0.0f;
				if (!Analyzer.GetFloat(PosZ)) return;

				float ZAngle = 0.0f;
				if (!Analyzer.GetFloat(ZAngle)) return;

				Camera->SetPos(glm::vec3(PosX, PosY, PosZ));
 				Camera->SetZAngle(ZAngle);
			}

			// カメラ切り替え
			if (PrevID != m_CurrentID)
			{
				// 挙動が怪しいのでひとまず常に最初のカメラを使用(あとでリファクタリング)
				//m_App->OnRaisedEvent("CameraSwitch", "");
			}
		}
	}
#endif // USE_NETWORK
}