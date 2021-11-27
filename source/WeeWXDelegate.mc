//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.

import Toybox.Lang;
import Toybox.WatchUi;

//! Handle input for the home view
class WeeWXDelegate extends WatchUi.BehaviorDelegate {

    //! Constructor
    public function initialize() {
        BehaviorDelegate.initialize();
    }

    //! Handle the menu event
    //! @return true if handled, false otherwise
    public function onMenu() as Boolean {
		var thisMenu = new WatchUi.Menu();
		
		thisMenu.setTitle(Rez.Strings.MainMenuTitle);
		for (var i = 1; i <= 5; i++) {
			addMenuItem(thisMenu, i);
		}
		
		WatchUi.pushView(thisMenu, new $.WeeWXMenuDelegate(), WatchUi.SLIDE_UP );

        return true;
    }

    public function onSelect() as Boolean {
		var thisMenu = new WatchUi.Menu();
		
		thisMenu.setTitle(Rez.Strings.MainMenuTitle);
		for (var i = 1; i <= 5; i++) {
			addMenuItem(thisMenu, i);
		}
		
		WatchUi.pushView(thisMenu, new $.WeeWXMenuDelegate(), WatchUi.SLIDE_UP );

        return true;
    }

	function addMenuItem(menu, slot)
	{
		var _slot_str = "option_slot" + slot + "_name";
		var _slot_data = Application.getApp().getProperty(_slot_str);
		
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
