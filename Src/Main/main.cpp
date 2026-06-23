#include <AppCore/CAppRunner.h>
#include "../App/ScriptApp/ModernPBR.h"

int main()
{
	app::SAppSettings Settings = {};
	Settings.FullScreen = false;

	if (!app::CAppRunner::Run(std::make_shared<app::ModernPBR>(), Settings)) return 1;

	return 0;
}