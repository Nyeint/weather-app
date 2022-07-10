import 'package:weather_app/data/weather_api_client.dart';
import 'package:weather_app/models/forecast.dart';
import 'package:weather_app/models/weather.dart';

class WeatherRepository{
  final WeatherApiClient weatherApiClient;
  WeatherRepository(this.weatherApiClient);

  Future<Weather> getCurrentWeather({required String lat,required String lon}) async {
    return weatherApiClient.fetchCurrentWeather(lat: lat,lon: lon);
  }
  Future<Forecast> getForecastWeather({required String lat,required String lon}) async {
    return weatherApiClient.fetchForecastWeather(lat: lat,lon: lon);
  }
}