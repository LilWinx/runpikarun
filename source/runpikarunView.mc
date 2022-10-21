import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Activity;


class runpikarunView extends WatchUi.WatchFace {

    var pikaAnimation; // AnimationLayer extends Layer
    var _animationDelegate = null;
    var _playing;
    var bolt_bmp;
    var heart_bmp;
    var steps_bmp;

    function initialize() {
        WatchFace.initialize();
        _animationDelegate = new RunningPikachuController();
        bolt_bmp = Application.loadResource(Rez.Drawables.bolt) as BitmapResource;
        heart_bmp = Application.loadResource(Rez.Drawables.heart) as BitmapResource;
        steps_bmp = Application.loadResource(Rez.Drawables.steps) as BitmapResource;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        // setLayout(Rez.Layouts.WatchFace(dc));   
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        _animationDelegate.handleOnShow(self);
        _animationDelegate.play();
    }

        // Build up the time string
    private function getTimeString() {
        var clockTime = System.getClockTime();
        var info = System.getDeviceSettings();

        var hour = clockTime.hour;

        if( !info.is24Hour ) {
            hour = clockTime.hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }

        return Lang.format("$1$:$2$", [hour, clockTime.min.format("%02d")]);
    }
    // get Date
    private function getDate() {
        var date = Time.Gregorian.info(Time.now(),0);
        var day = date.day;
        var month = date.month;
        var month_str = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM).month;
        var dayofweek_str = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dayofweek = dayofweek_str.day_of_week;
        return dayofweek.toString() + " " + day.toString() + " " + month_str.substring(0,3);
    }
    // get HR 
    private function getHeartRate() {
        var activity = Activity.getActivityInfo();
        var heartrate = activity.currentHeartRate;
        if (heartrate == null) {
            return "ded";
        }
        return heartrate.toNumber();
    }

    // get Battery 
    private function getBatteryPercentage() {
        var stats = System.getSystemStats();
        var batteryRaw = stats.battery;
        return batteryRaw > batteryRaw.toNumber() ? (batteryRaw + 1).toNumber() : batteryRaw.toNumber() + "%";
    }

    // get Steps
    private function getSteps() {
        var info = ActivityMonitor.getInfo();
        return info.steps.toString();
    }

    // Function to render the time on the time layer
    private function updateTimeLayer() {
        var dc = _animationDelegate.getTextLayer().getDc();
        var width = dc.getWidth();
        var height = dc.getHeight();

        // Clear the layer contents
        var timeString = getTimeString();
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        dc.clear();

        // Draw the time in the bottom
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, (height / 2) + 120, Graphics.FONT_NUMBER_MEDIUM, timeString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Draw the date above Pikachu
        var dateString = getDate();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, (height / 2) - 120, Graphics.FONT_SMALL, dateString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw the steps and step counter
        dc.drawBitmap((width / 2) - 70, (height / 2) - 100, steps_bmp);
        var stepString = getSteps();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText((width / 2) - 25, (height / 2) - 85, Graphics.FONT_TINY, stepString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw the Battery Percentage on the sides
        dc.drawBitmap((width / 6) - 20, (height / 2) + 25, bolt_bmp);
        var batteryString = getBatteryPercentage();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText((width / 6), (height / 2) + 70, Graphics.FONT_TINY, batteryString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw the Heart Rate on the other side
        dc.drawBitmap((5 * width / 6) - 20, (height / 2) + 25, heart_bmp);
        var hrString = getHeartRate();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText((5 * width / 6) - 5, (height / 2) + 70, Graphics.FONT_TINY, hrString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Clear the screen buffer
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        // Update the contents of the time layer
        updateTimeLayer();
        return;
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        _animationDelegate.handleOnHide(self);
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        _animationDelegate.play();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        _animationDelegate.stop();
    }


}

