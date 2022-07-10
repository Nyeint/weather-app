import 'package:equatable/equatable.dart';

abstract class CurrentWeatherEvent extends Equatable{
  const CurrentWeatherEvent();
  @override
  List<Object> get props=>[];
}


class CurrentWeatherInitialize extends CurrentWeatherEvent{}

class FetchCurrentWeather extends CurrentWeatherEvent {
  final String lat, lon;

  const FetchCurrentWeather({required this.lon,required this.lat});
}