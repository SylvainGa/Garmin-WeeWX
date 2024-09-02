using Toybox.Application as App;
using Toybox.Background;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi as Ui;
using Toybox.Application.Storage;
using Toybox.Application.Properties;

(:background)
class MyServiceDelegate extends System.ServiceDelegate {
	var _formatStr;
	var _cardinals_array;
	var _history_str;
	//var _timestamp_str;

    function initialize() {
        System.ServiceDelegate.initialize();

        var data = Background.getBackgroundData();
		if (data != null) {
			_history_str = data.get("history");
			//_timestamp_str = data.get("timestamp");

			/*DEBUG*/ logMessage("BG initialize from data - history: " + _history_str);
			//DEBUG*/ logMessage("BG initialize from data - timestamp: " + _timestamp_str);
		}
		else {
			_history_str = Storage.getValue("history");
			//_timestamp_str = Storage.getValue("timestamp");

			/*DEBUG*/ logMessage("BG initialize from Storage - history: " + _history_str);
			//DEBUG*/ logMessage("BG initialize from Storage - timestamp: " + _timestamp_str);
		}

		onSettingsChanged();
    }

	function onSettingsChanged() {
		_formatStr = Properties.getValue("glance");
		_cardinals_array = to_array(Properties.getValue("directions"),",", MAX_SIZE);
	}

    // This fires on our temporal event - we're going to go off and get the vehicle data, only if we have a token and vehicle ID
    function onTemporalEvent() {
		//DEBUG*/ logMessage("BG onTemporalEvent: calling makeRequest for " + Properties.getValue("option_slot1_url"));
		Storage.setValue("title", Properties.getValue("option_slot1_name"));
        makeRequest(Properties.getValue("option_slot1_url"));
        //DEBUG*/ onReceive(200, {"title" => "Station meteo","location" => "Gatineau, Qc, Haut de Labrosse","time" => "03/04/23 22:10:00","lat" => "45&#176; 30.49' N","lon" => "075&#176; 38.41' W","alt" => "102 meters","hardware" => "AcuRite 01036","uptime" => "1938156 seconds","serverUptime" => "1938156 seconds","weewxVersion" => "4.10.2","current" => {"outTemp" => "4.7","windchill" => "4.4","heatIndex" => "3.0","dewpoint" => "-0.9","humidity" => "67","insideHumidity" => "   N/A","barometer" => "1015.6","barometerTrendDelta" => "3 hours","barometerTrendData" => "3.1","windSpeed" => "5","windDir" => "289","windDirText" => "WNW","windGust" => "7","windGustDir" => "   N/A","rainRate" => "0.0","rainRateDaySum" => "0.5","insideTemp" => "20.3","rain" => "0.0"}});
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
			//DEBUG*/ logMessage("BG onReceive: responseCode is " + responseCode);
			//DEBUG*/ logMessage("BG onReceive: data is " + data);
	        if (data instanceof String) { // String is an error message
	            message = data;
	        } else if (data instanceof Dictionary) { // Dictionary is the answer from the web request call
				var current = data["current"];
				var current_time = 	data["time"];
				if (current_time == null) {
					var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
					// 30/08/24 22:35:00
					current_time = now.day.format("%02d") + "/" + now.month.format("%02d") + "/" + (now.year - 2000).format("%02d") + " " + now.hour.format("%02d") + ":" + now.min.format("%02d") + ":" + now.sec.format("%02d");
				}

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

								// If it's the field we take a history of
								if (fields_name[i].equals("outTemp")) {
									// Get what we had before and convert the ';' separated string of values to an array
									if (_history_str != null /*&& _timestamp_str != null*/) {
										var max_size = 288; //Properties.getValue("History_size");
										var history = to_array(_history_str,";", max_size);
										//var timestamp = to_array(_timestamp_str,";", max_size);

										var history_size = history.size();
										//var timestamp_size = timestamp.size();

										// Make sure we act on the smallest array if for some reason they are not the same size
										var array_size = history_size; //(history_size < timestamp_size ? history_size : timestamp_size );

										// If we reached our maximum size, we need to skip the oldest one before converting it back into a string
										var j = (array_size < max_size ? 0 : 1);
										
										var delimiter = "";
										for (_history_str = ""/*, _timestamp_str = ""*/; j < array_size; j++) {
											_history_str += delimiter + history[j];
											//_timestamp_str += delimiter + timestamp[j];
											delimiter = ";";
										}
										_history_str += delimiter + fields[i];
										//_timestamp_str += delimiter + current_time;
									}
									else {
										_history_str = fields[i];
										//_timestamp_str = current_time;
									}
								}
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

		//DEBUG*/ logMessage("BG onReceive: message is '" + message + "'");
		//DEBUG*/ logMessage("BG onReceive: text  is '" + text + "'");
        Background.exit({"text" => text, "message" => message, "history" => _history_str/*, "timestamp" => _timestamp_str*/});
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