//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System;


//! This sample shows how to define menus using resources and demonstrates the
//! use of nested menus. Press the Menu button to display an on-screen menu, which
//! has options to return to the home screen or display an auxiliary, nested menu.
class WeeWXApp extends Application.AppBase {

	var mView;
	
    //! Constructor
    public function initialize() {
        AppBase.initialize();
    }

    //! Handle app startup
    //! @param state Startup arguments
    public function onStart(state as Dictionary?) as Void {
    }

    //! Handle app shutdown
    //! @param state Shutdown arguments
    public function onStop(state as Dictionary?) as Void {
System.println("Stopping");
    }

    //! Return the initial views for the app
    public function getInitialView() as Array<Views or BehaviorDelegate>? {
    	var view = new $.WeeWXView(); 
        return [view, new WeeWXDelegate(view, view.method(:onReceive))];
    }
}

(:debug)
function logMessage(message) {
    System.println(message);
}

(:release)
function logMessage(message) {
    
}
