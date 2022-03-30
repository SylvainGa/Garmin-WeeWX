//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.

/*
outTemp
windSpeed
windDir
windGust
$1$\n\nTemp : $2$ C\nVit vent : $3$ KMH\nDir vent : $4$\nRafale : $5$ KMH\nFac. vent: $6$ KMH\nInd. chaleur: $7$ KMH\nHumidité: $8$%
N,NNE,NE,ENE,E,ESE,SE,SSE,S,SSW,SW,WSW,W,WNW,NW,NNW
*/

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! View for the home screen
class WeeWXView extends WatchUi.View {
	var thisMenu;
	var thisDelegate;
	var _message;
	var _status;
	var _menuDisplayed;
			
    //! Constructor
    public function initialize() {
        View.initialize();
        _message = null;
        _menuDisplayed = false;
        _status = -1;

		logMessage("Creating menu and delegate");
		thisMenu = new WatchUi.Menu();
		thisDelegate = new WeeWXMenuDelegate(method(:onReceive));
		thisMenu.setTitle(Rez.Strings.MainMenuTitle);

		for (var i = 1, index = 1; i <= 5; i++) {
			var _slot_str = "option_slot" + i + "_name";
			var _slot_data = Application.getApp().getProperty(_slot_str);
			if (_slot_data != null && !_slot_data.equals("")) {
				addMenuItem(thisMenu, index, _slot_data);
				index = index + 1;
			}
		}
    }
    
    //! Load your resources here
    //! @param dc Device context
    public function onLayout(dc as Dc) as Void {
        setLayout($.Rez.Layouts.MainLayout(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    public function onShow() as Void {
    	if (_message == null) {
			logMessage("Showing without text status is " + _status);
			if (_status == 0) {
				logMessage("Exiting");
				_status = 2;
				return true;
			}
		} else {
			logMessage("Showing with text status is " + _status);
		}
		
		return false;
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    public function onHide() as Void {
		logMessage("Hiding status is " + _status);
		if (_status == -1) {
			_status = 0;
		}
    }
    
    function onReceive(args) as Void {
    	if (args != null) {
			logMessage("onReceive with text");
			if (args.equals(WatchUi.loadResource(Rez.Strings.Awaiting_response))) {
				_status = 1;
			}
    	}
    	else {
			logMessage("onReceive null");
    	}
		_message = args;
    }

    //! Update the view
    //! @param dc Device context
    public function onUpdate(dc as Dc) as Void {
		if (_message == null) {		 
			if (_menuDisplayed == false) {
				logMessage("pushing menu and delegate");
		        _menuDisplayed = true;
				WatchUi.pushView(thisMenu, thisDelegate, WatchUi.SLIDE_UP );
			} else {
				logMessage("Menu already up, skipping pushView");
			}
        }
        else {
			logMessage("Displaying text");
	        _menuDisplayed = false;
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
			dc.clear();
			dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, _message, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

 	function addMenuItem(menu, slot, _slot_data)
	{
		switch (slot) {
			case 1:
				menu.addItem(_slot_data, :Item1);
				break;
			case 2:
				menu.addItem(_slot_data, :Item2);
				break;
			case 3:
				menu.addItem(_slot_data, :Item3);
				break;
			case 4:
				menu.addItem(_slot_data, :Item4);
				break;
			case 5:
				menu.addItem(_slot_data, :Item5);
				break;
		}
	}
}

