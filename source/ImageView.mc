using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Graphics as Gfx;

class imageView extends Ui.View
{
    hidden var _string;
    hidden var _bitmap;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        var deviceSettings = Sys.getDeviceSettings();

        if (!deviceSettings.phoneConnected) {
            _string = "Connect Phone";
        }
        else if (deviceSettings.isTouchScreen) {
            _string = "Tap Screen";
        }
        else {
            _string = "Press Enter/Start";
        }
    }

    function setBitmap(bitmap) {
        _bitmap = bitmap;
        _string = null;
        Ui.requestUpdate();
    }

    function setString(string) {
        _string = string;
        _bitmap = null;
        Ui.requestUpdate();
    }

    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();

        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;


        if (_bitmap != null) {
            cx -= _bitmap.getWidth() / 2;
            cy -= _bitmap.getHeight() / 2;

            dc.drawBitmap(cx, cy, _bitmap);
        }
        else if (_string != null) {
            dc.drawText(cx, cy, Gfx.FONT_SMALL,
            _string,
            Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
        }
    }
}