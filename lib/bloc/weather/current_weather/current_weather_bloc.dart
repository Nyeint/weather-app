import 'package:bloc/bloc.dart';
import 'package:weather_app/data/weather_repository.dart';
import 'package:weather_app/models/weather.dart';

import 'current_weather_event.dart';
import 'current_weather_state.dart';

class CurrentWeatherBloc extends Bloc<CurrentWeatherEvent,CurrentWeatherState>{
  final WeatherRepository weatherRepository;
  CurrentWeatherBloc(this.weatherRepository) : super(CurrentWeatherEmpty());

  @override
  Stream<CurrentWeatherState> mapEventToState(
      CurrentWeatherEvent event
      )async*{
    if(event is FetchCurrentWeather){
      yield CurrentWeatherLoading();
      try{
        final Weather weather = await weatherRepository.getCurrentWeather(lat: event.lat,lon: event.lon);
        yield CurrentWeatherLoaded(weather: weather);
      }
      catch (e) {
        yield CurrentWeatherError(errorMessage: e.toString());
      }
    }
  }
}