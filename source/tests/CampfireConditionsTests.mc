using Toybox.System;
using Toybox.Test;
using Toybox.Time;
using Toybox.Weather;

// Only included by the compiler's -t option.
(:test)
function temperatureUnitsAndMissingData(logger) {
    Test.assertEqual(CampfireConditions.temperatureText(null, System.UNIT_METRIC), "--\u00B0C");
    Test.assertEqual(CampfireConditions.temperatureText(null, System.UNIT_STATUTE), "--\u00B0F");
    Test.assertEqual(CampfireConditions.temperatureText(0, System.UNIT_METRIC), "0\u00B0C");
    Test.assertEqual(CampfireConditions.temperatureText(0, System.UNIT_STATUTE), "32\u00B0F");
    Test.assertEqual(CampfireConditions.temperatureText(-40, System.UNIT_STATUTE), "-40\u00B0F");
    Test.assertEqual(CampfireConditions.temperatureText(-0.6, System.UNIT_METRIC), "-1\u00B0C");
    return true;
}

(:test)
function elevationUnitsAndBelowSeaLevel(logger) {
    Test.assertEqual(CampfireConditions.elevationText(null, System.UNIT_METRIC), "-- m");
    Test.assertEqual(CampfireConditions.elevationText(null, System.UNIT_STATUTE), "-- ft");
    Test.assertEqual(CampfireConditions.elevationText(0, System.UNIT_METRIC), "0 m");
    Test.assertEqual(CampfireConditions.elevationText(-18, System.UNIT_METRIC), "-18 m");
    Test.assertEqual(CampfireConditions.elevationText(123, System.UNIT_STATUTE), "404 ft");
    return true;
}

(:test)
function weatherConditionsAndUnknownValues(logger) {
    Test.assertEqual(CampfireConditions.weatherLabel(Weather.CONDITION_CLEAR), "CLEAR");
    Test.assertEqual(CampfireConditions.weatherLabel(Weather.CONDITION_CLOUDY), "CLOUDY");
    Test.assertEqual(CampfireConditions.weatherLabel(Weather.CONDITION_PARTLY_CLOUDY), "P.CLOUDY");
    Test.assertEqual(CampfireConditions.weatherLabel(Weather.CONDITION_RAIN), "RAIN");
    Test.assertEqual(CampfireConditions.weatherLabel(Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN), "RAIN?");
    Test.assertEqual(CampfireConditions.weatherLabel(null), "N/A");
    Test.assertEqual(CampfireConditions.weatherLabel(Weather.CONDITION_UNKNOWN), "N/A");
    Test.assertEqual(CampfireConditions.weatherLabel(999), "N/A");
    return true;
}

(:test)
function weatherAgeBoundary(logger) {
    var now = new Time.Moment(20000);
    Test.assert(!CampfireConditions.weatherIsStale(null, now));
    Test.assert(!CampfireConditions.weatherIsStale(new Time.Moment(20000), now));
    Test.assert(!CampfireConditions.weatherIsStale(new Time.Moment(12800), now));
    Test.assert(CampfireConditions.weatherIsStale(new Time.Moment(12799), now));
    return true;
}
