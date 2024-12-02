import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xplora/objects/accommodation.dart';

class AccommodationService {
  final String baseUrl;

  AccommodationService(this.baseUrl);

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
}
