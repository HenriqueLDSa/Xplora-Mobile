import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'trip.dart';

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
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leadingWidth: 100,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Center(
              child: Text(
                "Trips",
                style: TextStyle(
                    color: Color(0xFF6A0DAD),
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: Icon(
                  Icons.add,
                  color: Color(0xFF6A0DAD),
                  size: 43.0,
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                                height: 100,
                                decoration: BoxDecoration(
                                    color: Color(0xFFEAEAEA),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                trip.name,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    trip.city,
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                  Text(
                                                    '${trip.startDate} - ${trip.endDate}',
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: 110,
                                          height: 100,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                              'assets/images/new-york.png',
                                              fit: BoxFit.cover,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
        ));
  }
}
