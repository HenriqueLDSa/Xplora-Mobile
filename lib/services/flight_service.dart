import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xplora/objects/flight.dart';

class FlightService {
  final String baseUrl;

  FlightService(this.baseUrl);

  Future<List<Flight>> fetchFlights(String userId, String tripId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/users/$userId/trips/$tripId/flights'));

    if (response.statusCode == 200) {
      List<dynamic> flightJson = json.decode(response.body);
      return flightJson.map((json) => Flight.fromJson(json)).toList();
    } else {
      final jsonResponse = json.decode(response.body);
      throw Exception(jsonResponse['error']);
    }
  }
}
