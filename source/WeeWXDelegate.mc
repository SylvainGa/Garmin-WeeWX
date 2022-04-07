//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.

import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Input handler to respond to main menu selections
class WeeWXDelegate extends WatchUi.BehaviorDelegate {
	var _view;
	var _handler;
	
    //! Constructor
    public function initialize(view as WeeWXView, handler) {
logMessage("WeeWXDelegate initializing");
        BehaviorDelegate.initialize();
        _view = view;
		_handler = handler;
    }

    function onKey(keyEvent) {
        logMessage(keyEvent.getKey());         // e.g. KEY_MENU = 7
        return true;
    }

    public function onTap(item as Symbol) as Void {
logMessage("WeeWXDelegate:Tap with _view._status at " + _view._status);
		if (_view._status == 1) {
			_view._status = 0;
			_handler.invoke(null);
	        WatchUi.requestUpdate();
		}
        return true;
    }

    public function onBack() as Void {
logMessage("WeeWXDelegate:Back with _view._status at " + _view._status);
		if (_view._status == 1) {
			_view._status = 0;
			_handler.invoke(null);
	        WatchUi.requestUpdate();
			return true;
		}
		else {
logMessage("Exiting?");
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			return false;
		}
    }
}
