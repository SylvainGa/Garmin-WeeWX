using Toybox.Graphics as Gfx;
using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Timer as Timer;
using Toybox.Application.Storage;
using Toybox.Application.Properties;

//! View for the home screen
class MessageView extends WatchUi.View {
	var _width, _height;
	var _message;
    var _timerTime;
    var _timer;

    //! Constructor
    public function initialize(message, timerTime) {
        _message = message;
        _timerTime = timerTime;
        _timer = null;

        View.initialize();

        if (_timerTime != null) {
            _timer = new Timer.Timer();
        }
	}

    function onShow() {
        if (_timer) {
            _timer.start(method(:onTimesUp), _timerTime, false);
        }
    }

    function onHide() {
        if (_timer) {
            _timer.stop();
        }
    }

    function onTimesUp() {
        WatchUi.popView(SLIDE_IMMEDIATE);
    }

    public function onLayout(dc) as Void {
		//DEBUG*/ logMessage("MessageView:onLayout:Showing main layout");
		_width = dc.getWidth();
		_height = dc.getHeight();
    }

	function onUpdate(dc) {
		//DEBUG*/ logMessage("MessageView:onUpdate:Showing '" + _message + "'");
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.clear();
		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(_width / 2, _height / 2, Gfx.FONT_SMALL, _message, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
	}
}
