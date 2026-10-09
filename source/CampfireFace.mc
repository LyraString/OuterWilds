using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.SensorHistory;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;
using Toybox.Weather;

// Fenix 7 Pro: 260 x 260, MIP. The system owns the update schedule.
class CampfireFace extends WatchUi.WatchFace {
    var mSleeping = true;
    var mScene as CampfireScene;
    var mDate = "";
    var mBattery = 0;
    var mSteps = "--";
    var mHeartRate = "--";
    var mElevation = "-- m";
    var mTemperature = "--\u00B0C";
    var mWeather = "N/A";
    var mLastDataUpdate = -1;
    var mWeekdays as Lang.Array<Lang.String> = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

    function initialize() {
        WatchFace.initialize();
        mScene = new CampfireScene();
    }

    function onEnterSleep() {
        mSleeping = true;
        // Draw the resting pose immediately; never leave an ember suspended.
        WatchUi.requestUpdate();
    }

    function onExitSleep() {
        mSleeping = false;
        mLastDataUpdate = -1;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        var clock = System.getClockTime();
        var now = Time.now();
        var stamp = now.value();
        // Refresh data once per minute at rest, every five seconds when awake.
        if (mLastDataUpdate < 0 || stamp < mLastDataUpdate ||
            (stamp / 60).toNumber() != (mLastDataUpdate / 60).toNumber() ||
            (!mSleeping && stamp - mLastDataUpdate >= 5)) {
            refreshData(now);
            mLastDataUpdate = stamp;
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setPenWidth(1);
        mScene.drawSky(dc, clock.sec, mSleeping);
        mScene.drawLandscape(dc);
        mScene.drawCampfire(dc, mSleeping ? 2 : clock.sec % 6, mSleeping);
        drawClock(dc, clock);
        drawDateAndBattery(dc);
        drawEnvironment(dc);
        drawActivity(dc);
    }

    function refreshData(now) {
        var date = Gregorian.info(now, Time.FORMAT_SHORT);
        mDate = mWeekdays[date.day_of_week - 1] + " " +
                date.month.format("%02d") + "." + date.day.format("%02d");
        mBattery = System.getSystemStats().battery.toNumber();

        var steps = ActivityMonitor.getInfo().steps;
        mSteps = steps == null ? "--" : steps.format("%d");

        var activity = Activity.getActivityInfo();
        var hr = activity.currentHeartRate;
        if (hr == null || hr <= 0 || hr == ActivityMonitor.INVALID_HR_SAMPLE) {
            // Use only a recent recorded sample; do not start a sensor session.
            var sample = ActivityMonitor.getHeartRateHistory(1, true).next();
            hr = null;
            if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE &&
                sample.heartRate > 0 && now.value() - sample.when.value() >= 0 &&
                now.value() - sample.when.value() <= 300) {
                hr = sample.heartRate;
            }
        }
        mHeartRate = hr == null ? "--" : hr.format("%d");
        refreshEnvironment(activity, now);
    }

    function refreshEnvironment(activity, now) {
        var settings = System.getDeviceSettings();
        var elevation = activity.altitude;
        if (elevation == null) {
            // Read the altimeter's existing sample; do not start GPS or a sensor.
            var sample = SensorHistory.getElevationHistory({
                :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST
            }).next();
            if (sample != null && sample.data != null &&
                now.value() - sample.when.value() >= 0 &&
                now.value() - sample.when.value() <= 300) {
                elevation = sample.data;
            }
        }
        mElevation = CampfireConditions.elevationText(elevation, settings.elevationUnits);

        var weather = Weather.getCurrentConditions();
        mWeather = "N/A";
        mTemperature = CampfireConditions.temperatureText(null, settings.temperatureUnits);
        if (weather != null) {
            if (CampfireConditions.weatherIsStale(weather.observationTime, now)) {
                mWeather = "STALE";
            } else {
                mTemperature = CampfireConditions.temperatureText(weather.temperature, settings.temperatureUnits);
                mWeather = CampfireConditions.weatherLabel(weather.condition);
            }
        }
    }

    function drawClock(dc, clock) {
        var hour = clock.hour;
        var is24Hour = System.getDeviceSettings().is24Hour;
        if (!is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }
        var text = hour.format("%02d") + ":" + clock.min.format("%02d");
        // Garmin's bold outdoor numerals keep the time clear above the clearing.
        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(130, 76, Graphics.FONT_NUMBER_HOT, text,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        if (!is24Hour) {
            dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
            dc.drawText(223, 87, Graphics.FONT_XTINY, clock.hour < 12 ? "AM" : "PM",
                        Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function drawDateAndBattery(dc) {
        dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
        dc.drawText(100, 109, Graphics.FONT_XTINY, mDate, Graphics.TEXT_JUSTIFY_CENTER);
        var color = mBattery <= 20 ? 0xFF5500 : 0xAAAA55;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(157, 113, 12, 9);
        dc.fillRectangle(170, 116, 2, 3);
        var fill = (mBattery * 9 / 100).toNumber();
        if (fill > 0) { dc.fillRectangle(159, 115, fill, 6); }
        dc.drawText(192, 109, Graphics.FONT_XTINY, mBattery.format("%d") + "%",
                    Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawEnvironment(dc) {
        dc.setColor(0xAAAA55, Graphics.COLOR_TRANSPARENT);
        dc.drawText(130, 27, Graphics.FONT_XTINY, mTemperature + "  " + mWeather,
                    Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
        dc.drawText(128, 132, Graphics.FONT_XTINY, "ALT " + mElevation,
                    Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawActivity(dc) {
        // Keep both groups inside the circular screen at y=226..239.
        dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
        dc.drawText(102, 224, Graphics.FONT_XTINY, mSteps, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(0xAAAA55, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(62, 227, 3, 5);
        dc.fillRectangle(61, 233, 5, 3);
        dc.fillRectangle(68, 229, 3, 5);
        dc.fillRectangle(67, 235, 5, 3);
        dc.setColor(0xFF5500, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(151, 228, 4, 4);
        dc.fillRectangle(157, 228, 4, 4);
        dc.fillRectangle(150, 231, 12, 3);
        dc.fillRectangle(152, 234, 8, 2);
        dc.fillRectangle(154, 236, 4, 2);
        dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
        dc.drawText(183, 224, Graphics.FONT_XTINY, mHeartRate, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
