import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:xplora/objects/activity.dart';

class ActivityService {
  final String baseUrl;

  ActivityService(this.baseUrl);

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  Future<List<Activity>> fetchActivities(String userId, String tripId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/users/$userId/trips/$tripId/activities'));

    if (response.statusCode == 200) {
      List<dynamic> activityJson = json.decode(response.body);
      return activityJson.map((json) => Activity.fromJson(json)).toList();
    } else {
      final jsonResponse = json.decode(response.body);
      throw Exception(jsonResponse['error']);
    }
  }

  Future<Map<String, dynamic>> addActivity(
      String userId,
      String tripId,
      String name,
      String date,
      String time,
      String location,
      String notes) async {
    final Map<String, dynamic> bodyData = {
      'name': name,
      'date': date,
      'time': time,
      'location': location,
      'notes': notes
    };

    logger.d(bodyData);

    final Uri uri =
        Uri.parse('$baseUrl/api/users/$userId/trips/$tripId/activities');

    final response = await http.post(
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

  Future<Map<String, dynamic>> editActivity(
      String activityId,
      String userId,
      String tripId,
      String? name,
      String? date,
      String? time,
      String? location,
      String? notes) async {
    final Map<String, dynamic> bodyData = {};

    if (name != null) bodyData['name'] = name;
    if (date != null) bodyData['date'] = date;
    if (time != null) bodyData['time'] = time;
    if (location != null) bodyData['location'] = location;
    if (notes != null) bodyData['notes'] = notes;

    logger.d(bodyData);

    final Uri uri = Uri.parse(
        '$baseUrl/api/users/$userId/trips/$tripId/activities/$activityId');

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

  Future<Map<String, dynamic>> deleteActivity(
      String activityId, String userId, String tripId) async {
    final Uri uri = Uri.parse(
        '$baseUrl/api/users/$userId/trips/$tripId/activities/$activityId');

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
