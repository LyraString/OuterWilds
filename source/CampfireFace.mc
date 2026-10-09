using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;

// Fenix 7 Pro: 260 x 260, MIP. The system owns the update schedule.
class CampfireFace extends WatchUi.WatchFace {
    var mSleeping = true;
    var mFont as PixelFont;
    var mScene as CampfireScene;
    var mDate = "";
    var mBattery = 0;
    var mSteps = "--";
    var mHeartRate = "--";
    var mLastDataUpdate = -1;
    var mWeekdays as Lang.Array<Lang.String> = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

    function initialize() {
        WatchFace.initialize();
        mFont = new PixelFont();
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
        drawActivity(dc);
    }

    function refreshData(now) {
        var date = Gregorian.info(now, Time.FORMAT_SHORT);
        mDate = mWeekdays[date.day_of_week - 1] + " " +
                date.month.format("%02d") + "." + date.day.format("%02d");
        mBattery = System.getSystemStats().battery.toNumber();

        var steps = ActivityMonitor.getInfo().steps;
        mSteps = steps == null ? "--" : steps.format("%d");

        var hr = Activity.getActivityInfo().currentHeartRate;
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
    }

    function drawClock(dc, clock) {
        mFont.draw(dc, "UNDER THE STARS", 130, 29, 1, 2, 0xAAAA55);
        var hour = clock.hour;
        var is24Hour = System.getDeviceSettings().is24Hour;
        if (!is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }
        var text = hour.format("%02d") + ":" + clock.min.format("%02d");
        mFont.draw(dc, text, 130, 55, 6, 4, 0xFFFFFF);
        if (!is24Hour) {
            mFont.draw(dc, clock.hour < 12 ? "AM" : "PM", 217, 90, 1, 1, 0xAAAAAA);
        }
    }

    function drawDateAndBattery(dc) {
        mFont.draw(dc, mDate, 100, 111, 2, 2, 0xAAAAAA);
        var color = mBattery <= 20 ? 0xFF5500 : 0xAAAA55;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(157, 113, 12, 9);
        dc.fillRectangle(170, 116, 2, 3);
        var fill = (mBattery * 9 / 100).toNumber();
        if (fill > 0) { dc.fillRectangle(159, 115, fill, 6); }
        mFont.draw(dc, mBattery.format("%d"), 192, 111, 2, 2, color);
    }

    function drawActivity(dc) {
        // Keep both groups inside the circular screen at y=226..239.
        // Six-digit counts use a compact scale to avoid colliding with the heart.
        var scale = mSteps.length() > 5 ? 1 : 2;
        mFont.draw(dc, mSteps, 102, 226, scale, 2, 0xAAAAAA);
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
        mFont.draw(dc, mHeartRate, 183, 226, 2, 2, 0xAAAAAA);
    }
}
