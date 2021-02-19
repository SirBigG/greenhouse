import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Greenhouse charts'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List temperatureData = [];
  List humidityData = [];

  getTemperature() async {
    var response = await http.get(
      'http://greenhouse-api.agromega.in.ua/temperature',
      headers: {'Accept': 'application/json'},
    );
    setState(() {
      temperatureData =
          json.decode(response.body)["results"][0]["series"][0]["values"];
    });
  }

  getHumidity() async {
    var response = await http.get(
      'http://greenhouse-api.agromega.in.ua/humidity',
      headers: {'Accept': 'application/json'},
    );
    setState(() {
      humidityData =
          json.decode(response.body)["results"][0]["series"][0]["values"];
    });
  }

  @override
  void initState() {
    super.initState();
    this.getTemperature().then((d) => {});
    this.getHumidity().then((d) => {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Tool Data'),
        ),
        body: Center(
            child: Container(
              margin: EdgeInsets.all(30.0),
                child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Text("Temperature (C)"),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  height: 300.0, width: 900.0, child: createTemperatureChart()),
            ),
            Text("Humidity (%)"),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  height: 300.0, width: 900.0, child: createHumidityChart()),
            )
          ],
        ))));
  }

  Widget createTemperatureChart() {
    List<TimeSeries> data = [];
    for (int i = 0; i < temperatureData.length; i++) {
      if (temperatureData[i][1] > 12) {
        data.add(TimeSeries(
            DateTime.fromMicrosecondsSinceEpoch(
                (temperatureData[i][0] / 1000).toInt()),
            temperatureData[i][1]));
      }
    }
    List<charts.Series<TimeSeries, DateTime>> seriesList = [
      charts.Series<TimeSeries, DateTime>(
        id: 'Temperature',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeries wear, _) => wear.time,
        measureFn: (TimeSeries wear, _) => wear.value,
        data: data,
      )
    ];
    return new charts.TimeSeriesChart(
      seriesList,
      animate: true,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec:
              new charts.BasicNumericTickProviderSpec(zeroBound: false)),
    );
  }

  Widget createHumidityChart() {
    List<TimeSeries> data = [];
    for (int i = 0; i < humidityData.length; i++) {
      if (humidityData[i][1] < 100) {
        data.add(TimeSeries(
            DateTime.fromMicrosecondsSinceEpoch(
                (humidityData[i][0] / 1000).toInt()),
            humidityData[i][1]));
      }
    }
    List<charts.Series<TimeSeries, DateTime>> seriesList = [
      charts.Series<TimeSeries, DateTime>(
        id: 'Humidity',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeries wear, _) => wear.time,
        measureFn: (TimeSeries wear, _) => wear.value,
        data: data,
      )
    ];
    return new charts.TimeSeriesChart(
      seriesList,
      animate: false,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec:
              new charts.BasicNumericTickProviderSpec(zeroBound: false)),
    );
  }
}

class TimeSeries {
  final DateTime time;
  final double value;

  TimeSeries(this.time, this.value);
}
