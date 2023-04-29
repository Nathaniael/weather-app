import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String cityName = "";
  String temperature = "";
  String description = "";
  String humidity = "";
  String windSpeed = "";
  String icon = "";
  String error = "";
  String location = "";

  Future getWeather() async {
    setState(() {
      error = "";
    });
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    http.Response response = await http.get(
        Uri.parse(
            "http://api.weatherapi.com/v1/forecast.json?q=$cityName&key=e1b4726e4af54395a9e170809232303"),
        headers: requestHeaders);
    // if error occurs, print error
    if (response.statusCode != 200) {
      print(response.statusCode);
      setState(() {
        error = "Sorry, we don't have data for this city";
        temperature = "";
        description = "";
        humidity = "";
        windSpeed = "";
        icon = "";
        location = "";
      });
      return;
    }
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
      location =
          results["location"]["name"] + ", " + results["location"]["country"];
    });
  }

  @override
  void initState() {
    void init() async {
      super.initState();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied.
          // You can try requesting permissions again here
          // or continue to use the app without location services.
          return Future.error('Location permissions are denied');
        }
      }
      await GeolocatorPlatform.instance.isLocationServiceEnabled();
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print(position);
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      String? city = placemarks[0].locality;
      setState(() {
        cityName = city!;
      });
      getWeather();
    }

    init();
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
            // create a top search bar with a text field and a search button to search for a city on the same row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 300.0,
                  child: TextField(
                    onSubmitted: (String input) {
                      setState(() {
                        cityName = input;
                        getWeather();
                      });
                    },
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Enter City Name",
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      getWeather();
                    });
                  },
                ),
              ],
            ),
            // if error occurs, display error message
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 20.0,
              ),
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    location,
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
