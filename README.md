# WeeWX
 Get WeeWX data directly from your Garmin watch

Display weather stations data for up to 5 weather stations tied to WeeWX. The WeeWX stations must be accessible through the Internet if you want to query it outside of your home network. You need to input the URL to your daily.json file.

For fields, you can start with these

outTemp
windSpeed
windDir
windGust
windchill
heatindex
humidity

This is an example of the display line for the above fields.

$1$||Temp: $2$ C|Wind speed: $3$ KMH|Wind dir: $4$|Wind gust: $5$ KMH|Wind chill: $6$ KMH|Heat index: $7$ KMH|Humidity: $8$%

The $x$ represent the field number you want to show its value. The $1$ is the title of the station as entered in the slot name. '|' means a new line and is used to separate the fields on screen. $2$ in the example above represent 'outTemp'.

Directions is the wind direction in 22.5 degrees increments. In English, use:

N,NNE,NE,ENE,E,ESE,SE,SSE,S,SSW,SW,WSW,W,WNW,NW,NNW

You can flip up/down to view more data if it doesn't fit on screen

Caveat 1, this app starts with a menu, which is not supported and because of that, when you get out, you'll need an extra Back button or sweep to get out of the blank screen. Couldn't figure out a way to get out of that problem,

Caveat 2, it's designed to be used with the Seasons skin and you need to make some modification to your installation
First, create this file: /etc/weewx/skins/Seasons/daily.json.tmpl
And add to it this content:
#encoding UTF-8
{"title":"Current Values","location":"$station.location","time":"$current.dateTime","lat":"$station.latitude[0]° $station.latitude[1]' $station.latitude[2]","lon":"$station.longitude[0]° $station.longitude[1]' $station.longitude[2]","alt":"$station.altitude","hardware":"$station.hardware","uptime":"$station.uptime","serverUptime":"$station.os_uptime","weewxVersion":"$station.version","current": {"outTemp":"$current.outTemp.formatted","windchill":"$current.windchill.formatted","heatIndex":"$current.heatindex.formatted","dewpoint":"$current.dewpoint.formatted","humidity":"$current.outHumidity.formatted","insideHumidity":"$current.inHumidity.formatted","barometer":"$current.barometer.formatted","barometerTrendDelta":"$trend.time_delta.hour.format("%.0f")","barometerTrendData":"$trend.barometer.formatted","windSpeed":"$current.windSpeed.formatted","windDir":"$current.windDir.formatted","windDirText":"$current.windDir.ordinal_compass","windGust":"$current.windGust.formatted","windGustDir":"$current.windGustDir.formatted","rainRate":"$current.rainRate.formatted","insideTemp":"$current.inTemp.formatted"}}

Now edit this file: /etc/weewx/skins/Seasons/skin.conf
Right after the following block
[CheetahGenerator]
    ....
    [[ToDate]]
        ....
        [[[RSS]]]
            template = rss.xml.tmpl

Add:
[[[json]]]
    template = daily.json.tmpl

That's it. Now either wait for the next iteration of the reports or force one with wee_reports. You can then access the data with http://IP-ADDRESS/weewx/daily.json

Caveat 3: You'll probably need to access your weather station from outside your wifi network, so you'll need to open up the port on your router and get a dynamic DNS provider unless you have a static IP address. I would recommend for security reason that you 'hide' your WeeWX from the internet throught a reverse proxy system. This is something out of the scope of this readme so you'll need to figure out by yourself how to do that, although there are many tutorials available on the Internet on how to set one up. I personnaly use Apache2, LetsEncrypt and DuckDNS.org to secure my installation and have a dns entry for my weewx system.

What's new: 

V0.97.1 
Compiled with CIQ 7.4.3
Added Edges devices

V0.97.0
Compiled with CIQ 7.3.0
Added Enduro 3 and Fenix 8 watches, including the Fenix E
Added a graphic for the outside temperature. Accessed by sliding to the left or pressing the Select button. The interval (by increment of 5 minutes) and the number of data points can be adjusted through the App Settings (max of 2016 or 7 days at interval of 5 minutes). By default, shows the last 24 hours (288 data points) but it must first accunulate those datapoints. A skip in the data is because the background ran but it couldn't get any data. It will NOT account for the time the watch is turned OFF.

V0.96.3
Workaround for a bug that Garmin never fixed

V0.96.2
Optimized Glance code and made the scroll speed more consistent across watches screen resolution
New option to scroll further so the top/bottom edge are cleared

V0.96.1
New algorithm for Glance text vertical placement
Option in Settings to choose a smaller font for Glance text. Could allow a third line of text on some watch
Added a bunch of watches as supported

V0.96.0
Adds scrolling text in Glance view if it's too long to fit the display area

V0.95.1 Oops, forgot scope=background for the french language

V0.95
Adds support for glance view and Forerunner *65 watches

V0.94
Now using '|' as field separator (new line)