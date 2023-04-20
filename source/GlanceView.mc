using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application.Storage;
using Toybox.Application.Properties;

(:glance)
class GlanceView extends Ui.GlanceView {
    var _curPos1X;
    var _curPos2X;
    var _curPos3X;
    var _xDir1;
    var _xDir2;
    var _xDir3;
    var _refreshTimer;
    var _scrollStartTimer;
    var _scrollEndTimer;
    var _prevText1Width;
    var _prevText2Width;
    var _prevText3Width;
    var _usingFont;
    var _fontHeight;
    var _dcWidth;
    var _dcHeight;
    var _threeLines;
    var _steps;

    function initialize() {
        GlanceView.initialize();
    }

	function onShow() {
        _refreshTimer = new Timer.Timer();
        _refreshTimer.start(method(:refreshView), 50, true);
        resetSavedPosition();
	}

    function onLayout(dc) {
        gSettingsChanged = false;

        _usingFont = (Properties.getValue("smallfontsize") ? Graphics.FONT_XTINY : Graphics.FONT_TINY);
        _fontHeight = Graphics.getFontHeight(_usingFont);
        _dcHeight = dc.getHeight();

        if (_dcHeight / _fontHeight >= 3.0) {
            _threeLines = true;
        }
        else {
            _threeLines = false;
        }

        var screenShape = System.getDeviceSettings().screenShape;
        _dcWidth = dc.getWidth();
        if (screenShape == System.SCREEN_SHAPE_ROUND && Properties.getValue("scrollclearsedge") == true) {
            var ratio = 1.0 + (System.getDeviceSettings().screenWidth < 454 ? Math.sqrt((454 - System.getDeviceSettings().screenWidth).toFloat() / 2800.0) : 0.0); // Convoluted way to adjust the width based on the screen width relative to a 454 watch, which shows ok with just the formula below 
            var rad = Math.asin(_dcHeight.toFloat() * (_threeLines ? ratio : 1.0) / _dcWidth.toFloat());
            _dcWidth = (Math.cos(rad) * _dcWidth.toFloat()).toNumber();
        }
        _steps = ((System.getDeviceSettings().screenWidth - 200).toFloat() / 50.0 + 0.5).toNumber();
        if (_steps < 1) {
            _steps = 1;
        }

        resetSavedPosition();
    }
	
	function onHide() {
        if (_refreshTimer) {
            _refreshTimer.stop();
            _refreshTimer = null;
        }
	}

    function resetSavedPosition() {
        _curPos1X = null;
        _curPos2X = null;
        _curPos3X = null;
        _prevText1Width = 0;
        _prevText2Width = 0;
        _prevText3Width = 0;

        _scrollStartTimer = 0;
        _scrollEndTimer = 0;
    }

	function refreshView() {
        Ui.requestUpdate();
	}

