import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:xplora/objects/accommodation.dart';
import 'package:xplora/objects/activity.dart';
import 'package:xplora/services/accommodation_service.dart';
import 'package:xplora/services/activity_service.dart';
import 'package:xplora/services/flight_service.dart';
import 'dart:convert';

import 'package:xplora/objects/flight.dart';

class TripDetailsPage extends StatefulWidget {
  final String userId;
  final String tripId;
  final String tripName;
  final String tripCity;
  final String tripStartDate;
  final String tripEndDate;
  final String tripNotes;
  final String tripPicUrl;

  const TripDetailsPage({
    super.key,
    required this.userId,
    required this.tripId,
    required this.tripName,
    required this.tripCity,
    required this.tripStartDate,
    required this.tripEndDate,
    required this.tripNotes,
    required this.tripPicUrl,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  late String userId;
  late String tripId;
  late String tripName;
  late String tripDate;
  late String tripStartDate;
  late String tripEndDate;
  late String tripCity;
  late String tripNotes;
  late String tripPicUrl;
  late String photoUrl;

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
  File? _photoFile;

  late Future<List<Flight>> futureFlights;
  late Future<List<Accommodation>> futureAccommodations;
  late Future<List<Activity>> futureActivities;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    tripId = widget.tripId;
    tripName = widget.tripName;
    tripCity = widget.tripCity;
    tripStartDate = widget.tripStartDate;
    tripEndDate = widget.tripEndDate;
    tripDate = '${widget.tripStartDate} - ${widget.tripEndDate}';
    tripNotes = widget.tripNotes;
    tripPicUrl = widget.tripPicUrl;
    photoUrl = "https://xplora.fun$tripPicUrl";

    futureFlights =
        FlightService("https://xplora.fun").fetchFlights(userId, tripId);

    futureAccommodations = AccommodationService("https://xplora.fun")
        .fetchAccommodations(userId, tripId);

    futureActivities =
        ActivityService("https://xplora.fun").fetchActivities(userId, tripId);
  }

  void _navigateBack(BuildContext context) {
    Navigator.pop(context, 'back');
  }

  void _handleMenuSelection(String value) {
    if (value == 'delete') {
      _deleteTrip();
    } else if (value == 'edit') {
      _editTrip();
    }
  }

  Future<void> _deleteTrip() async {
    final Uri uri =
        Uri.parse("https://xplora.fun/api/users/$userId/trips/$tripId");

    final response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: jsonResponse['message'],
        toastLength: Toast.LENGTH_LONG,
      );

      if (mounted) {
        Navigator.pop(context, 'delete');
      }
    }
  }

  void _editTrip() {
    _tripNameController.text = tripName;
    _tripLocationController.text = tripCity;
    _tripStartDateController.text = tripStartDate;
    _tripEndDateController.text = tripEndDate;
    _tripNotesController.text = tripNotes;
    _showEditDialog();
  }

  Future<void> _editTripRequest(
      String? reqName,
      String? reqCity,
      String? reqStartDate,
      String? reqEndDate,
      String? reqNotes,
      File? photo) async {
    final Uri uri =
        Uri.parse('https://xplora.fun/api/users/$userId/trips/$tripId');

    var request = http.MultipartRequest('PUT', uri);
    reqName != null ? request.fields['name'] = reqName : null;
    reqCity != null ? request.fields['city'] = reqCity : null;
    reqStartDate != null ? request.fields['start_date'] = reqStartDate : null;
    reqEndDate != null ? request.fields['end_date'] = reqEndDate : null;
    reqNotes != null ? request.fields['notes'] = reqNotes : null;

    if (photo != null) {
      var mimeType = lookupMimeType(photo.path);

      if (mimeType == null) {
        logger.e('Failed to detect MIME type');
        Fluttertoast.showToast(
            msg: 'Unexpected Error',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white);
        return;
      }

      logger.d('MIME Type: $mimeType');

      var photoFile = await http.MultipartFile.fromPath('photo', photo.path,
          contentType: MediaType.parse(mimeType));
      request.files.add(photoFile);
    }

    try {
      logger.d('Final URL: ${request.url}');
      var response = await request.send();

      logger.d(response.statusCode);

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);
        logger.d('Trip updated successfully');

        setState(() {
          tripName = reqName ?? tripName;
          tripCity = reqCity ?? tripCity;
          tripStartDate = reqStartDate ?? tripStartDate;
          tripEndDate = reqEndDate ?? tripEndDate;
          tripDate = '$tripStartDate - $tripEndDate';
          tripNotes = reqNotes ?? tripNotes;
        });

        if (photo != null) {
          setState(() {
            String fileName = responseData['picture_url'];
            photoUrl = "https://xplora.fun$fileName";
          });
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);
        logger.d('Failed to update trip: ${responseData['error']}');
      }
    } catch (e) {
      logger.e('Error occurred: $e');
    }
  }

  void _pickImage(ImageSource source, void Function(void Function()) setState) {
    final ImagePicker picker = ImagePicker();
    picker.pickImage(source: source).then((pickedFile) {
      if (pickedFile != null) {
        final File file = File(pickedFile.path);

        const int maxSizeInBytes = 5 * 1024 * 1024;
        if (file.lengthSync() > maxSizeInBytes) {
          Fluttertoast.showToast(
              msg: "File size must be less than 5MB",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.red,
              textColor: Colors.white);
          return;
        }

        final mimeType = lookupMimeType(pickedFile.path);
        logger.d('MIME Type: $mimeType');

        if (mimeType != 'image/jpeg' && mimeType != 'image/png') {
          Fluttertoast.showToast(
              msg: "Only JPEG and PNG files are allowed",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.red,
              textColor: Colors.white);
          return;
        }

        setState(() {
          _photoNameController.text = pickedFile.name;
          _photoFile = file;
        });
      } else {
        setState(() {
          _photoNameController.text = "No photo selected";
        });
      }
    });
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Trip Details'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
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
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      key: _choosePhotoButtonKey,
                      onPressed: () async {
                        final RenderBox renderBox = _choosePhotoButtonKey
                            .currentContext!
                            .findRenderObject() as RenderBox;
                        final position = renderBox.localToGlobal(Offset.zero);

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
                      child: Text('Choose photo (Optional)'),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: Text(
                        _photoNameController.text.isEmpty
                            ? 'No photo selected'
                            : _photoNameController.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                _tripNameController.text = tripName;
                _tripLocationController.text = tripCity;
                _tripStartDateController.text = tripStartDate;
                _tripEndDateController.text = tripEndDate;
                _tripNotesController.text = tripNotes;
                _photoNameController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                DateTime startDate =
                    DateTime.parse(_tripStartDateController.text);
                DateTime endDate = DateTime.parse(_tripEndDateController.text);

                if (startDate.isAfter(endDate)) {
                  Fluttertoast.showToast(
                      msg: "Please choose a valid date range",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white);
                  return;
                }

                _editTripRequest(
                    _tripNameController.text,
                    _tripLocationController.text,
                    _tripStartDateController.text,
                    _tripEndDateController.text,
                    _tripNotesController.text,
                    _photoFile);
                Navigator.pop(context);
                _photoFile = null;
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
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF6A0DAD),
          ),
          onPressed: () => _navigateBack(context),
        ),
        title: Text(
          'Trip Details',
          style: TextStyle(
            color: const Color(0xFF6A0DAD),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color: const Color(0xFF6A0DAD)),
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
        padding: const EdgeInsets.only(right: 8.0, left: 8.0, bottom: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.25),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tripName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            SizedBox(height: 18.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tripCity,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  tripDate,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 248, 220, 1.0),
                    border: Border.all(
                      color: const Color(0xFF6C4AB6),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 16 * 1.2 * 3,
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        tripNotes.isEmpty ? "No notes added." : tripNotes,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _buildCategorySection<Flight>(
                        'Flights',
                        futureFlights,
                        (context, flight) {
                          return ListTile(
                            title: Text('Flight: ${flight.flightNum}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Departure: ${flight.departureAirport} at ${flight.departureTime}'),
                                Text(
                                    'Arrival: ${flight.arrivalAirport} at ${flight.arrivalTime}'),
                                Text(
                                    'Confirmation Number: ${flight.confirmationNum}'),
                              ],
                            ),
                          );
                        },
                        (categoryName) => Icons.flight_takeoff,
                      ),
                      _buildCategorySection<Accommodation>(
                        'Accommodations',
                        futureAccommodations,
                        (context, accommodation) {
                          return ListTile(
                            title: Text('Hotel: ${accommodation.name}'),
                            subtitle:
                                Text('Location: ${accommodation.address}'),
                          );
                        },
                        (categoryName) => Icons.hotel,
                      ),
                      _buildCategorySection<Activity>(
                        'Activities',
                        futureActivities,
                        (context, activity) {
                          return ListTile(
                            title: Text('Activity: ${activity.name}'),
                            subtitle: Text('Details: ${activity.location}'),
                          );
                        },
                        (categoryName) =>
                            Icons.local_activity, // Icon for Activities
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection<T>(
    String categoryName,
    Future<List<T>> itemsFuture,
    Widget Function(BuildContext, T) itemBuilder,
    IconData Function(String) getCategoryIcon,
  ) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Theme(
          data: theme,
          child: ExpansionTile(
            leading: Icon(
              getCategoryIcon(categoryName),
              color: const Color(0xFF6A0DAD),
            ),
            title: Text(
              categoryName,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF6A0DAD)),
                  onPressed: () {
                    // Handle the "Add" button action here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Add to $categoryName')),
                    );
                  },
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                Icon(Icons.expand_more, color: Color(0xFF6A0DAD)),
              ],
            ),
            children: [
              FutureBuilder<List<T>>(
                future: itemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child:
                            Text(snapshot.error.toString().split(': ').last));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                          children: [
                            TextSpan(text: 'No $categoryName yet! Click '),
                            TextSpan(
                              text: "+",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const TextSpan(text: " button to add"),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Column(
                      children: snapshot.data!.map((item) {
                        return itemBuilder(context, item);
                      }).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
