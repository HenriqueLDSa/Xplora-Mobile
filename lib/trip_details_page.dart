import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:xplora/dashboard_page.dart';
import 'package:xplora/login_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TripDetailsPage extends StatefulWidget {
  const TripDetailsPage({super.key});

  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  String tripName = 'Trip name';
  String tripDate = '00/00/0000 - 00/00/0000';
  String tripNotes = 'Notes here...';

  // Simulate stored details for each category
  List<String> flights = [];
  List<String> accommodations = [];
  List<String> activities = [];

  // Navigate back
  void _navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  // Handle Popup Menu Actions
  void _handleMenuSelection(String value) {
    if (value == 'delete') {
      _deleteTrip();
    } else if (value == 'edit') {
      _editTrip();
    }
  }

  void _deleteTrip() {
    // Add delete functionality
    print("Trip deleted");
  }

  void _editTrip() {
    // Add edit functionality
    print("Edit trip");
  }

  //Method to check if the first letter of the categoryName of the details is a vowel or not
  bool _isFirstLetterVowel(String word) {
    if (word.isEmpty) return false;
    String firstLetter = word[0].toLowerCase();

    return 'aeiou'.contains(firstLetter);
  }

  String _toSingular(String word) {
    String lowerWord = word.toLowerCase();

    if (lowerWord.endsWith('ies')) {
      return lowerWord.substring(0, lowerWord.length - 3) + 'y';
    } else if (lowerWord.endsWith('s')) {
      return lowerWord.substring(0, lowerWord.length - 1);
    }

    return lowerWord;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF6C4AB6),
          ),
          onPressed: () => _navigateBack(context),
        ),
        title: Text(
          'Trip Details',
          style: TextStyle(
            color: const Color(0xFF6C4AB6),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color: const Color(0xFF6C4AB6)),
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit Trip'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete Trip'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.25),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Column(
            children: [
              // Image Section
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/images/new_york.jpeg",
                        width: 100,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tripName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              tripDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: CustomTextField(
                                label: "Notes here...",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              // Additional Content
              Expanded(
                child: ListView(
                  children: [
                    // Trip Details
                    _buildCategorySection('Flights', flights.cast<Widget>()),
                    _buildCategorySection(
                        'Accommodations', accommodations.cast<Widget>()),
                    _buildCategorySection(
                        'Activities', activities.cast<Widget>()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Build  single category section
  Widget _buildCategorySection(String categoryName, List<Widget> details) {
    bool isVowel = _isFirstLetterVowel(categoryName);
    String categoryLower = _toSingular(categoryName);

    return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ExpansionTile(
            leading: Icon(
              Icons.flight_takeoff,
              color: const Color(0xFF6C4AB6),
            ),
            title: Text(
              categoryName,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            children: [
              if (details.isNotEmpty)
                ...details
                    .map((detail) => ListTile(title: Text(detail as String)))
              else
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black), // Default text style
                        children: [
                          TextSpan(text: 'No $categoryName yet! Click'),
                          TextSpan(
                            text: "+",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text:
                                " button to add ${isVowel ? 'an ' : 'a '} ${categoryLower}",
                          ) // Regular text again
                        ],
                      ),
                    )),
            ]));
  }
}
