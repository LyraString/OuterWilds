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
    var mTimeFont;
    var mActivityFont;
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
        mTimeFont = WatchUi.loadResource(Rez.Fonts.TimeFont);
        mActivityFont = WatchUi.loadResource(Rez.Fonts.ActivityFont);
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
        drawDate(dc);
        drawEnvironment(dc);
        drawFooter(dc);
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
        drawStarlitTime(dc, text, is24Hour ? null : (clock.hour < 12 ? "AM" : "PM"));
    }

    function drawStarlitTime(dc, text, suffix) {
        var align = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        // Center the numerals in either time format; AM/PM sits separately to the right.
        var timeX = 130;
        // Slim white strokes float against the sky, with a quiet neutral halo.
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawText(timeX - 1, 110, mTimeFont, text, align);
        dc.drawText(timeX + 1, 110, mTimeFont, text, align);
        dc.drawText(timeX, 109, mTimeFont, text, align);
        dc.drawText(timeX, 111, mTimeFont, text, align);
        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(timeX, 110, mTimeFont, text, align);
        if (suffix != null) {
            var suffixX = timeX + dc.getTextWidthInPixels(text, mTimeFont) / 2 + 6;
            dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
            dc.drawText(suffixX, 120, Graphics.FONT_XTINY, suffix, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    function drawDate(dc) {
        dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
        dc.drawText(130, 139, Graphics.FONT_XTINY, mDate, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawEnvironment(dc) {
        dc.setColor(0xAAAA55, Graphics.COLOR_TRANSPARENT);
        dc.drawText(130, 35, Graphics.FONT_XTINY, mTemperature + "  " + mWeather,
                    Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
        dc.drawText(130, 56, Graphics.FONT_XTINY, "ALT " + mElevation,
                    Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawFooter(dc) {
        // Both activity values and icons share an ink baseline; battery is separate.
        var activityY = 221;
        var stepsText = stepDisplayText();
        var stepsWidth = 20 + dc.getTextWidthInPixels(stepsText, mActivityFont);
        var heartWidth = 20 + dc.getTextWidthInPixels(mHeartRate, mActivityFont);
        var stepsX = ((260 - stepsWidth - 18 - heartWidth) / 2).toNumber();
        var heartX = stepsX + stepsWidth + 18;
        dc.setColor(0xAAAA55, Graphics.COLOR_TRANSPARENT);
        drawFootstepsIcon(dc, stepsX, activityY + 3);
        dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
        dc.drawText(stepsX + 20, activityY, mActivityFont, stepsText, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(0xFF5500, Graphics.COLOR_TRANSPARENT);
        drawHeartIcon(dc, heartX, activityY + 4);
        dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
        dc.drawText(heartX + 20, activityY, mActivityFont, mHeartRate, Graphics.TEXT_JUSTIFY_LEFT);

        var batteryColor = mBattery <= 20 ? 0xFF5500 : 0xAAAAAA;
        var batteryText = mBattery.format("%d") + "%";
        var batteryX = ((260 - 12 - dc.getTextWidthInPixels(batteryText, Graphics.FONT_XTINY)) / 2).toNumber();
        dc.setColor(batteryColor, Graphics.COLOR_TRANSPARENT);
        drawBatteryIcon(dc, batteryX, 242);
        dc.drawText(batteryX + 12, 240, Graphics.FONT_XTINY, batteryText,
                    Graphics.TEXT_JUSTIFY_LEFT);
    }

    function stepDisplayText() {
        if (mSteps.length() <= 5) { return mSteps; }
        var count = mSteps.toNumber();
        // Unusually large counts stay compact without widening the footer.
        if (count < 1000000) { return (count / 1000).toNumber().format("%d") + "k"; }
        return (count / 1000000).toNumber().format("%d") + "M";
    }

    function drawFootstepsIcon(dc, x, y) {
        dc.fillRectangle(x + 1, y, 4, 6);
        dc.fillRectangle(x, y + 7, 6, 3);
        dc.fillRectangle(x + 8, y + 2, 4, 6);
        dc.fillRectangle(x + 7, y + 10, 6, 3);
    }

    function drawHeartIcon(dc, x, y) {
        dc.fillRectangle(x + 1, y, 5, 4);
        dc.fillRectangle(x + 8, y, 5, 4);
        dc.fillRectangle(x, y + 3, 14, 4);
        dc.fillRectangle(x + 2, y + 7, 10, 2);
        dc.fillRectangle(x + 4, y + 9, 6, 2);
        dc.fillRectangle(x + 6, y + 11, 2, 1);
    }

    function drawBatteryIcon(dc, x, y) {
        // One continuous column rises with the charge inside the upright outline.
        dc.fillRectangle(x + 2, y, 4, 2);
        dc.drawRectangle(x, y + 2, 8, 12);
        var height = (mBattery * 8 / 100).toNumber();
        if (height > 8) { height = 8; }
        if (height < 1 && mBattery > 0) { height = 1; }
        if (height > 0) { dc.fillRectangle(x + 2, y + 12 - height, 4, height); }
    }
}
