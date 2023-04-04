//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.

import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Input handler to respond to main menu selections
class WeeWXMenuDelegate extends WatchUi.Menu2InputDelegate {

    //! Constructor
    function initialize() {
		logMessage("WeeWXMenuDelegate initializing");
        Menu2InputDelegate.initialize();
    }

    //! Handle a menu item being selected
    //! @param item Symbol identifier of the menu item that was chosen
    public function onSelect(item) {
  		var id=item.getId();
		
		var view = new MessageView(WatchUi.loadResource(Rez.Strings.Awaiting_response), null);
		WatchUi.pushView(view, null, WatchUi.SLIDE_IMMEDIATE);

        if (id == :Item1) {
			Application.getApp().setProperty("title", Application.getApp().getProperty("option_slot1_name"));
            makeRequest(Application.getApp().getProperty("option_slot1_url"));
        } else if (id == :Item2) {
			Application.getApp().setProperty("title", Application.getApp().getProperty("option_slot2_name"));
            makeRequest(Application.getApp().getProperty("option_slot2_url"));
        } else if (id == :Item3) {
			Application.getApp().setProperty("title", Application.getApp().getProperty("option_slot3_name"));
            makeRequest(Application.getApp().getProperty("option_slot3_url"));
        } else if (id == :Item4) {
			Application.getApp().setProperty("title", Application.getApp().getProperty("option_slot4_name"));
            makeRequest(Application.getApp().getProperty("option_slot4_url"));
        } else if (id == :Item5) {
			Application.getApp().setProperty("title", Application.getApp().getProperty("option_slot5_name"));
            makeRequest(Application.getApp().getProperty("option_slot5_url"));
        }
    }

   private function makeRequest(url) as Void {
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
		var message = null;
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);

        if (responseCode == 200) {
			logMessage("data is " + data);
	        if (data instanceof String) { // String is an error message
	            message = data;
	        } else if (data instanceof Dictionary) { // Dictionary is the answer from the web request call
				var current = data["current"];
	
				if (current instanceof Dictionary) {
					// Calculate how many fields of data we have
					var numberOfFields;
					for (numberOfFields = 1; numberOfFields <= 16; numberOfFields++) {
						var field = Application.getApp().getProperty("field" + numberOfFields);
						if (field == null || field.equals("") == true) {
							break;
						}
					}
					var fields_name = new [numberOfFields + 1];
					var fields = new [numberOfFields + 1];
					
					fields_name[0] = "Title";
					fields[0] = Application.getApp().getProperty("title");

					// Fill in the fields
					for (var i = 1; i <= numberOfFields; i++) {
						fields_name[i] = Application.getApp().getProperty("field" + i);
						fields[i] = null;

	                    if (!(fields_name[i].toString().equals(""))) {
							if (current[fields_name[i]] != null) {
		                        fields[i] = convert(current[fields_name[i]], fields_name[i]);
							}
	                    }
					}

					// Need to parse our format string to replace '\' 'n' characters with the real \n follow by a space
					var _formatStr = Application.getApp().getProperty("display");
/*					var array = _formatStr.toCharArray();
					for (var i = 0; i < _formatStr.length() - 1; i++) {
						if (array[i] == '\\' && array[i + 1] == 'n' ) {
							array[i] = 10.toChar();
							array[i + 1] = ' ';
						}
					}
					
					// Build the strings to display
					_formatStr = StringUtil.charArrayToString(array);
*/					var text = Lang.format(_formatStr, fields);
					
					// Push the data
		            var view = new ShowDataView(text);
		            var delegate = new ShowDataDelegate(view);
		            WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);

				}
				else {
		            message = WatchUi.loadResource(Rez.Strings.NoCurrentValue);
				}
	        }
        }
        else {
            var errorStr = "";
            if (data) {
            	errorStr = data.get("error");
            }
            message = WatchUi.loadResource(Rez.Strings.FailedToRead) + responseCode.toString() + " " + errorStr;
        }

		if (message != null) {
			var view = new MessageView(message, 2000);
			WatchUi.pushView(view, null, WatchUi.SLIDE_IMMEDIATE);
		}
    }

    function convert(value, name) {
		logMessage(name + " - " + value);
    	if (name.equals("windDir")) {
    		if (value.toNumber() instanceof Lang.Number) {
				var val = (value.toFloat() / 22.5) + .5;
				var arr = to_array(Application.getApp().getProperty("directions"),",");
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
}
