import 'package:get_it/get_it.dart';
import 'package:weather_app/data/weather_api_client.dart';
import 'package:weather_app/data/weather_repository.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  getIt.registerSingleton(WeatherApiClient());
  getIt.registerSingleton<WeatherRepository>(WeatherRepository(getIt<WeatherApiClient>()));

}
