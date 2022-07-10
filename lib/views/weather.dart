import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_app/bloc/weather/current_weather/current_weather_bloc.dart';
import 'package:weather_app/bloc/weather/current_weather/current_weather_event.dart';
import 'package:weather_app/bloc/weather/current_weather/current_weather_state.dart';
import 'package:weather_app/bloc/weather/forecast_weather/forecast_weather_bloc.dart';
import 'package:weather_app/bloc/weather/forecast_weather/forecast_weather_event.dart';
import 'package:weather_app/bloc/weather/forecast_weather/forecast_weather_state.dart';
import 'package:weather_app/data/weather_repository.dart';
import 'package:weather_app/models/forecast.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/providers/service_locator.dart';
import 'package:weather_app/views/weather_forecast.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var toDay=DateFormat('E, d MMM y').format(DateTime.now());
  var weatherRepository=getIt<WeatherRepository>();
  CurrentWeatherBloc _currentWeatherBloc=CurrentWeatherBloc(getIt<WeatherRepository>());
  ForecastWeatherBloc _forecastWeatherBloc=ForecastWeatherBloc(getIt<WeatherRepository>());
  late String address="";
  bool isLoading=true;
  late String latitude="22.1216";
  late String longitude="95.1536";

  @override
  void initState() {
    super.initState();
    getLocation();
  }
  void getLocation() async{
    try{
      Position position=await _determinePosition();
      setState(() {
        latitude=position.latitude.toString();
        longitude=position.longitude.toString();
      });
      print("THFJLKSDFJKLFJ $latitude $longitude");
      if(latitude!="" && longitude!=""){
        _currentWeatherBloc.add(FetchCurrentWeather(lat: latitude,lon: longitude));
        _forecastWeatherBloc.add(FetchForecastWeather(lat: latitude,lon: longitude));
      }
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude,localeIdentifier: "en");

      Placemark place = placemarks[0];
      String addressTemp=place.locality.toString()+', '+place.country.toString();
      setState(() {
        address=addressTemp;
        isLoading=false;
      });
    }
    catch(e){
      print("THIS IS GET LOCATION123");
      setState(() {
        isLoading=false;
      });
    }
  }
  Future<Position> _determinePosition() async {
    print("THIS IS GET LOCATION");
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<Null> _onRefresh() async{
    _currentWeatherBloc.add(FetchCurrentWeather(lat: latitude,lon: longitude));
    _forecastWeatherBloc.add(FetchForecastWeather(lat: latitude,lon: longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
      RefreshIndicator(
        onRefresh:_onRefresh,
        child:
        MultiProvider(
          providers: [
            BlocProvider(create:(context){
              return CurrentWeatherBloc(weatherRepository);
            }),
            BlocProvider(create:(context){
              return ForecastWeatherBloc(weatherRepository);
            })
          ],
            child: SingleChildScrollView(
              child: Column(
                // scrollDirection: Axis.vertical,
                // shrinkWrap: true,
                  children: <Widget>[
                    // Center(child: Text("${location.city.capitalize()}, ${location.country.capitalize()}",
                    //   style: TextStyle(fontSize: 17,color: Colors.white),)),
                    BlocBuilder<CurrentWeatherBloc,CurrentWeatherState>(
                        bloc: _currentWeatherBloc,
                        builder: (context, state){
                          if(state is CurrentWeatherError){
                            return Container(
                                padding: EdgeInsets.only(top: 20,bottom: 20),
                                child: Center(child: Text(state.errorMessage,style: TextStyle(color: Colors.red,fontSize: 15),)));
                          }
                          else if(state is CurrentWeatherLoading){
                            return Container(
                                padding: EdgeInsets.only(top: 20,bottom: 20),
                                child: SpinKitFadingFour(color: Color(0xff334A52),));
                          }
                          else if(state is CurrentWeatherLoaded){
                            return Container(
                              color: Colors.white,
                                child: Column(
                                  children: [
                                    currentWeather(weather: state.weather,context: context,toDay: toDay, address: address),
                                    currentWeatherDetails(state.weather),
                                  ],
                                ));
                          }
                          return Container(
                              padding: EdgeInsets.only(top: 20,bottom: 20),
                              child: SpinKitFadingFour(color: Color(0xff334A52),));
                        }
                    ),
                    BlocBuilder<ForecastWeatherBloc,ForecastWeatherState>(
                        bloc: _forecastWeatherBloc,
                        builder: (context, state){
                          if(state is ForecastWeatherError){
                            return Container(
                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.5),
                                child: Center(child: Text(state.errorMessage,style: TextStyle(color: Colors.red,fontSize: 15),)));
                          }
                          else if(state is ForecastWeatherLoading){
                            return Container(
                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.5),
                                child: SpinKitFadingFour(color:  Color(0xff334A52),));
                          }
                          else if(state is ForecastWeatherLoaded){
                            var _forecast=state.forecast;
                            return  Container(
                                color: Colors.white,
                                padding: EdgeInsets.only(top: 25,left: 20,right: 20),
                                // height: MediaQuery.of(context).size.height*0.3,
                                child: hourlyWeather(context,state.forecast));
                          }
                          return Container(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.5),
                            child: SpinKitFadingFour(color: Color(0xff334A52),),
                          );
                        }
                    ),
                  ]
              ),
            ),
          // ),
        ),
      ),
    );
  }
}

