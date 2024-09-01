using Toybox.WatchUi as Ui;
using Toybox.Timer;
using Toybox.Time;
using Toybox.System;
using Toybox.Communications as Communications;
using Toybox.Cryptography;
using Toybox.Graphics;
using Toybox.Application.Storage;
using Toybox.Application.Properties;

class graphDelegate extends Ui.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() {
		Ui.popView(Ui.SLIDE_IMMEDIATE);
        return true;
    }

    function onTap(click) {
		Ui.popView(Ui.SLIDE_IMMEDIATE);
        return true;
    }
}
