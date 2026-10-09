using Toybox.Application;

class CampfireApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new CampfireFace() ];
    }
}
