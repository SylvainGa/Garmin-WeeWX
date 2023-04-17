using Toybox.Graphics as Gfx;
using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Timer as Timer;
using Toybox.Application.Storage;
using Toybox.Application.Properties;

//! View for the home screen
class MessageView extends WatchUi.View {
	var _message;
    var _timerTime;
    var _curPosX;
    var _xDir;
    var _refreshTimer;
    var _scrollStartTimer;
    var _scrollEndTimer;

    //! Constructor
    public function initialize(message, timerTime) {
        _message = message;
    
        if (timerTime != null) {
            _timerTime = timerTime / 50;
        }
        else {
            _timerTime = null;
        }
        _refreshTimer = null;

        View.initialize();
	}

    function onShow() {
        _refreshTimer = new Timer.Timer();
        _refreshTimer.start(method(:refreshView), 50, true);

        _curPosX = null;

        _scrollStartTimer = 0;
        _scrollEndTimer = 0;
    }

    function onHide() {
        if (_refreshTimer) {
            _refreshTimer.stop();
            _refreshTimer = null;
        }
    }

    function refreshView() {
        WatchUi.requestUpdate();
    }

    public function onLayout(dc) as Void {
		//DEBUG*/ logMessage("MessageView:onLayout:Showing main layout");
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.clear();
    }

	function onUpdate(dc) {
		//DEBUG*/ logMessage("MessageView:onUpdate:Showing '" + _message + "'");

        var width = dc.getWidth();
        var height = dc.getHeight();
        var textMaxWidth = dc.getWidth();
        var textWidth = dc.getTextWidthInPixels(_message, Gfx.FONT_SMALL);

        if (_curPosX == null && textWidth > textMaxWidth) {
            //DEBUG*/ logMessage("DC width: " + textMaxWidth + ", text width: " + biggestTextWidth + " for line " + biggestTextWidthIndex);
            //DEBUG*/ logMessage("Showing " + _message);
            _curPosX = 0;
            _scrollEndTimer = 0;
            _scrollStartTimer = 0;
            _xDir = -2;
        }

        if (textWidth > textMaxWidth) {
            if (_scrollStartTimer > 10) {
                _curPosX = _curPosX + _xDir;
                if (_curPosX + textWidth < textMaxWidth) {
                    _xDir = 0;
                    _scrollEndTimer = _scrollEndTimer + 1;
                }
            }
            else {
                _scrollStartTimer = _scrollStartTimer + 1;
            }
        }

		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.clear();
		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);

        if (textWidth <= textMaxWidth) {
    		dc.drawText(width / 2, height / 2, Gfx.FONT_SMALL, _message, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
            _scrollEndTimer = 10; // Don't wait for the end timer to expire before we get out if the message fits on screen
        }
        else {
    		dc.drawText(_curPosX + textWidth / 2, height / 2, Gfx.FONT_SMALL, _message, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
        }

        if (_timerTime != null) {
            _timerTime = _timerTime - 1;
            if (_timerTime <= 0 && _scrollEndTimer == 10) {
                WatchUi.popView(SLIDE_IMMEDIATE);
            }
        }

        if (_scrollEndTimer == 10) {
            _curPosX = null;
            _scrollEndTimer = 0;
            _scrollStartTimer = 0;
        }
	}
}
