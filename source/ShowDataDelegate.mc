using Toybox.WatchUi as Ui;
using Toybox.Timer;
using Toybox.Time;
using Toybox.System;
using Toybox.Communications as Communications;
using Toybox.Cryptography;
using Toybox.Graphics;
using Toybox.Application.Storage;
using Toybox.Application.Properties;

class ShowDataDelegate extends Ui.BehaviorDelegate {
	var _view as ShowDataView;
	
    function initialize(view as ShowDataView) {
		_view = view;
        BehaviorDelegate.initialize();
    }

	function onNextPage() {
		_view._viewOffset += 6;
		if (_view._viewOffset > 12) {
			_view._viewOffset = 12;
		}

		var i;
		for (i = 0; i < 6; i++) {
			if (_view._array[_view._viewOffset + i].length() > 0) {
				break;
			}
		}
		if (i == 6) {
			//DEBUG*/ logMessage("Data at " + _view._viewOffset  + " is empty, not displaying");
			_view._viewOffset -= 6;
		}
	    _view.requestUpdate();
        return true;
	}

	function onPreviousPage() {
		_view._viewOffset -= 6;
		if (_view._viewOffset < 0) {
			_view._viewOffset = 0;
		}
	    _view.requestUpdate();
        return true;
	}

    function onSwipe(swipeEvent) {
    	if (swipeEvent.getDirection() == 3) {
			Ui.popView(Ui.SLIDE_IMMEDIATE);
	        return true;
	    }
	    else if (swipeEvent.getDirection() == 2) { // Up we go!
	    	_view._viewOffset -= 6;
	    	if (_view._viewOffset < 0) {
				_view._viewOffset = 0;
	    	}
	    }	
	    else if (swipeEvent.getDirection() == 0) { // Down we go!
	    	_view._viewOffset += 6;
	    	if (_view._viewOffset > 12) {
				_view._viewOffset = 12;
	    	}

			var i;
			for (i = 0; i < 6; i++) {
				if (_view._array[_view._viewOffset + i].length() > 0) {
					break;
				}
			}
			if (i == 6) {
				//DEBUG*/ logMessage("Data at " + _view._viewOffset  + " is empty, not displaying");
		    	_view._viewOffset -= 6;
			}
	    }	
	    _view.requestUpdate();
        return true;
	}
	
    function onBack() {
		Ui.popView(Ui.SLIDE_IMMEDIATE);
        return true;
    }

    function onTap(click) {
		Ui.popView(Ui.SLIDE_IMMEDIATE);
        return true;
    }
}
