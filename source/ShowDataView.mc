using Toybox.Background;
using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Time;
using Toybox.Application.Storage;
using Toybox.Application.Properties;

class ShowDataView extends Ui.View {
    hidden var _display;
    var _data;
    var _viewOffset;
	var _array;

    // Initial load - show the 'requesting data' string, make sure we don't process touches
    function initialize(data) {
        View.initialize();
        _data = data;
        _viewOffset = 0;

		_array = to_array(_data,"|");
		for (var i = 0; i < _array.size(); i++) {
			if (_array[i] == null) {
				_array[i] = "";
			}
		}
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.ShowScreenLayout(dc));
    }

    function onReceive(args) {
        _display = args;
        Ui.requestUpdate();
    }

    function onUpdate(dc) {
        // We're loading the image layout
        setLayout(Rez.Layouts.ShowScreenLayout(dc));
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        View.onUpdate(dc);

		var lineText = new [6];
		var i;

		// Fill up our line layout
		for (i = 0; i < 6; i++) {
			lineText[i]	= View.findDrawableById("Line" + (i + 1).toString() + "Text");	            
		}

		// Find how many lines to show
		for (i = 0; i < 6 && _viewOffset + i < _array.size(); i++) {
			if (_array[_viewOffset + i] == null) {
				break;
			}
		}
		
		var lineStart = ((6 - i) / 2.0 + 0.5).toNumber(); 

		//DEBUG*/ logMessage("_viewOffset is " + _viewOffset);
		//DEBUG*/ logMessage("Line offset of " + i);
		var j;
		for (i = lineStart, j = 0; j < 6 - lineStart && _viewOffset + j < _array.size(); j++, i++) {
			//DEBUG*/ logMessage("Line " + i + " is " + _array[_viewOffset + j] + " for j=" + j);
	        lineText[i].setText(_array[_viewOffset + j]);
	        lineText[i].draw(dc);
	    }
	}
}
