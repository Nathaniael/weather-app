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
  List<dynamic> hourlyForecast = [];

  AssetImage getBackgroundImage(String description) {
    if (description.contains('rain')) {
      return const AssetImage('assets/images/rainy.png');
    } else if (description.contains('sun') || description.contains('clear')) {
      return const AssetImage('assets/images/sunny.png');
    } else if (description.contains('snow') || description.contains('ice')) {
      return const AssetImage('assets/images/snowy.png');
    } else if (description.contains('thunder')) {
      return const AssetImage('assets/images/thunder.png');
    } else if (description.contains('cloud') ||
        description.contains('mist') ||
        description.contains('overcast')) {
      return const AssetImage('assets/images/cloudy.png');
    } else {
      return const AssetImage('assets/images/default.png');
    }
  }

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
    if (response.statusCode != 200) {
      setState(() {
        error = "Sorry, we don't have data for this city";
        temperature = "";
        description = "";
        humidity = "";
        windSpeed = "";
        icon = "";
        location = "";
        hourlyForecast = [];
      });
      return;
    }
    var results = await jsonDecode(response.body);
    var forecastData = results["forecast"]["forecastday"];

    setState(() {
      temperature = (results["current"]["temp_c"]).toString();
      description = results["current"]["condition"]["text"];
      humidity = results["current"]["humidity"].toString();
      windSpeed = results["current"]["wind_kph"].toString();
      icon = results["current"]["condition"]["icon"];
      location =
          results["location"]["name"] + ", " + results["location"]["country"];
      hourlyForecast = forecastData[0]["hour"];
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
          return Future.error('Location permissions are denied');
        }
      }
      await GeolocatorPlatform.instance.isLocationServiceEnabled();
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
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
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: getBackgroundImage(description),
              fit: BoxFit.cover,
            )),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
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
                      icon.replaceFirst('//', 'http://'),
                      color: Colors.white,
                      height: 100.0,
                    ),
                    Container(
                      height: 180.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: hourlyForecast.length,
                        itemBuilder: (context, index) {
                          var hour = hourlyForecast[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: 120.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    hour["time"].substring(11, 16),
                                    style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Image.network(
                                    hour["condition"]["icon"]
                                        .replaceFirst('//', 'http://'),
                                    height: 50.0,
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    '${hour["temp_c"].toStringAsFixed(0)}°C',
                                    style: const TextStyle(fontSize: 18.0),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    hour["condition"]["text"],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ))),
      ),
    );
  }
}
