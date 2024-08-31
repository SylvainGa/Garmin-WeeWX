using Toybox.Application as App;
using Toybox.Background;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi as Ui;
using Toybox.Application.Storage;
using Toybox.Application.Properties;

(:background)
class MyServiceDelegate extends System.ServiceDelegate {
	var _formatStr;
	var _cardinals_array;

    function initialize() {
        System.ServiceDelegate.initialize();

		onSettingsChanged();
    }

	function onSettingsChanged() {
		_formatStr = Properties.getValue("glance");
		_cardinals_array = to_array(Properties.getValue("directions"),",");
	}

    // This fires on our temporal event - we're going to go off and get the vehicle data, only if we have a token and vehicle ID
    function onTemporalEvent() {
		//DEBUG*/ logMessage("onTemporalEvent: calling makeRequest for " + Properties.getValue("option_slot1_url"));
		Storage.setValue("title", Properties.getValue("option_slot1_name"));
        makeRequest(Properties.getValue("option_slot1_url"));
        //DEBUG*/onReceive(200, {"title" => "Station meteo","location" => "Gatineau, Qc, Haut de Labrosse","time" => "03/04/23 22:10:00","lat" => "45&#176; 30.49' N","lon" => "075&#176; 38.41' W","alt" => "102 meters","hardware" => "AcuRite 01036","uptime" => "1938156 seconds","serverUptime" => "1938156 seconds","weewxVersion" => "4.10.2","current" => {"outTemp" => "4.7","windchill" => "4.4","heatIndex" => "3.0","dewpoint" => "-0.9","humidity" => "67","insideHumidity" => "   N/A","barometer" => "1015.6","barometerTrendDelta" => "3 hours","barometerTrendData" => "3.1","windSpeed" => "5","windDir" => "289","windDirText" => "WNW","windGust" => "7","windGustDir" => "   N/A","rainRate" => "0.0","rainRateDaySum" => "0.5","insideTemp" => "20.3","rain" => "0.0"}});
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

    public function onReceive(responseCode, data) as Void {
		var message = null;
		var text = null;

		if (responseCode == 200) {
			//DEBUG*/ logMessage("background onReceive: responseCode is " + responseCode);
			//DEBUG*/ logMessage("background onReceive: data is " + data);
	        if (data instanceof String) { // String is an error message
	            message = data;
	        } else if (data instanceof Dictionary) { // Dictionary is the answer from the web request call
				var current = data["current"];
	
				if (current instanceof Dictionary) {
					// Calculate how many fields of data we have
					var numberOfFields;
					for (numberOfFields = 1; numberOfFields <= 16; numberOfFields++) {
						var field = Properties.getValue("field" + numberOfFields);
						if (field == null || field.toString().length() == 0) {
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

					if (_formatStr != null) {
						text = Lang.format(_formatStr, fields);
					}
					else {
		            	message = WatchUi.loadResource(Rez.Strings.BadFormat);
					}
				}
				else {
		            message = App.loadResource(Rez.Strings.NoCurrentValue);
				}
	        }
        }
        else {
            var errorStr = "";
            if (data) {
            	errorStr = data.get("error");
            }
            message = App.loadResource(Rez.Strings.FailedToRead) + responseCode.toString() + " " + errorStr;
        }

		//DEBUG*/ logMessage("background onReceive: message is '" + message + "'");
		//DEBUG*/ logMessage("background onReceive: text  is '" + text + "'");
        Background.exit({"text" => text, "message" => message});
    }

    function convert(value, name) {
		//DEBUG*/ logMessage(name + " - " + value);
    	if (name.equals("windDir")) {
    		if (value.toNumber() instanceof Lang.Number) {
				var val = (value.toFloat() / 22.5) + .5;
				return(_cardinals_array[(val.toNumber() % 16)]);
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
	
// 	function type_name(obj) {
// 	    if (obj instanceof Toybox.Lang.Number) {
// 	        return "Number";
// 	    } else if (obj instanceof Toybox.Lang.Long) {
// 	        return "Long";
// 	    } else if (obj instanceof Toybox.Lang.Float) {
// 	        return "Float";
// 	    } else if (obj instanceof Toybox.Lang.Double) {
// 	        return "Double";
// 	    } else if (obj instanceof Toybox.Lang.Boolean) {
// 	        return "Boolean";
// 	    } else if (obj instanceof Toybox.Lang.String) {
// 	        return "String";
// 	    } else if (obj instanceof Toybox.Lang.Array) {
// 	        var s = "Array [";
// 	        for (var i = 0; i < obj.size(); ++i) {
// 	            s += type_name(obj);
// 	            s += ", ";
// 	        }
// 	        s += "]";
// 	        return s;
// 	    } else if (obj instanceof Toybox.Lang.Dictionary) {
// 	        var s = "Dictionary{";
// 	        var keys = obj.keys();
// 	        var vals = obj.values();
// 	        for (var i = 0; i < keys.size(); ++i) {
// 	            s += keys;
// 	            s += ": ";
// 	            s += vals;
// 	            s += ", ";
// 	        }
// 	        s += "}";
// 	        return s;
// 	    } else if (obj instanceof Toybox.Time.Gregorian.Info) {
// 	        return "Gregorian.Info";
// 	    } else {
// 	        return "???";
// 	    }
// 	}
}