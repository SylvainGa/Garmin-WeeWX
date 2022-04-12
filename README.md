# WeeWX
 Get WeeWX data directly from your Garmin watch

Display weather stations data for up to 5 weather stations tied to WeeWX. The WeeWX stations must be accessible through the Internet if you want to query it outside of your home network. You need to input the URL to your daily.json file.

For fields, you can start with these

outTemp

windSpeed

windDir

windGust

This is an example of the display line for the above fields.

$1$\n\nTemp: $2$ C\nWind speed: $3$ KMH\nWind dir: $4$\nWind gust: $5$ KMH\nWind chill: $6$ KMH\nHeat index: $7$ KMH\nHumidity: $8$%\n

The $x$ represent the field number you want to show its value. The $1$ is the title of the station as entered in the slot name. '\n' means a new line and is used to separate the fields on screen. $2$ in the example above represent 'outTemp'.

Directions is the wind direction in 22.5 degrees increments. In English, use:

N,NNE,NE,ENE,E,ESE,SE,SSE,S,SSW,SW,WSW,W,WNW,NW,NNW

You can flip up/down to view more data if it doesn't fit on screen

One caveat, this app starts with a menu, which is not supported and because of that, when you get out, you'll need an extra Back button or sweep to get out of the blank screen. Couldn't figure out a way to get out of that problem,
