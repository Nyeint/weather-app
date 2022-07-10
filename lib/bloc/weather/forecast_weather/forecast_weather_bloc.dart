import 'package:bloc/bloc.dart';
import 'package:weather_app/data/weather_repository.dart';
import 'package:weather_app/models/forecast.dart';

import 'forecast_weather_event.dart';
import 'forecast_weather_state.dart';

class ForecastWeatherBloc extends Bloc<ForecastWeatherEvent,ForecastWeatherState>{
  final WeatherRepository weatherRepository;
  ForecastWeatherBloc(this.weatherRepository) : super(ForecastWeatherEmpty());

  @override
  Stream<ForecastWeatherState> mapEventToState(
      ForecastWeatherEvent event
      )async*{
    if(event is FetchForecastWeather){
      yield ForecastWeatherLoading();
      try{
        final Forecast forecast = await weatherRepository.getForecastWeather(lat: event.lat,lon: event.lon);
        yield ForecastWeatherLoaded(forecast: forecast);
      }
      catch (e) {
        yield ForecastWeatherError(errorMessage: e.toString());
      }
    }
  }
}