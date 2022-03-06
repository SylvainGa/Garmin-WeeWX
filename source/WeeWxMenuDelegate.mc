//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.

import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Input handler to respond to main menu selections
class WeeWXMenuDelegate extends WatchUi.BehaviorDelegate {

    //! Constructor
    public function initialize() {
        MenuInputDelegate.initialize();
    }

    public function onTap(item as Symbol) as Void {
System.println("Tap!");
		Application.getApp().setProperty("message", null);
        WatchUi.requestUpdate();
        return true;
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
        } else if (item == :Back) {
			Application.getApp().setProperty("exit", true);
System.println("Back!");
            WatchUi.requestUpdate();
        }
		return true;
    }

    public function onBack() as Void {
		var _message = Application.getApp().getProperty("message");
		if (_message == null) {		 
System.println("message is null in WeeWXMenuDelegate, exiting");
			Application.getApp().setProperty("exit", true);
            WatchUi.requestUpdate();
	    } else {
System.println("message is NOT null in WeeWXMenuDelegate, poping up");
			Application.getApp().setProperty("message", null);
            WatchUi.requestUpdate();
			return true;
	    }
    }
    
   private function makeRequest(url) as Void {
		Application.getApp().setProperty("message", WatchUi.loadResource(Rez.Strings.Awaiting_response));

		var params = {};
		var headers = {
			"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
		};
		var options = {
			:method => Communications.HTTP_REQUEST_METHOD_GET,
			:headers => headers,
			:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
		}; 

		if (Communications has :makeWebRequest ) {
			Communications.makeWebRequest(url, params, options, method(:onReceive));
		}
		else {
			Communications.makeJsonRequest(url, params, options, method(:onReceive));
		}
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
                    var field1_name = Application.getApp().getProperty("field1");
                    var field2_name = Application.getApp().getProperty("field2");
                    var field3_name = Application.getApp().getProperty("field3");
                    var field4_name = Application.getApp().getProperty("field4");
                    var field1 = null, field2 = null, field3 = null, field4 = null;
    
                    if (!(field1_name.toString().equals(""))) {
                        field1 = convert(current[field1_name], field1_name);
System.println(field1_name + " - " + field1);
                    }
                    if (!(field2_name.toString().equals(""))) {
                        field2 = convert(current[field2_name], field2_name);
                    }
                    if (!(field3_name.toString().equals(""))) {
                        field3 = convert(current[field3_name], field3_name);
                    }
                    if (!(field4_name.toString().equals(""))) {
                        field4 = convert(current[field4_name], field4_name);
                    }

					// Need to parse our format string to replace '\' 'n' characters with the real \n follow by a space
					var _formatStr = Application.getApp().getProperty("display");
					var array = _formatStr.toCharArray();
					for (var i = 0; i < _formatStr.length() - 1; i++) {
						if (array[i] == '\\' && array[i + 1] == 'n' ) {
							array[i] = 10.toChar();
							array[i + 1] = ' ';
						}
					}
					_formatStr = StringUtil.charArrayToString(array);

					// _message = Lang.format("$1$\n\nTemp : $2$ C\nVit vent : $3$ KMH\nDir vent : $4$\nRafale : $5$ KMH", [title, field1, field2, field3, field4]);
					_message = Lang.format(_formatStr, [title, field1, field2, field3, field4]);
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
        WatchUi.requestUpdate();
    }

    function convert(value, name) {
System.println(name + " - " + value);
    	if (name.equals("windDir")) {
    		if (value.toNumber() instanceof Lang.Number) {
				var val = (value.toFloat() / 22.5) + .5;
				var arr = toArray(Application.getApp().getProperty("directions"),",");
				return(arr[(val.toNumber() % 16)]);
			}
			else {
				return("N/A");
			}
    	}
    	else {
    		if (value.find(".") != null || value.find(",") != null) {
	    		return (value.toFloat().format("%.1f"));
    		} else {
	    		return (value.toNumber());
    		}
    	}
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
	
	function toArray(string, splitter) {
		var array = new [16]; //Use maximum expected length
		var index = 0;
		var location;

		do {
			location = string.find(splitter);
			if (location != null) {
				array[index] = string.substring(0, location);
				string = string.substring(location + 1, string.length());
				index++;
			}
		} while (location != null);

		array[index] = string;
		
		var result = new [index];
		for (var i = 0; i < index; i++) {
			result = array;
		}
		return result;
	}
}
