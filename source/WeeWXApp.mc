import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System;
using Toybox.Application.Storage;
using Toybox.Application.Properties;

const MAX_SIZE = 18;

(:background)
class WeeWXApp extends Application.AppBase {

    //! Constructor
    public function initialize() {
		/*DEBUG*/ logMessage("initialize called");
        AppBase.initialize();
    }

    //! Handle app startup
    //! @param state Startup arguments
    public function onStart(state as Dictionary?) as Void {
		/*DEBUG*/ logMessage("onStart called");
    }

    //! Handle app shutdown
    //! @param state Shutdown arguments
    public function onStop(state as Dictionary?) as Void {
    }

    //! Return the initial views for the app
    public function getInitialView() as Array<Views or BehaviorDelegate>? {
		/*DEBUG*/ logMessage("getInitialView called");
    	var view = new $.WeeWXView(); 
        return [view];
    }

    function getServiceDelegate(){
		/*DEBUG*/ logMessage("getServiceDelegate called");
//		Storage.setValue("message", "Waiting for data");
        return [ new MyServiceDelegate() ];
    }

    (:glance)
    function getGlanceView() {
		/*DEBUG*/ logMessage("getGlanceView called");

        Background.registerForTemporalEvent(new Time.Duration(60*5));
        return [ new GlanceView() ];
    }

    function onBackgroundData(data) {
		/*DEBUG*/ logMessage("onBackgroundData received '" + data + "'");
        if (data != null && data instanceof Dictionary) {
			Storage.setValue("message", data.get("message"));
			Storage.setValue("text", data.get("text"));
        }
		else {
			/*DEBUG*/ logMessage("onBackgroundData data not a dictionary: " + data);
		}

        Background.registerForTemporalEvent(new Time.Duration(300));

		/*DEBUG*/ logMessage("onBackgroundData requesting view update");
        WatchUi.requestUpdate();
	}
}

(:background)
function to_array(string, splitter) {
	var array = new [MAX_SIZE]; //Use maximum expected length
	var index = 0;
	var location;

	do {
		location = string.find(splitter);
		if (location != null) {
			array[index] = string.substring(0, location);
			string = string.substring(location + 1, string.length());
			index++;
		}
	} while (location != null && index < MAX_SIZE);

	array[index] = string;
	
	var result = new [index + 1];
	for (var i = 0; i <= index; i++) {
		result[i] = array[i];
	}
	return result;
}


(:debug, :background)
function logMessage(message) {
	var clockTime = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
	var dateStr = clockTime.hour + ":" + clockTime.min.format("%02d") + ":" + clockTime.sec.format("%02d");
	System.println(dateStr + " : " + message);
}

(:release, :background)
function logMessage(output) {
}

(:background)
var errorsStr = {
	"0" => "UNKNOWN_ERROR",
	"-1" => "BLE_ERROR",
	"-2" => "BLE_HOST_TIMEOUT",
	"-3" => "BLE_SERVER_TIMEOUT",
	"-4" => "BLE_NO_DATA",
	"-5" => "BLE_REQUEST_CANCELLED",
	"-101" => "BLE_QUEUE_FULL",
	"-102" => "BLE_REQUEST_TOO_LARGE",
	"-103" => "BLE_UNKNOWN_SEND_ERROR",
	"-104" => "BLE_CONNECTION_UNAVAILABLE",
	"-200" => "INVALID_HTTP_HEADER_FIELDS_IN_REQUEST",
	"-201" => "INVALID_HTTP_BODY_IN_REQUEST",
	"-202" => "INVALID_HTTP_METHOD_IN_REQUEST",
	"-300" => "NETWORK_REQUEST_TIMED_OUT",
	"-400" => "INVALID_HTTP_BODY_IN_NETWORK_RESPONSE",
	"-401" => "INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE",
	"-402" => "NETWORK_RESPONSE_TOO_LARGE",
	"-403" => "NETWORK_RESPONSE_OUT_OF_MEMORY",
	"-1000" => "STORAGE_FULL",
	"-1001" => "SECURE_CONNECTION_REQUIRED",
	"-1002" => "UNSUPPORTED_CONTENT_TYPE_IN_RESPONSE",
	"-1003" => "REQUEST_CANCELLED",
	"-1004" => "REQUEST_CONNECTION_DROPPED",
	"-1005" => "UNABLE_TO_PROCESS_MEDIA",
	"-1006" => "UNABLE_TO_PROCESS_IMAGE",
	"-1007" => "UNABLE_TO_PROCESS_HLS",
	"400" => "Bad_Request",
	"401" => "Unauthorized",
	"402" => "Payment_Required",
	"403" => "Forbidden",
	"404" => "Not_Found",
	"405" => "Method_Not_Allowed",
	"406" => "Not_Acceptable",
	"407" => "Proxy_Authentication_Required",
	"408" => "Request_Timeout",
	"409" => "Conflict",
	"410" => "Gone",
	"411" => "Length_Required",
	"412" => "Precondition_Failed",
	"413" => "Request_Too_Large",
	"414" => "Request-URI_Too_Long",
	"415" => "Unsupported_Media_Type",
	"416" => "Range_Not_Satisfiable",
	"417" => "Expectation_Failed",
	"500" => "Internal_Server_Error",
	"501" => "Not_Implemented",
	"502" => "Bad_Gateway",
	"503" => "Service_Unavailable",
	"504" => "Gateway_Timeout",
	"505" => "HTTP_Version_Not_Supported",
	"511" => "Network_Authentication_Required",
	"540" => "Vehicle_Server_Error"
};
