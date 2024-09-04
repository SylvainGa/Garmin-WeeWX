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

using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Application.Storage;
using Toybox.Application.Properties;

//! View for the home screen
class graphView extends WatchUi.View {
    //! Constructor
    public function initialize() {
        View.initialize();
	}

    public function onShow() as Void {

    }

    public function onLayout(dc) as Void {
		//DEBUG*/ logMessage("onLayout:Showing main layout");
    }

	function onUpdate(dc) {
		var width = dc.getWidth();
		var height = dc.getHeight();

		// Read the data into an array
		var history_str = Storage.getValue("history");
		//var timestamp_str = Storage.getValue("timestamp");
		if (history_str != null /*&& timestamp_str != null*/) {
			var max_size;
			try {
				max_size = Properties.getValue("historySize");
			}
			catch (e) {
				max_size = 288;  // 24 hours * 60 minutes / 5 minutes between samples = 288 samples in 24 hours
			}

			if (max_size == null) {
				max_size = 288;
			}
			var history = to_array(history_str,";", max_size);
			//var timestamp = to_array(timestamp_str,";", max_size);

			//DEBUG*/ history = [ "20.3","20.2","20.1","20.0","20.0","19.6","19.4","19.2","19.0","18.9","18.9","18.9","18.9","18.8","18.8","18.9","19.0","19.0","18.9","null","18.7","18.5","18.4","18.3","null","null","null","null","18.3","18.3","18.3","18.3","18.3","18.3","18.3","18.3","18.3","18.3","18.2","18.1","18.1","18.1","18.0","18.0","18.0","17.9","17.9","17.9","17.8","17.8","17.8","17.8","17.8","17.8","17.8","17.8","17.8","17.8","17.8","17.8","17.8","17.8","17.8","17.9","17.9","17.9","17.9","17.9","17.9","17.9","17.9","17.9","18.0","18.0","18.0","18.1","18.1","18.2","18.2","18.3","18.3","18.4","18.4","18.5","18.5","18.5","18.6","18.7","18.7","18.8","18.8","18.8","18.8","18.8","18.9","18.9","18.9","18.9","18.9","18.9","18.9","18.9","19.0","19.0","19.0","19.0","19.1","19.1","19.1" ];

			var history_size = history.size();
			//var timestamp_size = timestamp.size();
			var array_size = history_size; //(history_size < timestamp_size ? history_size : timestamp_size );

			// The the highest and lowest value so we can build our Y scale
			var index;
			var high;
			var low;
			for (index = 0; index < array_size; index++) {
				var value = history[index];
				if (value != null) {
					try {
						value = value.toFloat();
					}
					catch (e) {
						value = null;
					}
				}

				if (value != null) {
					if (high == null || high < value) {
						high = value;
					}
					if (low == null || low > value) {
						low = value;
					}
				}
				else {
					/*DEBUG*/ logMessage("index " + index + " is null");
				}

				history[index] = value; // SO we don't need to convert again when plotting
			}

			// Now draw those scales
			if (high != null && low != null) {
				// low = -12.0;
				// high = 26.0;

				dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
				dc.clear();
				dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);

				// Max range to display
				var yZero;
				var xPos;
				var highTop;
				var lowBottom;
				var shapeOffset = (Sys.getDeviceSettings().screenShape == Sys.SCREEN_SHAPE_RECTANGLE ? height / 20 : height / 10);
				var drawableHeight = (height - (shapeOffset * 2));

				highTop = ((high + 5.0) / 5.0).toNumber() * 5.0;
				lowBottom = ((low - 5.0) / 5.0).toNumber() * 5.0;

				var yRange = highTop - lowBottom;

				if (low < 0.0 && high > 0.0) { // X axis is mid screen, find its position
					yZero = highTop / yRange;
					xPos = height * yZero;
				}
				else if (high < 0.0) { // All data is below 0C
					xPos = shapeOffset;
					yRange = lowBottom; // Our range is from 0 to low
				}
				else {
					xPos = height - shapeOffset; // All data is above 0C
					yRange = highTop; // Our range is from 0 to high
				}

				// Draw X axis
				dc.drawLine(0, xPos, width, xPos);

				// Draw Y Axis
				dc.drawLine(width / 2, 0, width / 2, height);

				if (high >= 0.0) {
					for (index = 5; index <= highTop; index += 5) {
						var yValue = xPos - ((index * drawableHeight) / yRange);
						dc.drawLine(width / 2 - (index % 10 == 0 ? 10 : 5), yValue, width / 2 + (index % 10 == 0 ? 10 : 5), yValue);
						if (index % 2 == 0 && index != 0) {
							dc.drawText(width / 2 - 15, yValue, Gfx.FONT_TINY, index.toString(), Gfx.TEXT_JUSTIFY_RIGHT | Gfx.TEXT_JUSTIFY_VCENTER);
						}
					}
				}
				if (low < 0.0) {
					for (index = -5; index >= lowBottom; index -= 5) {
						var yValue = xPos - (((index * drawableHeight) / yRange));
						dc.drawLine(width / 2 - (index % 10 == 0 ? 10 : 5), yValue, width / 2 + (index % 10 == 0 ? 10 : 5), yValue);
						if (index % 2 == 0 && index != 0) {
							dc.drawText(width / 2 - 15, yValue, Gfx.FONT_TINY, index.toString(), Gfx.TEXT_JUSTIFY_RIGHT | Gfx.TEXT_JUSTIFY_VCENTER);
						}
					}
				}

				dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

				// Now plot the data
				var prevValue; // Last known value we got so we know from where to start our line
				var prevPos = 0;
				var startPos = max_size - array_size;
				for (index = 0; index < array_size; index++) { // We start at one so we can draw from a previous point
					var valuePos = (index + startPos) * width / max_size;
					var value = history[index];
					var yValue;

					if (value != null) { // Only we if got real value from the array
						yValue = xPos - ((value * drawableHeight) / yRange);

						if (prevValue == null) {
							prevValue = value;
							dc.drawPoint(valuePos, yValue);
						}
						else {
							if (prevPos != valuePos || prevValue != yValue) {
								dc.drawLine(prevPos, prevValue, valuePos, yValue);

							}
						}
					}
					else {
						yValue = null;
					}

					prevPos = valuePos;
					prevValue = yValue;
				}
				return;
			}
		}

		// If we get here, we had no valid data, show a message stating so
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.clear();
		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(width / 2, height / 2, Gfx.FONT_SMALL, WatchUi.loadResource(Rez.Strings.noData), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER); // TODO Change text to 'No data to show'
	}
}