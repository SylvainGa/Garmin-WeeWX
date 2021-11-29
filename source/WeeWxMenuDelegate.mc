//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.

import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Input handler to respond to main menu selections
class WeeWXMenuDelegate extends WatchUi.MenuInputDelegate {

    //! Constructor
    public function initialize() {
        MenuInputDelegate.initialize();
    }

    //! Handle a menu item being selected
    //! @param item Symbol identifier of the menu item that was chosen
    public function onMenuItem(item as Symbol) as Void {
        if (item == :Item1) {
			Application.getApp().setProperty("title", Application.getApp().getProperty("option_slot1_name"));
            makeRequest(Application.getApp().getProperty("option_slot1_url"));
        } else if (item == :Item2) {
			Application.getApp().setProperty("title", Application.getApp().getProperty("option_slot2_name"));
            makeRequest(Application.getApp().getProperty("option_slot2_url"));
        } else if (item == :Item3) {
			Application.getApp().setProperty("title", Application.getApp().getProperty("option_slot3_name"));
            makeRequest(Application.getApp().getProperty("option_slot3_url"));
        } else if (item == :Item4) {
			Application.getApp().setProperty("title", Application.getApp().getProperty("option_slot4_name"));
            makeRequest(Application.getApp().getProperty("option_slot4_url"));
        } else if (item == :Item5) {
			Application.getApp().setProperty("title", Application.getApp().getProperty("option_slot5_name"));
            makeRequest(Application.getApp().getProperty("option_slot5_url"));
        }
    }

    private function makeRequest(url) as Void {
        Application.getApp().setProperty("url", null);
		Application.getApp().setProperty("message", WatchUi.loadResource(Rez.Strings.Awaiting_response));

        var options = {
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
            }
        };

        Communications.makeWebRequest(
            url,
            {},
            options,
            method(:onReceive)
        );
    }

    public function onReceive(responseCode as Number, data as Dictionary?) as Void {
    	var _message = null;
        if (responseCode == 200) {
	        if (data instanceof String) {
	            _message = data;
	        } else if (data instanceof Dictionary) {
				var current = data["current"];
	
				if (current instanceof Dictionary) {
					var title = Application.getApp().getProperty("title");
/*                    var field1_name = Application.getApp().getProperty("field1");
                    var field2_name = Application.getApp().getProperty("field2");
                    var field3_name = Application.getApp().getProperty("field3");
                    var field4_name = Application.getApp().getProperty("field4");
                    var field1 = null, field2 = null, field3 = null, field4 = null;
                    if (field1_name) {
                        field1 = current[field1_name].toNumber();
                    }
                    if (field2_name) {
                        field2 = current[field2_name].toNumber();
                    }
                    if (field3_name) {
                        field3 = current[field3_name].toNumber();
                    }
                    if (field4_name) {
                        field4 = current[field4_name].toNumber();
                    }
*/		 			var outTemp = current["outTemp"];
		 			var windSpeed = current["windSpeed"];
		 			var windDir = current["windDir"].toNumber();
		 			if (windDir instanceof Lang.Number) {
						var val = (windDir.toFloat() / 22.5) + .5;
						var arr = ["N","NNE","NE","ENE","E","ESE", "SE", "SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"];
						windDir = arr[(val.toNumber() % 16)];
					}
					else {
						windDir = "N/A";
					}
					_message = Lang.format(WatchUi.loadResource(Rez.Strings.Answer), [title, outTemp, windSpeed, windDir]);
				}
				else {
		            _message = WatchUi.loadResource(Rez.Strings.NoCurrentValue);
				}
	        }
        }
        else {
            var errorStr = "";
            if (data) {
            	errorStr = data.get("error");
            }
            _message = WatchUi.loadResource(Rez.Strings.FailedToRead) + responseCode.toString() + " " + errorStr;
        }

		Application.getApp().setProperty("message", _message);
        requestUpdate();
    }

function type_name(obj) {
    if (obj instanceof Toybox.Lang.Number) {
        return "Number";
    } else if (obj instanceof Toybox.Lang.Long) {
        return "Long";
    } else if (obj instanceof Toybox.Lang.Float) {
        return "Float";
    } else if (obj instanceof Toybox.Lang.Double) {
        return "Double";
    } else if (obj instanceof Toybox.Lang.Boolean) {
        return "Boolean";
    } else if (obj instanceof Toybox.Lang.String) {
        return "String";
    } else if (obj instanceof Toybox.Lang.Array) {
        var s = "Array [";
        for (var i = 0; i < obj.size(); ++i) {
            s += type_name(obj);
            s += ", ";
        }
        s += "]";
        return s;
    } else if (obj instanceof Toybox.Lang.Dictionary) {
        var s = "Dictionary{";
        var keys = obj.keys();
        var vals = obj.values();
        for (var i = 0; i < keys.size(); ++i) {
            s += keys;
            s += ": ";
            s += vals;
            s += ", ";
        }
        s += "}";
        return s;
    } else if (obj instanceof Toybox.Time.Gregorian.Info) {
        return "Gregorian.Info";
    } else {
        return "???";
    }
}
}
