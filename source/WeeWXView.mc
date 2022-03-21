//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! View for the home screen
class WeeWXView extends WatchUi.View {
	var thisMenu;
	var thisDelegate;
	
    //! Constructor
    public function initialize() {
        View.initialize();
        Application.getApp().setProperty("message", null);
        Application.getApp().setProperty("exit", false);
        Application.getApp().setProperty("menuDisplayed", false);
        thisMenu = null;
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
System.println("Showing");
    }

    //! Update the view
    //! @param dc Device context
    public function onUpdate(dc as Dc) as Void {
		var _message = Application.getApp().getProperty("message");
		if (_message == null) {		 
//	        View.onUpdate(dc);

			var _exit = Application.getApp().getProperty("exit");
			if (_exit) {
System.println("Exiting");
				WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
				System.exit();
			}

			if (thisMenu == null) {
System.println("Creating menu and delegate");
				thisMenu = new WatchUi.Menu();
				thisDelegate = new $.WeeWXMenuDelegate();
				thisMenu.setTitle(Rez.Strings.MainMenuTitle);
	
				for (var i = 1, index = 1; i <= 5; i++) {
					var _slot_str = "option_slot" + i + "_name";
					var _slot_data = Application.getApp().getProperty(_slot_str);
					if (_slot_data != null && !_slot_data.equals("")) {
						addMenuItem(thisMenu, index, _slot_data);
						index = index + 1;
					}
				}
//				thisMenu.addItem(WatchUi.loadResource($.Rez.Strings.back), :Back);

			}
			var _menuDisplayed = Application.getApp().getProperty("menuDisplayed");
			if (_menuDisplayed == false) {
System.println("pushing menu and delegate");
		        Application.getApp().setProperty("menuDisplayed", true);
				WatchUi.pushView(thisMenu, thisDelegate, WatchUi.SLIDE_UP );
			} else {
System.println("Menu already up, skipping pushView");
			}
        }
        else {
System.println("Displaying text");
	        Application.getApp().setProperty("menuDisplayed", false);
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
			dc.clear();
			dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, _message, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    public function onHide() as Void {
System.println("Hiding");
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
