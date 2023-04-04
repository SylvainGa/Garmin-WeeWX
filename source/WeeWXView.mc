//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.

/*
outTemp
windSpeed
windDir
windGust
windchill
heatIndex
humidity

$1$||Temp : $2$ C|Vit vent : $3$ KMH|Dir vent : $4$|Rafale : $5$ KMH|Fac. vent: $6$ C|Ind. chaleur: $7$ C|Humidité: $8$%
N,NNE,NE,ENE,E,ESE,SE,SSE,S,SSW,SW,WSW,W,WNW,NW,NNW
*/

using Toybox.Graphics as Gfx;
using Toybox.Lang;
using Toybox.WatchUi;

//! View for the home screen
class WeeWXView extends WatchUi.View {
	var _width, _height;
	var _shown = false;

    //! Constructor
    public function initialize() {
        View.initialize();
	}

    public function onShow() as Void {

		if (!_shown) {
			var thisMenu;
			var thisDelegate;

			logMessage("Creating menu and delegate");
			thisMenu = new WatchUi.Menu2({:title=>Rez.Strings.MainMenuTitle});
			thisDelegate = new WeeWXMenuDelegate();

			var slots = [ :Item1, :Item2, :Item3, :Item4, :Item5 ];
			for (var i = 1, index = 0; i <= 5; i++) {
				var _slot_str = "option_slot" + i + "_name";
				var _slot_data = Application.getApp().getProperty(_slot_str);
				if (_slot_data != null && !_slot_data.equals("")) {
					thisMenu.addItem(new MenuItem(_slot_data, null, slots[index], {}));
					index = index + 1;
				}
			}

			WatchUi.pushView(thisMenu, thisDelegate, WatchUi.SLIDE_IMMEDIATE);
			_shown = true;
		}
    }

    public function onLayout(dc) as Void {
		logMessage("onLayout:Showing main layout");
		_width = dc.getWidth();
		_height = dc.getHeight();
    }

	function onUpdate(dc) {
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.clear();
		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(_width / 2, _height / 2, Gfx.FONT_SMALL, WatchUi.loadResource(Rez.Strings.back), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
	}
}