import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'trip.dart'; // Import your Trip model

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  Future<List<Trip>>? _futureItems;

  Future<List<Trip>> fetchTrips(String userId) async {
    final response =
        await http.get(Uri.parse('https://xplora.fun/api/users/$userId/trips'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Trip.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load trips');
    }
  }

  Future<void> _loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId'); // Not being used for now

    setState(() {
      _futureItems = fetchTrips(userId!); // Use hardcoded userId
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Trips",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A0DAD),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Container(
                color: Color(0xFFDEDEDE),
                width: double.infinity,
                height: 2,
              ),
            ],
          ),
          SizedBox(height: 4),
          Expanded(
            child: FutureBuilder<List<Trip>>(
              future: _futureItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No trips found'));
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      children: snapshot.data!.map((trip) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            width: double.infinity,
                            height: 90,
                            color: Colors.amber,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(trip.name),
                                Text(trip.city),
                                Text('${trip.startDate} - ${trip.endDate}'),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
