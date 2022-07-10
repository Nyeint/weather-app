import 'package:equatable/equatable.dart';
import 'package:weather_app/models/weather.dart';

abstract class CurrentWeatherState extends Equatable{
  @override
  List<Object> get props => [];
}

class CurrentWeatherEmpty extends CurrentWeatherState {}

class CurrentWeatherLoading extends CurrentWeatherState {}

class CurrentWeatherLoaded extends CurrentWeatherState {
  final Weather weather;

  CurrentWeatherLoaded({required this.weather});
}

class CurrentWeatherError extends CurrentWeatherState {
  final String errorMessage;
  CurrentWeatherError({required this.errorMessage});
}