Widget currentWeather({required Weather weather,required  context,required  toDay, required address}){
  return Container(
    // color: Color(0xffE8F4F8),
    color: Colors.white,
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // "${weather.description.capitalize()}",
                    weather.description,
                    style: TextStyle(fontSize: 24,fontFamily: 'MyanmarSansPro',fontWeight: FontWeight.w500),
                  ),
                  Padding(padding: EdgeInsets.only(top: 7)),
                  Text("$toDay",style: TextStyle(color: Color(0xff555555),fontSize: 18,fontFamily: 'Rasa',),),
                  Text(address,style: TextStyle(color: Color(0xff555555),fontSize: 18,fontFamily: 'Rasa',))
                  // Text("Monywa, Sagaing",style: TextStyle(color: Color(0xff555555),fontSize: 18,fontFamily: 'Rasa',))
                ],
              ),
              Text( "${((weather.temp-32)*5/9).toInt()}°C",style: TextStyle(color:Color(0xff334A52),fontSize: 33,fontFamily: 'Oswald'),)
            ],
          ),
        ),
        Container(
          // color: Colors.yellow,
          width: MediaQuery.of(context).size.width*0.8,
          height: MediaQuery.of(context).size.height*0.3  ,
          child:Image.asset('assets/images/${getWeatherImage(weather.icon)}.png'),
        ),
        // getWeatherIcon(_weather.icon),
      ],
    ),
  );
}
Widget currentWeatherDetails(Weather _weather) {
  return Container(
    padding: const EdgeInsets.only(left: 15, top: 15, bottom: 15, right: 15),
    margin: const EdgeInsets.only(left: 15, bottom: 10, right: 15),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0xff989898),
            // color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(0, 3),
          )
        ]),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Container(
                child: Text(
                  "လေတိုက်နှုန်း",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontFamily: 'MyanmarSansPro',fontSize: 18,fontWeight: FontWeight.w500,
                      // fontWeight: FontWeight.w600,
                      // fontSize: 12
                      color: Colors.grey),
                )),
            Padding(padding: EdgeInsets.only(top: 3)),
            Container(
                child: Text(
                  "${_weather.wind} m/h",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontFamily: 'Rasa',fontSize: 18,fontWeight: FontWeight.w500,
                      // fontWeight: FontWeight.w700,
                      // fontSize: 15,
                      color: Colors.black),
                ))
          ],
        ),
        Column(
          children: [
            Container(
                child: Text(
                  "စိုထိုင်းဆ",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontFamily: 'MyanmarSansPro',fontSize: 18,fontWeight: FontWeight.w500, color: Colors.grey),
                )),
            Padding(padding: EdgeInsets.only(top: 3)),
            Container(
                child: Text(
                  "${_weather.humidity.toInt()}%",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontFamily: 'Rasa',fontSize: 18,fontWeight: FontWeight.w500, color: Colors.black),
                ))
          ],
        ),
        Column(
          children: [
            Container(
                child: Text(
                  "ဖိအား",
                  // "Pressure",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontFamily: 'MyanmarSansPro',fontSize: 18,fontWeight: FontWeight.w500, color: Colors.grey),
                )),
            Padding(padding: EdgeInsets.only(top: 3)),
            Container(
                child: Text(
                  "${_weather.pressure} hPa",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontFamily: 'Rasa',fontSize: 18,fontWeight: FontWeight.w500, color: Colors.black),
                ))
          ],
        ),
        Column(
          children: [
            Container(
                child: Text(
                  // "Feels like",
                  "ခံစားရမှု",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontFamily: 'MyanmarSansPro',
                      fontSize: 18,fontWeight: FontWeight.w500, color: Colors.grey),
                )),
            Padding(padding: EdgeInsets.only(top: 3)),
            Container(
                child: Text(
                  '${((_weather.feelsLike-32)*5/9).toInt()}°C',
                  // "${_weather.wind} km/h",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontFamily: 'Rasa',fontSize: 18,fontWeight: FontWeight.w500, color: Colors.black),
                ))
          ],
        )
      ],
    ),
  );
}
//
Widget hourlyWeather(context,Forecast _forecast,){
  return
    Column(
      children: [
        Divider(thickness: 1,),
        Padding(padding: EdgeInsets.only(top: 10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text("Today",style: TextStyle(fontFamily: 'Rasa',color: Colors.black,fontSize: 18,fontWeight: FontWeight.w500),),
                Icon(Icons.circle,size: 7,)
              ],
            ),

            GestureDetector(
              onTap: (){
               Navigator.push(context, MaterialPageRoute(builder:  (BuildContext context) => WeatherForecast(_forecast)));
              },
              child: Text("Next 7 Days >",style: TextStyle(fontFamily: 'Rasa',fontSize: 18,),),
            )

          ],
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        Container(
          height: 150.0,
          child: ListView.builder(
              // padding: const EdgeInsets.only(left: 5, top: 0, bottom: 30, right: 5),
              scrollDirection: Axis.horizontal,
              itemCount: _forecast.hourly.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: 75,
                    padding: const EdgeInsets.only(
                        left: 10, top: 10, bottom: 10, right: 10),
                      margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      border: Border.all(
                        // width: 1.4,
                        color: Colors.grey,
                      ),
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${getTimeFromTimestamp(_forecast.hourly[index].dt)}",
                            style: TextStyle(color: Color(0xff4A4A4A),fontSize: 14,fontFamily: 'Rasa'),
                          ),
                          Padding(padding: EdgeInsets.only(top: 5)),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                // color:Color(0xffE8F4F8),
                                color:Color(0xff367488),
                                image: DecorationImage(
                                    image: getWeatherIcon(_forecast.hourly[index].icon).image,
                                    fit: BoxFit.cover
                                ),
                                shape: BoxShape.circle
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 5)),
                          Text(
                            "${((_forecast.hourly[index].temp-32)*5/9).toInt()} °C",
                            style: TextStyle(color: Color(0xff334A52),fontSize: 18,fontFamily: 'Rasa',fontWeight: FontWeight.w500),
                          ),
                          // getWeatherIcon(_forecast.hourly[index].icon),
                        ]));
              }),
        )
      ],
    );
}

Image getWeatherIcon(String _icon) {
  String imgUrl='http://openweathermap.org/img/wn/$_icon@2x.png';
  // return Image.network(imgUrl,width: 100,height: 100,);
  return Image.network(imgUrl);
}
String getWeatherImage(String _icon) {
  String imgUrl='http://openweathermap.org/img/wn/$_icon@2x.png';
  // return Image.network(imgUrl,width: 100,height: 100,);
  String getData=_icon.substring(0,2);
  print("GetData $getData");
  switch(getData){
    case '01':
      return 'clearsky';
    case '02':
      return 'few_cloud';
    case '03':
      return 'cloudy';
    case '04':
      return 'cloudy';
    case '09':
      return 'raining';
    case '10':
      return 'raining';
    case '11':
      return 'thunder';
    case '13':
      return 'snow';
    case '50':
      return 'mist';
  }
  return "nocondition";
  // return Image.network(imgUrl);
}

String getTimeFromTimestamp(int timestamp) {
  var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var formatter = new DateFormat('h:mm a');
  return formatter.format(date);
}
