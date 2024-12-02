import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xplora/objects/activity.dart';

class ActivityService {
  final String baseUrl;

  ActivityService(this.baseUrl);

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
}
