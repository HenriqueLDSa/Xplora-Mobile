import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:xplora/objects/flight.dart';

class FlightService {
  final String baseUrl;

  FlightService(this.baseUrl);

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  Future<List<Flight>> fetchFlights(String userId, String tripId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/users/$userId/trips/$tripId/flights'));

      if (response.statusCode == 200) {
        List<dynamic> flightJson = json.decode(response.body);
        return flightJson.map((json) => Flight.fromJson(json)).toList();
      } else {
        final jsonResponse = json.decode(response.body);
        throw Exception(jsonResponse['error']);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> addFlight(
    String userId,
    String tripId,
    String confirmationNum,
    String flightNum,
    String departureAirport,
    String arrivalAirport,
    String departureTime,
    String arrivalTime,
    String departureDate,
    String arrivalDate,
  ) async {
    final Map<String, dynamic> bodyData = {
      'confirmation_num': confirmationNum,
      'flight_num': flightNum,
      'departure_airport': departureAirport,
      'arrival_airport': arrivalAirport,
      'departure_time': departureTime,
      'arrival_time': arrivalTime,
      'departure_date': departureDate,
      'arrival_date': arrivalDate,
    };

    final Uri uri =
        Uri.parse('$baseUrl/api/users/$userId/trips/$tripId/flights');

    final response = await http.post(
      uri,
      body: json.encode(bodyData),
      headers: {'Content-Type': 'application/json'},
    );

    final jsonResponseData = json.decode(response.body);

    if (response.statusCode == 201) {
      return {
        'status_code': response.statusCode,
        'message': jsonResponseData['message']
      };
    }

    return {
      'status_code': response.statusCode,
      'message': jsonResponseData['error']
    };
  }

  Future<Map<String, dynamic>> editFlight(
    String flightId,
    String userId,
    String tripId,
    String? confirmationNum,
    String? flightNum,
    String? departureAirport,
    String? arrivalAirport,
    String? departureTime,
    String? arrivalTime,
    String? departureDate,
    String? arrivalDate,
  ) async {
    final Map<String, dynamic> bodyData = {};

    if (confirmationNum != null) bodyData['confirmation_num'] = confirmationNum;
    if (flightNum != null) bodyData['flight_num'] = flightNum;
    if (departureAirport != null) {
      bodyData['departure_airport'] = departureAirport;
    }
    if (arrivalAirport != null) bodyData['arrival_airport'] = arrivalAirport;
    if (departureTime != null) bodyData['departure_time'] = departureTime;
    if (arrivalTime != null) bodyData['arrival_time'] = arrivalTime;
    if (departureDate != null) bodyData['departure_date'] = departureDate;
    if (arrivalDate != null) bodyData['arrival_date'] = arrivalDate;

    final Uri uri =
        Uri.parse('$baseUrl/api/users/$userId/trips/$tripId/flights/$flightId');

    final response = await http.put(
      uri,
      body: json.encode(bodyData),
      headers: {'Content-Type': 'application/json'},
    );

    final jsonResponseData = json.decode(response.body);

    if (response.statusCode == 201) {
      logger.d(jsonResponseData['message']);
      return {
        'status_code': response.statusCode,
        'message': jsonResponseData['message']
      };
    }

    logger.e(jsonResponseData['error']);
    return {
      'status_code': response.statusCode,
      'message': jsonResponseData['error']
    };
  }

  Future<Map<String, dynamic>> deleteFlight(
      String flightId, String userId, String tripId) async {
    final Uri uri =
        Uri.parse('$baseUrl/api/users/$userId/trips/$tripId/flights/$flightId');

    final response = await http.delete(uri);

    final jsonResponseData = json.decode(response.body);

    if (response.statusCode == 201) {
      logger.d(jsonResponseData['message']);
      return {
        'status_code': response.statusCode,
        'message': jsonResponseData['message']
      };
    }

    logger.e(jsonResponseData['error']);
    return {
      'status_code': response.statusCode,
      'message': jsonResponseData['error']
    };
  }
}
