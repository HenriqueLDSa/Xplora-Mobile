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
  bool isEditingNotes = false;
  TextEditingController notesController = TextEditingController();

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
      return '${lowerWord.substring(0, lowerWord.length - 3)}y';
    } else if (lowerWord.endsWith('s')) {
      return lowerWord.substring(0, lowerWord.length - 1);
    }

    return lowerWord;
  }

  @override
  void initState() {
    super.initState();
    notesController.text = tripNotes;
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/images/new_york.jpeg",
                        width: 110,
                        height: 110,
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              tripDate,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isEditingNotes = true; // Switch to editing mode
                    });
                  },
                  child: isEditingNotes
                      ? Container(
                          height: 100, // Set a fixed height for the container
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(
                                255, 248, 220, 1.0), // Set background color
                            border: Border.all(
                              color: const Color(0xFF6C4AB6), // Purple border
                              width: 2.0,
                            ),
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded corners
                          ),
                          child: SingleChildScrollView(
                            // Make the TextField scrollable
                            child: TextField(
                              controller: notesController,
                              maxLines: null, // Allow unlimited lines
                              onSubmitted: (value) {
                                setState(() {
                                  tripNotes = value; // Update the tripNotes
                                  isEditingNotes = false; // Exit editing mode
                                });
                              },
                              decoration: InputDecoration(
                                border:
                                    InputBorder.none, // Remove default border
                                contentPadding: EdgeInsets.all(
                                    8.0), // Padding inside the text field
                                hintText: "Notes here...", // Placeholder text
                                hintStyle: TextStyle(
                                    color: Colors
                                        .grey), // Style for the placeholder text
                              ),
                              cursorColor:
                                  const Color(0xFF6C4AB6), // Purple cursor
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(8.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(
                                255, 248, 220, 1.0), // Set background color
                            border: Border.all(
                              color: const Color(
                                  0xFF6C4AB6), // Purple border when not editing
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: SingleChildScrollView(
                            // Make the text scrollable when not editing
                            child: Text(
                              tripNotes.isEmpty
                                  ? "Notes here..."
                                  : tripNotes, // Show placeholder when empty
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ),
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

    //theme to remove the lines that divide the categorySections when they're clicked
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);

    IconData getIconForCategory(String categoryName) {
      switch (categoryName.toLowerCase()) {
        case 'flights':
          return Icons.flight_takeoff;
        case 'accommodations':
          return Icons.hotel;
        case 'activities':
          return Icons.local_activity;
        default:
          return Icons.category;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 12.0), // Match the image padding
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85, // Adjust the width
          child: Theme(
            data: theme,
            child: ExpansionTile(
              leading: Icon(
                getIconForCategory(categoryName),
                color: const Color(0xFF6C4AB6),
              ),
              title: Text(
                categoryName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              children: [
                // Details
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
                                " button to add ${isVowel ? 'an ' : 'a '} $categoryLower",
                          ), // Regular text again
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;

  const CustomTextField({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: null, // Allow the text field to expand vertically
      textAlignVertical: TextAlignVertical.top, // Align text to the top
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey), // Customize border color
        ),
        contentPadding:
            EdgeInsets.all(8.0), // Add padding inside the text field
      ),
    );
  }
}
