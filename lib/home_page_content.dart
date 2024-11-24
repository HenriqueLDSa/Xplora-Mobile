import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'trip.dart';
import 'package:image_picker/image_picker.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  var logger = Logger(
    printer: PrettyPrinter(),
  );

  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _tripLocationController = TextEditingController();
  final TextEditingController _tripStartDateController =
      TextEditingController();
  final TextEditingController _tripEndDateController = TextEditingController();
  final TextEditingController _tripNotesController = TextEditingController();
  final GlobalKey _choosePhotoButtonKey = GlobalKey();
  final TextEditingController _photoNameController =
      TextEditingController(text: 'No photo selected');

  Future<List<Trip>>? _futureItems;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<List<Trip>> fetchTrips(String userId) async {
    final response =
        await http.get(Uri.parse('https://xplora.fun/api/users/$userId/trips'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Trip.fromJson(item)).toList();
    } else {
      logger.e('Failed to fetch trips: ${response.body}');
      throw Exception('Failed to load trips');
    }
  }

  Future<void> _loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    setState(() {
      _futureItems = fetchTrips(userId!);
    });
  }

  Future<void> _addTrip(String reqName, String reqCity, String reqStartDate,
      String reqEndDate, String reqNotes, String reqPicName) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    final Map<String, dynamic> payload = {
      'name': reqName,
      'city': reqCity,
      'start_date': reqStartDate,
      'end_date': reqEndDate,
      'notes': reqNotes,
      'picture_url': reqPicName
    };

    final response = await http.post(
      Uri.parse('https://xplora.fun/api/users/$userId/trips'),
      body: jsonEncode(payload),
      headers: {'Content-Type': 'application/json'},
    );

    logger.d('Payload addTrip: $payload');

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 201) {
      Fluttertoast.showToast(
        msg: jsonResponse['message'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      _loadTrips();
    } else {
      Fluttertoast.showToast(
        msg: jsonResponse['error'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _pickImage(ImageSource source, void Function(void Function()) setState) {
    final ImagePicker picker = ImagePicker();
    picker.pickImage(source: source).then((pickedFile) {
      if (pickedFile != null) {
        setState(() {
          _photoNameController.text = pickedFile.name;
        });
      }
    });
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Trip Details'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _tripNameController,
                    decoration: InputDecoration(
                      labelText: 'Trip Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _tripLocationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _tripStartDateController,
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      ).then((pickedDate) {
                        if (pickedDate != null) {
                          _tripStartDateController.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
                        }
                      })
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _tripEndDateController,
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      ).then((pickedDate) {
                        if (pickedDate != null) {
                          _tripEndDateController.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
                        }
                      })
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _tripNotesController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    key: _choosePhotoButtonKey,
                    onPressed: () async {
                      final RenderBox renderBox = _choosePhotoButtonKey
                          .currentContext!
                          .findRenderObject() as RenderBox;
                      final position = renderBox.localToGlobal(
                          Offset.zero); // Get global position of the button

                      // Show the dropdown menu when the button is clicked
                      showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                            position.dx,
                            position.dy + renderBox.size.height,
                            position.dx + renderBox.size.width,
                            0.0),
                        items: [
                          PopupMenuItem<String>(
                            value: 'Take picture',
                            child: Text('Take picture'),
                          ),
                          PopupMenuItem<String>(
                            value: 'Select from gallery',
                            child: Text('Select from gallery'),
                          ),
                        ],
                      ).then((value) {
                        if (value != null) {
                          if (value == 'Take picture') {
                            _pickImage(ImageSource.camera, setState);
                          } else if (value == 'Select from gallery') {
                            _pickImage(ImageSource.gallery, setState);
                          }
                        }
                      });
                    },
                    child: Text('Choose trip photo'),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: 200), // Set max width for the text
                    child: Text(
                      _photoNameController.text.isEmpty
                          ? 'No photo selected'
                          : _photoNameController.text,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis, // Truncate text with ellipsis
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  )
                ],
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                _tripNameController.clear();
                _tripLocationController.clear();
                _tripStartDateController.clear();
                _tripEndDateController.clear();
                _tripNotesController.clear();
                _photoNameController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addTrip(
                    _tripNameController.text,
                    _tripLocationController.text,
                    _tripStartDateController.text,
                    _tripEndDateController.text,
                    _tripNotesController.text,
                    _photoNameController.text);
                Navigator.of(context).pop();
                _tripNameController.clear();
                _tripLocationController.clear();
                _tripStartDateController.clear();
                _tripEndDateController.clear();
                _tripNotesController.clear();
                _photoNameController.clear();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
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
                child: IconButton(
                  onPressed: () {
                    _showAddDialog();
                  },
                  icon: Icon(
                    Icons.add,
                    color: Color(0xFF6A0DAD),
                    size: 43.0,
                  ),
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
