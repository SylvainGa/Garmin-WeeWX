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
using Toybox.Application.Storage;
using Toybox.Application.Properties;

//! View for the home screen
class WeeWXView extends WatchUi.View {
	var _shown = false;

    //! Constructor
    public function initialize() {
        View.initialize();
	}

    public function onShow() as Void {

		if (!_shown) {
			var thisMenu;
			var thisDelegate;

			//DEBUG*/ logMessage("Creating menu and delegate");
			thisMenu = new WatchUi.Menu2({:title=>Rez.Strings.MainMenuTitle});
			thisDelegate = new WeeWXMenuDelegate();

			var slots = [ :Item1, :Item2, :Item3, :Item4, :Item5 ];
			for (var i = 1, index = 0; i <= 5; i++) {
				var _slot_str = "option_slot" + i + "_name";
				var _slot_data = Properties.getValue(_slot_str);
				if (_slot_data != null && _slot_data.length() > 0) {
					thisMenu.addItem(new MenuItem(_slot_data, null, slots[index], {}));
					index = index + 1;
				}
			}

			WatchUi.pushView(thisMenu, thisDelegate, WatchUi.SLIDE_IMMEDIATE);
			_shown = true;
		}
    }

    public function onLayout(dc) as Void {
		//DEBUG*/ logMessage("onLayout:Showing main layout");
    }

(:can_glance)
	function onUpdate(dc) {
		if (gBack) {
			try {
				WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); 
			}
			catch (e) {
				System.exit();
			}
		}
		
		var width = dc.getWidth();
		var height = dc.getHeight();

		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.clear();
		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(width / 2, height / 2, Gfx.FONT_SMALL, WatchUi.loadResource(Rez.Strings.back), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
	}


(:cant_glance)
	function onUpdate(dc) {
		var width = dc.getWidth();
		var height = dc.getHeight();

		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.clear();
		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(width / 2, height / 2, Gfx.FONT_SMALL, WatchUi.loadResource(Rez.Strings.back), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
	}
}