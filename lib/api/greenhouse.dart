import 'dart:convert';

import 'package:http/http.dart' as http;

const API_HOST = 'http://greenhouse-api.agromega.in.ua';


getTemperature({period = '1h'}) async {
  var response = await http.get(
    '$API_HOST/temperature?period=$period',
    headers: {'Accept': 'application/json'},
  );
  return json.decode(response.body)["results"][0]["series"][0]["values"];
}

getHumidity({period = '1h'}) async {
  var response = await http.get(
    '$API_HOST/humidity?period=$period',
    headers: {'Accept': 'application/json'},
  );

  return json.decode(response.body)["results"][0]["series"][0]["values"];
}