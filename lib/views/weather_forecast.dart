import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/forecast.dart';

class WeatherForecast extends StatefulWidget {
  final Forecast forecast;
  WeatherForecast(this.forecast);
  @override
  _WeatherForecastState createState() => _WeatherForecastState();
}

class _WeatherForecastState extends State<WeatherForecast> {
  @override
  Widget build(BuildContext context) {
    print("forecast!!");
    print(widget.forecast);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_rounded,color: Colors.black,),
        ),
        backgroundColor: Colors.white,
        title: Text('Weather Forecast',style: TextStyle(color: Colors.black,fontFamily: 'Rasa',fontSize: 20),),
      ),
      body: Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 20,top: 20,bottom: 20),
              child:  EasyRichText(
                'Next 7 days',
                patternList: [
                  EasyRichTextPattern(
                    targetString: 'Next',
                    style: TextStyle(color: Color(0xff4D4D4D),fontFamily: 'Rasa',fontSize: 22),
                  ),
                  EasyRichTextPattern(
                    targetString: '7 days',
                    style: TextStyle(fontSize: 25,fontFamily: 'Rasa'),
                  ),
                ],
              ),
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: widget.forecast.daily.length,
                itemBuilder: (BuildContext context, int index) {
                  return
                    index==0?Container():
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    // color:Color(0xffE8F4F8),
                                      color:Color(0xff367488),
                                      image: DecorationImage(
                                          image: getWeatherIconSmall(widget.forecast.daily[index].icon).image,
                                          fit: BoxFit.cover
                                      ),
                                      shape: BoxShape.circle
                                  ),
                                ),
                                // getWeatherIconSmall(widget.forecast.daily[index].icon),
                                // Padding(padding: EdgeInsets.only(left: 40)),
                                // Expanded(
                                //     child: getWeatherIconSmall(widget.forecast.daily[index].icon)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${getDateFromTimestamp(widget.forecast.daily[index].dt)}",
                                      style: TextStyle(fontSize: 18,fontFamily: 'Rasa', color: Colors.black),
                                    ),
                                    Row(
                                      children: [
                                        Text('${((widget.forecast.daily[index].dayTemp-32)*5/9).toInt()} °C',
                                            style: TextStyle(color: Color(0xff334A52),fontFamily: 'Oswald',fontSize: 18,)),
                                        Padding(padding: EdgeInsets.only(left: 10)),
                                        Text('${((widget.forecast.daily[index].nightTemp-32)*5/9).toInt()} °',
                                          style: TextStyle(color: Color(0xffBCBCBC),fontFamily: 'Oswald',fontSize: 16),),
                                        // Text('${(widget.forecast.daily[index].day-273.15).toInt()}')
                                      ],
                                    )
                                  ],
                                ),
                                // Padding(padding: EdgeInsets.only(left: 40)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Rain", style: TextStyle(color: Color(0xffBCBCBC),fontSize: 18,fontFamily: 'MyanmarSansPro'),
                                    ),
                                    Text(widget.forecast.daily[index].rain=="null"?"_":
                                    '${(double.parse(widget.forecast.daily[index].rain)*100).toInt()} %',
                                        style: TextStyle(color: Color(0xff334A52),fontFamily: 'Oswald',fontSize: 16,)),
                                  ],
                                ),
                                // Padding(padding: EdgeInsets.only(left: 40)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Wind",style: TextStyle(color: Color(0xffBCBCBC),fontSize: 18,fontFamily: 'MyanmarSansPro'),
                                    ),
                                    Text(
                                        '${widget.forecast.daily[index].wind} m/h',
                                        style:TextStyle(color: Color(0xff334A52),fontFamily: 'Oswald',fontSize: 16,)),
                                  ],
                                ),
                                // Padding(padding: EdgeInsets.only(left: 40)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Humidity",
                                      style: TextStyle(color: Color(0xffBCBCBC),fontSize: 18,fontFamily: 'MyanmarSansPro'),
                                    ),
                                    Text(
                                        '${widget.forecast.daily[index].humidity.toInt()} %',
                                        style: TextStyle(color: Color(0xff334A52),fontFamily: 'Oswald',fontSize: 16,)),
                                  ],
                                )
                              ]),
                        ),
                        Divider()
                      ],
                    );
                }),
          )
        ],
      ),
    );
  }
}

Image getWeatherIconSmall(String _icon) {
  String imgUrl='http://openweathermap.org/img/wn/$_icon@2x.png';
  return Image.network(imgUrl,width: 40,height: 40,);
}

String getDateFromTimestamp(int timestamp) {
  var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var formatter = new DateFormat('EEEE');
  
  return formatter.format(date);
}
