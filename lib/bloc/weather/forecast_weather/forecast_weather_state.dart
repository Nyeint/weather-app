import 'package:equatable/equatable.dart';
import 'package:weather_app/models/forecast.dart';

abstract class ForecastWeatherState extends Equatable{
  @override
  List<Object> get props => [];
}

class ForecastWeatherEmpty extends ForecastWeatherState {}

class ForecastWeatherLoading extends ForecastWeatherState {}

class ForecastWeatherLoaded extends ForecastWeatherState {
  final Forecast forecast;

  ForecastWeatherLoaded({required this.forecast});
}

class ForecastWeatherError extends ForecastWeatherState {
  final String errorMessage;
  ForecastWeatherError({required this.errorMessage});
}
