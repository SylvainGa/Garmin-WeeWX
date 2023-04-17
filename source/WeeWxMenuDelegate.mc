import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.Application.Storage;
using Toybox.Application.Properties;

//! Input handler to respond to main menu selections
class WeeWXMenuDelegate extends WatchUi.Menu2InputDelegate {

    //! Constructor
    function initialize() {
		//DEBUG*/ logMessage("WeeWXMenuDelegate initializing");
        Menu2InputDelegate.initialize();
    }

    //! Handle a menu item being selected
    //! @param item Symbol identifier of the menu item that was chosen
    public function onSelect(item) {
  		var id=item.getId();
		
		var view = new MessageView(WatchUi.loadResource(Rez.Strings.Awaiting_response), null);
		WatchUi.pushView(view, null, WatchUi.SLIDE_IMMEDIATE);

        if (id == :Item1) {
			Storage.setValue("title", Properties.getValue("option_slot1_name"));
            makeRequest(Properties.getValue("option_slot1_url"), id);
        } else if (id == :Item2) {
			Storage.setValue("title", Properties.getValue("option_slot2_name"));
            makeRequest(Properties.getValue("option_slot2_url"), id);
        } else if (id == :Item3) {
			Storage.setValue("title", Properties.getValue("option_slot3_name"));
            makeRequest(Properties.getValue("option_slot3_url"), id);
        } else if (id == :Item4) {
			Storage.setValue("title", Properties.getValue("option_slot4_name"));
            makeRequest(Properties.getValue("option_slot4_url"), id);
        } else if (id == :Item5) {
			Storage.setValue("title", Properties.getValue("option_slot5_name"));
            makeRequest(Properties.getValue("option_slot5_url"), id);
        }
    }

   private function makeRequest(url, id) as Void {
		var params = {};
		var headers = {
			"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
		};
		var options = {
			:method => Communications.HTTP_REQUEST_METHOD_GET,
			:headers => headers,
			:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
			:context => id
		}; 

		if (Communications has :makeWebRequest ) {
			Communications.makeWebRequest(url, params, options, method(:onReceive));
		}
		else {
			Communications.makeJsonRequest(url, params, options, method(:onReceive));
		}
    }

    public function onReceive(responseCode as Number, data as Dictionary?, id) as Void {
		var message = null;
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);

        if (responseCode == 200) {
			//DEBUG*/ logMessage("data is " + data);
	        if (data instanceof String) { // String is an error message
	            message = data;
	        } else if (data instanceof Dictionary) { // Dictionary is the answer from the web request call
				var current = data["current"];
	
				if (current instanceof Dictionary) {
					// Calculate how many fields of data we have
					var numberOfFields;
					for (numberOfFields = 1; numberOfFields <= 16; numberOfFields++) {
						var field = Properties.getValue("field" + numberOfFields);
						if (field == null || field.length() == 0) {
							break; // We stop at the first blank field
						}
					}

					var fields_name = new [numberOfFields + 1];
					var fields = new [numberOfFields + 1];
					
					fields_name[0] = "Title";
					fields[0] = Storage.getValue("title");

					// Fill in the fields
					for (var i = 1; i <= numberOfFields; i++) {
						fields_name[i] = Properties.getValue("field" + i);
						fields[i] = null;

	                    if ((fields_name[i] != null && fields_name[i].length() > 0)) {
							if (current[fields_name[i]] != null) {
		                        fields[i] = convert(current[fields_name[i]], fields_name[i]);
							}
	                    }
					}

					var _formatStr = Properties.getValue("display");
					if (_formatStr != null) {
						var text = Lang.format(_formatStr, fields);
						
						// Show the data
						var view = new ShowDataView(text);
						var delegate = new ShowDataDelegate(view);
						WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
					}
					else {
		            	message = WatchUi.loadResource(Rez.Strings.BadFormat);
					}

					// Check if it's for our main entry, if so, update its glance with what we received
					if (id == :Item1) {
						_formatStr = Properties.getValue("glance");
						if (_formatStr != null) {
							var text = Lang.format(_formatStr, fields);
							Storage.setValue("text", text);
						}
					}
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
		//DEBUG*/ logMessage(name + " - " + value);
    	if (name.equals("windDir")) {
    		if (value.toNumber() instanceof Lang.Number) {
				var val = (value.toFloat() / 22.5) + .5;
				var arr = to_array(Properties.getValue("directions"),",");
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
	
	// function type_name(obj) {
	//     if (obj instanceof Toybox.Lang.Number) {
	//         return "Number";
	//     } else if (obj instanceof Toybox.Lang.Long) {
	//         return "Long";
	//     } else if (obj instanceof Toybox.Lang.Float) {
	//         return "Float";
	//     } else if (obj instanceof Toybox.Lang.Double) {
	//         return "Double";
	//     } else if (obj instanceof Toybox.Lang.Boolean) {
	//         return "Boolean";
	//     } else if (obj instanceof Toybox.Lang.String) {
	//         return "String";
	//     } else if (obj instanceof Toybox.Lang.Array) {
	//         var s = "Array [";
	//         for (var i = 0; i < obj.size(); ++i) {
	//             s += type_name(obj);
	//             s += ", ";
	//         }
	//         s += "]";
	//         return s;
	//     } else if (obj instanceof Toybox.Lang.Dictionary) {
	//         var s = "Dictionary{";
	//         var keys = obj.keys();
	//         var vals = obj.values();
	//         for (var i = 0; i < keys.size(); ++i) {
	//             s += keys;
	//             s += ": ";
	//             s += vals;
	//             s += ", ";
	//         }
	//         s += "}";
	//         return s;
	//     } else if (obj instanceof Toybox.Time.Gregorian.Info) {
	//         return "Gregorian.Info";
	//     } else {
	//         return "???";
	//     }
	// }
}
