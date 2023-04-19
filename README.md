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

One caveat, this app starts with a menu, which is not supported and because of that, when you get out, you'll need an extra Back button or sweep to get out of the blank screen. Couldn't figure out a way to get out of that problem,

What's new: 

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