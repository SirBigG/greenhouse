import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../utils/models.dart' as models;
import '../api/greenhouse.dart' as api;

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  List temperatureData = [];
  List humidityData = [];
  List moistureData = [];
  String filter = '1h';

  getTemperature({period: '1h'}) {
    api.getTemperature(period: period).then((data) => {
          setState(() {
            temperatureData = data;
          })
        });
  }

  getHumidity({period: '1h'}) {
    api.getHumidity(period: period).then((data) => {
          setState(() {
            humidityData = data;
          })
        });
  }

  getMoisture({period: '1h'}) {
    api.getMoisture(period: period).then((data) => {
      setState(() {
        moistureData = data;
      })
    });
  }

  @override
  void initState() {
    super.initState();
    this.getTemperature();
    this.getHumidity();
    this.getMoisture();
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
                    Container(
                        height: 30.0,
                        width: 900.0,
                        margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            Wrap(spacing: 10.0, runSpacing: 0.0, children: [
                              filterChip('1h'),
                              filterChip('6h'),
                              filterChip('12h'),
                              filterChip('1d'),
                              filterChip('7d'),
                            ])
                          ],
                        )),
                    Text("Temperature (C)"),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          height: 300.0,
                          width: 900.0,
                          child: createTemperatureChart()),
                    ),
                    Text("Humidity (%)"),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          height: 300.0,
                          width: 900.0,
                          child: createHumidityChart()),
                    ),
                    Text("Moisture"),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          height: 300.0,
                          width: 900.0,
                          child: createMoistureChart()),
                    )
                  ],
                ))));
  }

  Widget createTemperatureChart() {
    List<models.TimeSeries> data = [];
    for (int i = 0; i < temperatureData.length; i++) {
      if (temperatureData[i][1] > 12) {
        data.add(models.TimeSeries(
            DateTime.fromMicrosecondsSinceEpoch(
                (temperatureData[i][0] / 1000).toInt()),
            temperatureData[i][1]));
      }
    }
    List<charts.Series<models.TimeSeries, DateTime>> seriesList = [
      charts.Series<models.TimeSeries, DateTime>(
        id: 'Temperature',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (models.TimeSeries wear, _) => wear.time,
        measureFn: (models.TimeSeries wear, _) => wear.value,
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

  Widget filterChip(String period) {
    return ChoiceChip(
        selected: period == filter,
        label: Text(period),
        onSelected: (bool selected) {
          if (period != filter) {
            setState(() {
              filter = period;
            });
            this.getTemperature(period: period);
            this.getHumidity(period: period);
            this.getMoisture(period: period);
          }
        });
  }

  Widget createHumidityChart() {
    List<models.TimeSeries> data = [];
    for (int i = 0; i < humidityData.length; i++) {
      if (humidityData[i][1] < 100) {
        data.add(models.TimeSeries(
            DateTime.fromMicrosecondsSinceEpoch(
                (humidityData[i][0] / 1000).toInt()),
            humidityData[i][1]));
      }
    }
    List<charts.Series<models.TimeSeries, DateTime>> seriesList = [
      charts.Series<models.TimeSeries, DateTime>(
        id: 'Humidity',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (models.TimeSeries wear, _) => wear.time,
        measureFn: (models.TimeSeries wear, _) => wear.value,
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

  Widget createMoistureChart() {
    List<models.TimeSeries> data = [];
    for (int i = 0; i < moistureData.length; i++) {
        data.add(models.TimeSeries(
            DateTime.fromMicrosecondsSinceEpoch(
                (moistureData[i][0] / 1000).toInt()),
            moistureData[i][1]));
    }
    List<charts.Series<models.TimeSeries, DateTime>> seriesList = [
      charts.Series<models.TimeSeries, DateTime>(
        id: 'Humidity',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (models.TimeSeries wear, _) => wear.time,
        measureFn: (models.TimeSeries wear, _) => wear.value,
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
}
