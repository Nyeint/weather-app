import 'package:equatable/equatable.dart';

abstract class ForecastWeatherEvent extends Equatable{
  const ForecastWeatherEvent();
  @override
  List<Object> get props=>[];
}

class ForecastWeatherInitialize extends ForecastWeatherEvent{}

class FetchForecastWeather extends ForecastWeatherEvent {
  final String lat, lon;

  const FetchForecastWeather({required this.lon,required this.lat});
}