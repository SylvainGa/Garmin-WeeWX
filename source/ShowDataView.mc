using Toybox.Background;
using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Time;

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

		_array = to_array(_data,"\n");
		for (var i = 0; i < 18; i++) {
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
		
		for (i = 1; i < 7; i++) {
			lineText[i - 1]	= View.findDrawableById("Line" + i + "Text");	            
		}
		
		// Find how many lines to show
		for (i = 5; i > 0; --i) {
			if (_array[_viewOffset + i].equals("") != true) {
				break;
			}
		}

		var lineStart = (6 - i) / 2; 

logMessage("_viewOffset is " + _viewOffset);
logMessage("Line offset of " + i);
		var j;
		for (i = lineStart, j = 0; j < 6 - lineStart; j++, i++) {
logMessage("Line " + i + " is " + _array[_viewOffset + j] + " for j=" + j);
	        lineText[i].setText(_array[_viewOffset + j]);
	        lineText[i].draw(dc);
	    }
	}
}
