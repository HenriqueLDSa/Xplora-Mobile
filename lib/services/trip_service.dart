import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:xplora/objects/trip.dart';

class TripService {
  final String baseUrl;

  TripService(this.baseUrl);

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  Future<Map<String, dynamic>> addTrip(String userId, String name, String city,
      String startDate, String endDate, String notes, File? photo) async {
    final Uri uri = Uri.parse('$baseUrl/api/users/$userId/trips');

    var request = http.MultipartRequest('POST', uri);
    request.fields['name'] = name;
    request.fields['city'] = city;
    request.fields['start_date'] = startDate;
    request.fields['end_date'] = endDate;
    request.fields['notes'] = notes;

    if (photo != null) {
      var mimeType = lookupMimeType(photo.path);

      if (mimeType == null) {
        return {'status_code': 500, 'message': 'Failed to detect file type'};
      }

      var photoFile = await http.MultipartFile.fromPath('photo', photo.path,
          contentType: MediaType.parse(mimeType));
      request.files.add(photoFile);
    }

    try {
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 201) {
        return {
          'status_code': response.statusCode,
          'message': responseData['message']
        };
      }

      return {
        'status_code': response.statusCode,
        'message': responseData['error']
      };
    } catch (e) {
      return {'status_code': 500, 'message': e.toString()};
    }
  }

  Future<List<Trip>> fetchTrips(String userId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/users/$userId/trips'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => Trip.fromJson(item)).toList();
      }

      var jsonResponse = json.decode(response.body);

      if (jsonResponse is Map && jsonResponse.containsKey('error')) {
        throw Exception(jsonResponse['error']);
      }

      throw Exception('Failed to fetch trips');
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> editTrip(
      String userId,
      String tripId,
      String? name,
      String? city,
      String? startDate,
      String? endDate,
      String? notes,
      File? photo) async {
    final Uri uri = Uri.parse('$baseUrl/api/users/$userId/trips/$tripId');

    var request = http.MultipartRequest('PUT', uri);
    name != null ? request.fields['name'] = name : null;
    city != null ? request.fields['city'] = city : null;
    startDate != null ? request.fields['start_date'] = startDate : null;
    endDate != null ? request.fields['end_date'] = endDate : null;
    notes != null ? request.fields['notes'] = notes : null;

    if (photo != null) {
      var mimeType = lookupMimeType(photo.path);

      if (mimeType == null) {
        return {'status_code': 500, 'message': 'Failed to detect file type'};
      }

      var photoFile = await http.MultipartFile.fromPath('photo', photo.path,
          contentType: MediaType.parse(mimeType));
      request.files.add(photoFile);
    }

    try {
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 201) {
        return {
          'status_code': response.statusCode,
          'message': responseData['message'],
          'picture_url': responseData['picture_url;']
        };
      }

      return {
        'status_code': response.statusCode,
        'message': responseData['error']
      };
    } catch (e) {
      return {'status_code': 500, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteTrip(String userId, String tripId) async {
    final Uri uri = Uri.parse("$baseUrl/api/users/$userId/trips/$tripId");

    final response = await http.delete(uri);

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return {
        'status_code': response.statusCode,
        'message': jsonResponse['message']
      };
    }

    return {
      'status_code': response.statusCode,
      'message': jsonResponse['error']
    };
  }
}
