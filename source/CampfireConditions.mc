using Toybox.Lang;
using Toybox.Math;
using Toybox.System;
using Toybox.Time;
using Toybox.Weather;

// Garmin's weather values are Celsius; elevation samples are meters.
// Keep conversion and null handling independent from drawing and sensor access.
module CampfireConditions {
    function temperatureText(celsius, units) {
        var suffix = units == System.UNIT_STATUTE ? "\u00B0F" : "\u00B0C";
        if (celsius == null) { return "--" + suffix; }
        var value = units == System.UNIT_STATUTE ? celsius * 1.8 + 32 : celsius;
        return Math.round(value).toNumber().format("%d") + suffix;
    }

    function elevationText(meters, units) {
        var suffix = units == System.UNIT_STATUTE ? " ft" : " m";
        if (meters == null) { return "--" + suffix; }
        var value = units == System.UNIT_STATUTE ? meters * 3.28084 : meters;
        return Math.round(value).toNumber().format("%d") + suffix;
    }

    function weatherIsStale(observedAt, now) {
        // Do not present old conditions as current after a long disconnection.
        return observedAt != null && now.value() - observedAt.value() > 7200;
    }

    function weatherLabel(condition) {
        if (condition == null) { return "N/A"; }
        switch (condition) {
            case Weather.CONDITION_CLEAR:
            case Weather.CONDITION_MOSTLY_CLEAR:
            case Weather.CONDITION_FAIR:
                return "CLEAR";
            case Weather.CONDITION_PARTLY_CLOUDY:
            case Weather.CONDITION_PARTLY_CLEAR:
            case Weather.CONDITION_THIN_CLOUDS:
                return "P.CLOUDY";
            case Weather.CONDITION_MOSTLY_CLOUDY:
            case Weather.CONDITION_CLOUDY:
                return "CLOUDY";
            case Weather.CONDITION_RAIN:
            case Weather.CONDITION_LIGHT_RAIN:
            case Weather.CONDITION_HEAVY_RAIN:
                return "RAIN";
            case Weather.CONDITION_SCATTERED_SHOWERS:
            case Weather.CONDITION_LIGHT_SHOWERS:
            case Weather.CONDITION_SHOWERS:
            case Weather.CONDITION_HEAVY_SHOWERS:
                return "SHOWERS";
            case Weather.CONDITION_CHANCE_OF_SHOWERS:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN:
                return "RAIN?";
            case Weather.CONDITION_SNOW:
            case Weather.CONDITION_LIGHT_SNOW:
            case Weather.CONDITION_HEAVY_SNOW:
            case Weather.CONDITION_FLURRIES:
                return "SNOW";
            case Weather.CONDITION_CHANCE_OF_SNOW:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW:
                return "SNOW?";
            case Weather.CONDITION_WINTRY_MIX:
            case Weather.CONDITION_LIGHT_RAIN_SNOW:
            case Weather.CONDITION_HEAVY_RAIN_SNOW:
            case Weather.CONDITION_RAIN_SNOW:
                return "MIXED";
            case Weather.CONDITION_CHANCE_OF_RAIN_SNOW:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW:
                return "MIXED?";
            case Weather.CONDITION_WINDY: return "WINDY";
            case Weather.CONDITION_THUNDERSTORMS:
            case Weather.CONDITION_SCATTERED_THUNDERSTORMS:
            case Weather.CONDITION_HURRICANE:
            case Weather.CONDITION_TROPICAL_STORM:
                return "STORM";
            case Weather.CONDITION_CHANCE_OF_THUNDERSTORMS: return "STORM?";
            case Weather.CONDITION_FOG: return "FOG";
            case Weather.CONDITION_MIST: return "MIST";
            case Weather.CONDITION_HAZY:
            case Weather.CONDITION_HAZE:
                return "HAZE";
            case Weather.CONDITION_HAIL: return "HAIL";
            case Weather.CONDITION_DRIZZLE: return "DRIZZLE";
            case Weather.CONDITION_TORNADO: return "TORNADO";
            case Weather.CONDITION_SMOKE: return "SMOKE";
            case Weather.CONDITION_ICE: return "ICE";
            case Weather.CONDITION_FREEZING_RAIN: return "ICE/RAIN";
            case Weather.CONDITION_SLEET: return "SLEET";
            case Weather.CONDITION_ICE_SNOW: return "ICE/SNOW";
            case Weather.CONDITION_DUST: return "DUST";
            case Weather.CONDITION_SAND:
            case Weather.CONDITION_SANDSTORM:
                return "SAND";
            case Weather.CONDITION_SQUALL: return "SQUALL";
            case Weather.CONDITION_VOLCANIC_ASH: return "ASH";
            case Weather.CONDITION_UNKNOWN_PRECIPITATION: return "PRECIP";
            default: return "N/A";
        }
    }
}