    function onUpdate(dc) {
        if (gSettingsChanged) {
            onLayout(dc);
        }

        var message = Storage.getValue("message");
        var text = Storage.getValue("text");
        var textExtra;
        var title = "WeeWX";

		//DEBUG*/ logMessage("onUpdate: message is '" + message + "'");
		//DEBUG*/ logMessage("onUpdate: text is '" + text + "'");

        if (text != null) {
            var array = to_array(text,"|");
            //DEBUG*/ logMessage("onUpdate: array size is " + array.size());
            if (array.size() > 0) {
                for (var i = 0; i < array.size(); i++) {
                    if (array[i] == null) {
                        array[i] = "";
                    }
                }
                title = array[0];
                text = array[2];
                if (_threeLines == true && array.size() > 3) {
                    textExtra = array[3];
                }
            }

            //DEBUG*/ logMessage("onUpdate: array is " + array);
        }
        else {
            text = message; // We're displaying a error
        }

        if (text == null) {
            text = "";
        }
        var text1Width = dc.getTextWidthInPixels(title, _usingFont);
        var text2Width = dc.getTextWidthInPixels(text, _usingFont);
        var text3Width = (textExtra != null ? dc.getTextWidthInPixels(textExtra, _usingFont) : 0);

        var longestTextWidth = text1Width;
        var longestTextWidthIndex = 1;
        if (longestTextWidth < text2Width) {
            longestTextWidth = text2Width;
            longestTextWidthIndex = 2;
        }
        if (longestTextWidth < text3Width) {
            longestTextWidthIndex = 3;
            longestTextWidth = text3Width;
        }

        if (_curPos1X == null || _prevText1Width != text1Width) {
            //DEBUG*/ logMessage("DC width/height: " + _dcWidth + "/" + _dcHeight + " resetPos: " + resetPos + " longest text width: " + longestTextWidth + " for line #" + longestTextWidthIndex);
            //DEBUG*/ logMessage("Showing " + title + " | " +  text + " | " + textExtra);
            _curPos1X = 0;
            _prevText1Width = text1Width;
            _scrollEndTimer = 0;
            _scrollStartTimer = 0;
            if (text1Width > _dcWidth) {
                _xDir1 = _steps;
            }
            else {
                _xDir1 = 0;
            }
        }
        if (_curPos2X == null || _prevText2Width != text2Width) {
            _curPos2X = 0;
            _prevText2Width = text2Width;
            _scrollEndTimer = 0;
            _scrollStartTimer = 0;
            if (text2Width > _dcWidth) {
                _xDir2 = _steps;
            }
            else {
                _xDir2 = 0;
            }
        }
        if (_curPos3X == null || _prevText3Width != text3Width) {
            _curPos3X = 0;
            _prevText3Width = text3Width;
            _scrollEndTimer = 0;
            _scrollStartTimer = 0;
            if (text3Width > _dcWidth) {
                _xDir3 = _steps;
            }
            else {
                _xDir3 = 0;
            }
        }

        if (text1Width > _dcWidth || text2Width > _dcWidth || text3Width > _dcWidth) {
            if (_scrollStartTimer > 20) {
                _curPos1X = _curPos1X - _xDir1;
                _curPos2X = _curPos2X - _xDir2;
                _curPos3X = _curPos3X - _xDir3;

                if (_curPos1X + text1Width < _dcWidth) {
                    _xDir1 = 0;
                    if (longestTextWidthIndex == 1) {
                        _scrollEndTimer = _scrollEndTimer + 1;              
                    }
                }
                if (_curPos2X + text2Width < _dcWidth) {
                    _xDir2 = 0;
                    if (longestTextWidthIndex == 2) {
                        _scrollEndTimer = _scrollEndTimer + 1;              
                    }
                }
                if (_curPos3X + text3Width < _dcWidth) {
                    if (longestTextWidthIndex == 3) {
                        _scrollEndTimer = _scrollEndTimer + 1;              
                    }
                    _xDir3 = 0;
                }
            }
            else {
                _scrollStartTimer = _scrollStartTimer + 1;
            }
        }

        // Draw the two rows of text on the glance widget
        dc.setColor(Gfx.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var spacing;
        if (textExtra != null && _threeLines == true) {
            spacing = ((_dcHeight - _fontHeight * 3) / 4).toNumber();

        }
        else {
            spacing = ((_dcHeight - _fontHeight * 2) / 3).toNumber();
        }

        var y = spacing;
        dc.drawText(
            _curPos1X,
            y,
            _usingFont,
            title,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        y = (spacing * 2 + _fontHeight).toNumber();
        dc.drawText(
            _curPos2X,
            y,
            _usingFont,
            text,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        if (textExtra != null) {
            y = (spacing * 3 + _fontHeight * 2).toNumber();
            dc.drawText(
                _curPos3X,
                y,
                _usingFont,
                textExtra,
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }

        if (_scrollEndTimer == 20) {
            _curPos1X = null;
            _curPos2X = null;
            _curPos3X = null;

            _scrollEndTimer = 0;
            _scrollStartTimer = 0;
        }
    }
}
