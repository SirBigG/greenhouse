import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Greenhouse charts'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List temperatureData;
  List humidityData;

  getTemperature() async {
    var response = await http.get(
      'http://localhost:8088/temperature',
      headers: {'Accept': 'application/json'},
    );
    setState(() {
      temperatureData = json.decode(response.body)["results"][0]["series"][0]["values"];
    });
  }

  getHumidity() async {
    var response = await http.get(
      'http://localhost:8088/humidity',
      headers: {'Accept': 'application/json'},
    );
    setState(() {
      humidityData = json.decode(response.body)["results"][0]["series"][0]["values"];
    });
  }

  @override
  void initState() {
    super.initState();
    this.getTemperature().then((d) => {print("temperature request sent")});
    this.getHumidity().then((d) => {print("humidity request sent")});
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Tool Data'),
      ),
      body: Container(
          margin: const EdgeInsets.all(30.0),
      child: Center(

          child: SingleChildScrollView(
          child: Column(
              children: [
                  Row(children: [Text("Temperature (C)")]),
                  // temperatureData == null ? CircularProgressIndicator() : createTemperatureChart()
              Row(children: [SizedBox(
                  width: 700.0,
                  height: 300.0,
                  child: createTemperatureChart()
              )]),
                Row(children: [Text("Humidity (%)")]),
                Row(children: [SizedBox(
                    width: 700.0,
                    height: 300.0,
                    child: createHumidityChart()
                )]),
                ]

          )
      )
    ))
    );
  }

  Widget createTemperatureChart() {
    List<TimeSeries> data = [];
    for (int i = 0; i < temperatureData.length; i++) {
      data.add(TimeSeries(DateTime.fromMicrosecondsSinceEpoch(temperatureData[i][0]), temperatureData[i][1]));
    }
    List<charts.Series<TimeSeries, DateTime>> seriesList =  [charts.Series<TimeSeries, DateTime>(
      id: 'Temperature',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (TimeSeries wear, _) => wear.time,
      measureFn: (TimeSeries wear, _) => wear.value,
      // data is a List<LiveWerkzeuge> - extract the information from data
      // could use i as index - there isn't enough information in the question
      // map from 'data' to the series
      // this is a guess
      data: data,
    )];
    return new charts.TimeSeriesChart(
      seriesList,
      animate: false,
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
        primaryMeasureAxis: new charts.NumericAxisSpec(
            tickProviderSpec:
            new charts.BasicNumericTickProviderSpec(zeroBound: false)),

    );
  }

  Widget createHumidityChart() {
    List<TimeSeries> data = [];
    for (int i = 0; i < humidityData.length; i++) {
      data.add(TimeSeries(DateTime.fromMicrosecondsSinceEpoch(humidityData[i][0]), humidityData[i][1]));
    }
    List<charts.Series<TimeSeries, DateTime>> seriesList =  [charts.Series<TimeSeries, DateTime>(
      id: 'Humidity',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (TimeSeries wear, _) => wear.time,
      measureFn: (TimeSeries wear, _) => wear.value,
      // data is a List<LiveWerkzeuge> - extract the information from data
      // could use i as index - there isn't enough information in the question
      // map from 'data' to the series
      // this is a guess
      data: data,
    )];
    return new charts.TimeSeriesChart(
      seriesList,
      animate: false,
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
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
