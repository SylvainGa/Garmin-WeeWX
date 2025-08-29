using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Graphics as Gfx;

class imageDelegate extends Ui.BehaviorDelegate
{
    hidden var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onSelect() {
        var deviceSettings = Sys.getDeviceSettings();
        if (!deviceSettings.phoneConnected) {
            _view.setString("Connect Phone; Try again.");
        }
        else {
            var url = /*"http://static.garmincdn.com/com.garmin/ui/images/logo/garmin_logo_on_w.png";*/ "http://weewx.sylvain-maison.duckdns.org/daywindvec.png";
            var params = null;

            var options = {
                :palette => [
                Gfx.COLOR_WHITE,
                Gfx.COLOR_GREEN,
                Gfx.COLOR_DK_GREEN,
                Gfx.COLOR_LT_GRAY,
                Gfx.COLOR_DK_GRAY,
                Gfx.COLOR_BLACK
                ],
                :maxWidth => 127,
                :maxHeight => 127,
                :dithering => Comm.IMAGE_DITHERING_NONE,
                :packingFormat => Comm.PACKING_FORMAT_PNG
            };

            _view.setString("Requesting...");

            Comm.makeImageRequest(url, params, options, method(:onImageResponse));
        }

        return true;
    }

    function onImageResponse(code, bitmap) {
        if (code == 200) {
            _view.setBitmap(bitmap);
        }
        else {
            _view.setString("Failed, error #" + code);
        }
    }
}
