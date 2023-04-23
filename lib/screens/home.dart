import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String cityName = "Manama";
  String temperature = "";
  String description = "";
  String humidity = "";
  String windSpeed = "";
  String icon = "";

  Future getWeather() async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    http.Response response = await http.get(
        Uri.parse(
            "http://api.weatherapi.com/v1/forecast.json?q=$cityName&key=e1b4726e4af54395a9e170809232303"),
        headers: requestHeaders);
    var results = await jsonDecode(response.body);
    // try {
    //   var response = await Dio().get(
    //       'http://api.weatherapi.com/v1/forecast.json?q=$cityName&key=e1b4726e4af54395a9e170809232303');
    //   print(response);
    // } catch (e) {
    //   print(e);
    // }

    setState(() {
      temperature = (results["current"]["temp_c"]).toString();
      description = results["current"]["condition"]["text"];
      humidity = results["current"]["humidity"].toString();
      windSpeed = results["current"]["wind_kph"].toString();
      icon = results["current"]["condition"]["icon"];
    });
  }

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blueGrey[800],
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    cityName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "$temperature°C",
                    style: const TextStyle(
                      fontSize: 80.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    description.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.opacity,
                        color: Colors.white,
                        size: 30.0,
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        "$humidity%",
                        style: const TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.air,
                        color: Colors.white,
                        size: 30.0,
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        "$windSpeed km/h",
                        style: const TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Image.network(
              "http://cdn.weatherapi.com/weather/64x64/day/113.png",
              color: Colors.white,
              height: 100.0,
            ),
          ],
        ),
      ),
    );
  }
}
