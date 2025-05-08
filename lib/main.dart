import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

void main() => runApp(const WeatherApp());

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WeatherHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final WeatherFactory _wf = WeatherFactory("27ef4814cf136da0049aece18c8bf531", language: Language.ENGLISH);
  Weather? _weather;
  String? _cityName;
  late String _formattedDate;

  @override
  void initState() {
    super.initState();
    _formattedDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());
    _fetchWeatherByLocation();
  }

  Future<void> _fetchWeatherByLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    Weather weather = await _wf.currentWeatherByLocation(position.latitude, position.longitude);
    setState(() {
      _weather = weather;
      _cityName = weather.areaName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF89A1C5), Color(0xFF4A5D79)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                _cityName ?? "Location",
                style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.w300),
              ),
              Text(
                _formattedDate,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              Text(
                _weather != null ? "${_weather!.temperature!.celsius!.round()}°C" : "--°C",
                style: const TextStyle(fontSize: 80, color: Colors.white),
              ),
              const Divider(color: Colors.white38, thickness: 1, indent: 40, endIndent: 40),
              Text(
                _weather != null ? _weather!.weatherMain! : "Cloudy",
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              Text(
                _weather != null
                    ? "${_weather!.tempMin!.celsius!.round()}°C / ${_weather!.tempMax!.celsius!.round()}°C"
                    : "25°C / 28°C",
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
