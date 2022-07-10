import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/forecast.dart';
import 'package:weather_app/models/weather.dart';

class WeatherApiClient {
  Future<Weather> fetchCurrentWeather({required String lat,required String lon}) async {
    String apiKey = "a4c9925585e92cd21138bd7aa14465e5";
    final weatherUrl = Uri.parse('https://api.openweathermap.org/data/2.5/weather?units=imperial&lat=$lat&lon=$lon&appid=$apiKey');
    final weatherResponse = await http.get(weatherUrl);

    if (weatherResponse.statusCode != 200) {
      throw Exception('error getting weather for location');
    }

    final weatherJson = jsonDecode(weatherResponse.body);
    return Weather.fromJson(weatherJson);
  }

  Future<Forecast> fetchForecastWeather({required String lat,required String lon}) async {
    String apiKey = "a4c9925585e92cd21138bd7aa14465e5";
    print("EHHLL apiKey ${"https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&appid=$apiKey&units='metric'"}");
    final weatherForecastUrl = Uri.parse("https://api.openweathermap.org/data/2.5/onecall?units=imperial&lat=$lat&lon=$lon&appid=$apiKey&units='metric'");
    final weatherForecastResponse = await http.get(weatherForecastUrl);

    if (weatherForecastResponse.statusCode != 200) {
      throw Exception('error getting weather for location');
    }

    final weatherForecastJson = jsonDecode(weatherForecastResponse.body);
    return Forecast.fromJson(weatherForecastJson);
  }

}