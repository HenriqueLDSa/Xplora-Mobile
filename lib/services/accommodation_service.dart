import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:xplora/objects/accommodation.dart';

class AccommodationService {
  final String baseUrl;

  AccommodationService(this.baseUrl);

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  Future<List<Accommodation>> fetchAccommodations(
      String userId, String tripId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/trips/$tripId/accommodations'));

    if (response.statusCode == 200) {
      List<dynamic> accommodationJson = json.decode(response.body);
      return accommodationJson
          .map((json) => Accommodation.fromJson(json))
          .toList();
    } else {
      final jsonResponse = json.decode(response.body);
      throw Exception(jsonResponse['error']);
    }
  }

  Future<Map<String, dynamic>> addAccommodation(
      String userId,
      String tripId,
      String name,
      String confirmationNum,
      String address,
      String checkInDate,
      String checkOutDate,
      String checkInTime,
      String checkOutTime) async {
    final Map<String, dynamic> bodyData = {
      'name': name,
      'confirmation_num': confirmationNum,
      'address': address,
      'checkin_date': checkInDate,
      'checkout_date': checkOutDate,
      'checkin_time': checkInTime,
      'checkout_time': checkOutTime
    };

    final Uri uri =
        Uri.parse('$baseUrl/api/users/$userId/trips/$tripId/accommodations');

    final response = await http.post(
      uri,
      body: json.encode(bodyData),
      headers: {'Content-Type': 'application/json'},
    );

    final jsonResponseData = json.decode(response.body);
    logger.d(response.statusCode);

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

  Future<Map<String, dynamic>> editAccommodation(
      String accommodationId,
      String userId,
      String tripId,
      String? name,
      String? confirmationNum,
      String? address,
      String? checkInDate,
      String? checkOutDate,
      String? checkInTime,
      String? checkOutTime) async {
    final Map<String, dynamic> bodyData = {};

    if (name != null) bodyData['name'] = name;
    if (confirmationNum != null) bodyData['confirmation_num'] = confirmationNum;
    if (address != null) bodyData['address'] = address;
    if (checkInDate != null) bodyData['checkin_date'] = checkInDate;
    if (checkOutDate != null) bodyData['checkout_date'] = checkOutDate;
    if (checkInTime != null) bodyData['checkin_time'] = checkInTime;
    if (checkOutTime != null) bodyData['checkout_time'] = checkOutTime;

    final Uri uri = Uri.parse(
        '$baseUrl/api/users/$userId/trips/$tripId/accommodations/$accommodationId');

    final response = await http.put(
      uri,
      body: json.encode(bodyData),
      headers: {'Content-Type': 'application/json'},
    );

    final jsonResponseData = json.decode(response.body);
    logger.d(response.statusCode);

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

  Future<Map<String, dynamic>> deleteAccommodation(
      String accommodationId, String userId, String tripId) async {
    final Uri uri = Uri.parse(
        '$baseUrl/api/users/$userId/trips/$tripId/accommodations/$accommodationId');

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
