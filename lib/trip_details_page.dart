import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:xplora/objects/accommodation.dart';
import 'package:xplora/objects/activity.dart';
import 'package:xplora/services/accommodation_service.dart';
import 'package:xplora/services/activity_service.dart';
import 'package:xplora/services/flight_service.dart';
import 'package:xplora/objects/flight.dart';
import 'package:xplora/services/trip_service.dart';

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
  final TextEditingController _flightConfirmationNumController =
      TextEditingController();
  final TextEditingController _flightNumController = TextEditingController();
  final TextEditingController _departureAirportController =
      TextEditingController();
  final TextEditingController _arrivalAirportController =
      TextEditingController();
  final TextEditingController _departureTimeController =
      TextEditingController();
  final TextEditingController _arrivalTimeController = TextEditingController();
  final TextEditingController _departureDateController =
      TextEditingController();
  final TextEditingController _arrivalDateController = TextEditingController();

  late Future<List<Accommodation>> futureAccommodations;
  final TextEditingController _accommodationNameController =
      TextEditingController();
  final TextEditingController _accommodationConfirmationNumController =
      TextEditingController();
  final TextEditingController _accommodationAddressController =
      TextEditingController();
  final TextEditingController _accommodationCheckInDateController =
      TextEditingController();
  final TextEditingController _accommodationCheckOutDateController =
      TextEditingController();
  final TextEditingController _accommodationCheckInTimeController =
      TextEditingController();
  final TextEditingController _accommodationCheckOutTimeController =
      TextEditingController();

  late Future<List<Activity>> futureActivities;
  final TextEditingController _activityNameController = TextEditingController();
  final TextEditingController _activityDateController = TextEditingController();
  final TextEditingController _activityTimeController = TextEditingController();
  final TextEditingController _activityLocationController =
      TextEditingController();
  final TextEditingController _activityNotesController =
      TextEditingController();

  bool isEditing = false;

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
      _showEditTripDialog();
    }
  }

  Future<void> _deleteTrip() async {
    final tripDeleteResponse =
        await TripService("https://xplora.fun").deleteTrip(userId, tripId);

    if (tripDeleteResponse['status_code'] == 200) {
      Fluttertoast.showToast(
          msg: tripDeleteResponse['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP);

      if (mounted) {
        Navigator.pop(context, 'delete');
      }

      return;
    }

    Fluttertoast.showToast(
        msg: tripDeleteResponse['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  void _editTrip(String? name, String? city, String? startDate, String? endDate,
      String? notes, File? photo) async {
    final tripEditResponse = await TripService('https://xplora.fun')
        .editTrip(userId, tripId, name, city, startDate, endDate, notes, photo);

    if (tripEditResponse['status_code'] == 201) {
      setState(() {
        tripName = name ?? tripName;
        tripCity = city ?? tripCity;
        tripStartDate = startDate ?? tripStartDate;
        tripEndDate = endDate ?? tripEndDate;
        tripDate = '$tripStartDate - $tripEndDate';
        tripNotes = notes ?? tripNotes;
      });

      if (photo != null) {
        setState(() {
          String fileName = tripEditResponse['picture_url'];
          photoUrl = "https://xplora.fun$fileName";
        });
      }

      Fluttertoast.showToast(
          msg: tripEditResponse['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP);

      return;
    }

    Fluttertoast.showToast(
        msg: tripEditResponse['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white);
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

  void _showEditTripDialog() {
    _tripNameController.text = tripName;
    _tripLocationController.text = tripCity;
    _tripStartDateController.text = tripStartDate;
    _tripEndDateController.text = tripEndDate;
    _tripNotesController.text = tripNotes;

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

                _editTrip(
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

  void _showFlightDialog([Flight? flight]) {
    showDialog(
      context: context,
      builder: (context) {
        if (isEditing && flight != null) {
          _flightConfirmationNumController.text = flight.confirmationNum;
          _flightNumController.text = flight.flightNum;
          _departureAirportController.text = flight.departureAirport;
          _arrivalAirportController.text = flight.arrivalAirport;
          _departureTimeController.text = flight.departureTime;
          _arrivalTimeController.text = flight.arrivalTime;
          _departureDateController.text = flight.departureDate;
          _arrivalDateController.text = flight.arrivalDate;
        }

        return AlertDialog(
          title: Text(isEditing ? 'Edit Flight Details' : 'Add Flight Details'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _flightConfirmationNumController,
                      decoration: InputDecoration(
                        labelText: 'Confirmation Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _flightNumController,
                      decoration: InputDecoration(
                        labelText: 'Flight Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _departureAirportController,
                      decoration: InputDecoration(
                        labelText: 'Departure Airport',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _arrivalAirportController,
                      decoration: InputDecoration(
                        labelText: 'Arrival Airport',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _departureTimeController,
                      decoration: InputDecoration(
                        labelText: 'Departure Time',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        ).then((pickedTime) {
                          if (pickedTime != null) {
                            String formattedTime =
                                "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                            _departureTimeController.text = formattedTime;
                          }
                        })
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _arrivalTimeController,
                      decoration: InputDecoration(
                        labelText: 'Arrival Time',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        ).then((pickedTime) {
                          if (pickedTime != null) {
                            String formattedTime =
                                "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                            _arrivalTimeController.text = formattedTime;
                          }
                        })
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _departureDateController,
                      decoration: InputDecoration(
                        labelText: 'Departure Date',
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
                            _departureDateController.text =
                                "${pickedDate.toLocal()}".split(' ')[0];
                          }
                        })
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _arrivalDateController,
                      decoration: InputDecoration(
                        labelText: 'Arrival Date',
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
                            _arrivalDateController.text =
                                "${pickedDate.toLocal()}".split(' ')[0];
                          }
                        })
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                _flightConfirmationNumController.clear();
                _flightNumController.clear();
                _departureAirportController.clear();
                _arrivalAirportController.clear();
                _departureTimeController.clear();
                _arrivalTimeController.clear();
                _departureDateController.clear();
                _arrivalDateController.clear();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_flightConfirmationNumController.text.isEmpty ||
                    _flightNumController.text.isEmpty ||
                    _departureAirportController.text.isEmpty ||
                    _arrivalAirportController.text.isEmpty ||
                    _departureTimeController.text.isEmpty ||
                    _arrivalTimeController.text.isEmpty ||
                    _departureDateController.text.isEmpty ||
                    _arrivalDateController.text.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "All fields are required",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white);
                  return;
                }

                DateTime startDate = DateTime.parse(
                    "${_departureDateController.text} ${_departureTimeController.text}");
                DateTime endDate = DateTime.parse(
                    "${_arrivalDateController.text} ${_arrivalTimeController.text}");

                if (startDate.isAfter(endDate)) {
                  Fluttertoast.showToast(
                      msg: "Please choose a valid date/time range",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white);
                  return;
                }

                if (isEditing) {
                  _editFlight(
                    flight!.id,
                    userId,
                    tripId,
                    _flightConfirmationNumController.text,
                    _flightNumController.text,
                    _departureAirportController.text,
                    _arrivalAirportController.text,
                    _departureTimeController.text,
                    _arrivalTimeController.text,
                    _departureDateController.text,
                    _arrivalDateController.text,
                  );
                } else {
                  _addFlight(
                    userId,
                    tripId,
                    _flightConfirmationNumController.text,
                    _flightNumController.text,
                    _departureAirportController.text,
                    _arrivalAirportController.text,
                    _departureTimeController.text,
                    _arrivalTimeController.text,
                    _departureDateController.text,
                    _arrivalDateController.text,
                  );
                }

                Navigator.pop(context);

                _flightConfirmationNumController.clear();
                _flightNumController.clear();
                _departureAirportController.clear();
                _arrivalAirportController.clear();
                _departureTimeController.clear();
                _arrivalTimeController.clear();
                _departureDateController.clear();
                _arrivalDateController.clear();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _addFlight(
    String userId,
    String tripId,
    String confirmationNum,
    String flightNum,
    String departureAirport,
    String arrivalAirport,
    String departureTime,
    String arrivalTime,
    String departureDate,
    String arrivalDate,
  ) async {
    final flightAddResponse = await FlightService('https://xplora.fun')
        .addFlight(
            userId,
            tripId,
            confirmationNum,
            flightNum,
            departureAirport,
            arrivalAirport,
            departureTime,
            arrivalTime,
            departureDate,
            arrivalDate);

    if (flightAddResponse['status_code'] == 201) {
      Fluttertoast.showToast(
          msg: flightAddResponse['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP);

      return;
    }

    Fluttertoast.showToast(
        msg: flightAddResponse['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  void _editFlight(
    String flightId,
    String userId,
    String tripId,
    String confirmationNum,
    String flightNum,
    String departureAirport,
    String arrivalAirport,
    String departureTime,
    String arrivalTime,
    String departureDate,
    String arrivalDate,
  ) async {
    final flightEditResponse = await FlightService('https://xplora.fun')
        .editFlight(
            flightId,
            userId,
            tripId,
            confirmationNum,
            flightNum,
            departureAirport,
            arrivalAirport,
            departureTime,
            arrivalTime,
            departureDate,
            arrivalDate);

    if (flightEditResponse['status_code'] == 201) {
      Fluttertoast.showToast(
          msg: flightEditResponse['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP);

      return;
    }

    Fluttertoast.showToast(
        msg: flightEditResponse['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  void _deleteFlight(Flight flight, String userId, String tripId) async {
    final flightDeleteResponse = await FlightService("https://xplora.fun")
        .deleteFlight(flight.id, userId, tripId);

    if (flightDeleteResponse['status_code'] == 201) {
      Fluttertoast.showToast(
          msg: flightDeleteResponse['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP);

      return;
    }

    Fluttertoast.showToast(
        msg: flightDeleteResponse['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  void _showAccommodationDialog([Accommodation? accommodation]) {
    showDialog(
      context: context,
      builder: (context) {
        if (isEditing && accommodation != null) {
          _accommodationNameController.text = accommodation.name;
          _accommodationConfirmationNumController.text =
              accommodation.confirmationNum;
          _accommodationAddressController.text = accommodation.address;
          _accommodationCheckInDateController.text = accommodation.checkInDate;
          _accommodationCheckOutDateController.text =
              accommodation.checkOutDate;
          _accommodationCheckInTimeController.text = accommodation.checkInTime;
          _accommodationCheckOutTimeController.text =
              accommodation.checkOutTime;
        }

        return AlertDialog(
          title: Text(isEditing
              ? 'Edit Accommodation Details'
              : 'Add Accommodation Details'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _accommodationNameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _accommodationConfirmationNumController,
                      decoration: InputDecoration(
                        labelText: 'Confirmation Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _accommodationAddressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _accommodationCheckInDateController,
                      decoration: InputDecoration(
                        labelText: 'Check-in Date',
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
                            _accommodationCheckInDateController.text =
                                "${pickedDate.toLocal()}".split(' ')[0];
                          }
                        })
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _accommodationCheckOutDateController,
                      decoration: InputDecoration(
                        labelText: 'Check-out Date',
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
                            _accommodationCheckOutDateController.text =
                                "${pickedDate.toLocal()}".split(' ')[0];
                          }
                        })
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _accommodationCheckInTimeController,
                      decoration: InputDecoration(
                        labelText: 'Check-in Time',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        ).then((pickedTime) {
                          if (pickedTime != null) {
                            String formattedTime =
                                "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                            _accommodationCheckInTimeController.text =
                                formattedTime;
                          }
                        })
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _accommodationCheckOutTimeController,
                      decoration: InputDecoration(
                        labelText: 'Check-out Time',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        ).then((pickedTime) {
                          if (pickedTime != null) {
                            String formattedTime =
                                "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                            _accommodationCheckOutTimeController.text =
                                formattedTime;
                          }
                        })
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                _accommodationNameController.clear();
                _accommodationConfirmationNumController.clear();
                _accommodationAddressController.clear();
                _accommodationCheckInDateController.clear();
                _accommodationCheckOutDateController.clear();
                _accommodationCheckInTimeController.clear();
                _accommodationCheckOutTimeController.clear();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_accommodationNameController.text.isEmpty ||
                    _accommodationConfirmationNumController.text.isEmpty ||
                    _accommodationAddressController.text.isEmpty ||
                    _accommodationCheckInDateController.text.isEmpty ||
                    _accommodationCheckOutDateController.text.isEmpty ||
                    _accommodationCheckInTimeController.text.isEmpty ||
                    _accommodationCheckOutTimeController.text.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "All fields are required",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white);
                  return;
                }

                DateTime startDate = DateTime.parse(
                    "${_accommodationCheckInDateController.text} ${_accommodationCheckInTimeController.text}");
                DateTime endDate = DateTime.parse(
                    "${_accommodationCheckOutDateController.text} ${_accommodationCheckOutTimeController.text}");

                if (startDate.isAfter(endDate)) {
                  Fluttertoast.showToast(
                      msg: "Please choose a valid date/time range",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white);
                  return;
                }

                if (isEditing) {
                  _editAccommodation(
                      accommodation!.id,
                      userId,
                      tripId,
                      _accommodationNameController.text,
                      _accommodationConfirmationNumController.text,
                      _accommodationAddressController.text,
                      _accommodationCheckInDateController.text,
                      _accommodationCheckOutDateController.text,
                      _accommodationCheckInTimeController.text,
                      _accommodationCheckOutTimeController.text);
                } else {
                  _addAccommodation(
                      userId,
                      tripId,
                      _accommodationNameController.text,
                      _accommodationConfirmationNumController.text,
                      _accommodationAddressController.text,
                      _accommodationCheckInDateController.text,
                      _accommodationCheckOutDateController.text,
                      _accommodationCheckInTimeController.text,
                      _accommodationCheckOutTimeController.text);
                }

                Navigator.pop(context);

                _accommodationNameController.clear();
                _accommodationConfirmationNumController.clear();
                _accommodationAddressController.clear();
                _accommodationCheckInDateController.clear();
                _accommodationCheckOutDateController.clear();
                _accommodationCheckInTimeController.clear();
                _accommodationCheckOutTimeController.clear();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _addAccommodation(
      String userId,
      String tripId,
      String name,
      String confirmationNum,
      String address,
      String checkInDate,
      String checkOutDate,
      String checkInTime,
      String checkOutTime) async {
    final accommodationAddResponse =
        await AccommodationService('https://xplora.fun').addAccommodation(
            userId,
            tripId,
            name,
            confirmationNum,
            address,
            checkInDate,
            checkOutDate,
            checkInTime,
            checkOutTime);

    if (accommodationAddResponse['status_code'] == 201) {
      Fluttertoast.showToast(
          msg: accommodationAddResponse['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP);

      return;
    }

    Fluttertoast.showToast(
        msg: accommodationAddResponse['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  void _editAccommodation(
      String accommodationId,
      String userId,
      String tripId,
      String name,
      String confirmationNum,
      String address,
      String checkInDate,
      String checkOutDate,
      String checkInTime,
      String checkOutTime) async {
    final accommodationAddResponse =
        await AccommodationService('https://xplora.fun').editAccommodation(
            accommodationId,
            userId,
            tripId,
            name,
            confirmationNum,
            address,
            checkInDate,
            checkOutDate,
            checkInTime,
            checkOutTime);

    if (accommodationAddResponse['status_code'] == 201) {
      Fluttertoast.showToast(
          msg: accommodationAddResponse['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP);

      return;
    }

    Fluttertoast.showToast(
        msg: accommodationAddResponse['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  void _deleteAccommodation(
      Accommodation accommodation, String userId, String tripId) async {
    final activityDeleteResponse =
        await AccommodationService("https://xplora.fun")
            .deleteAccommodation(accommodation.id, userId, tripId);

    if (activityDeleteResponse['status_code'] == 201) {
      Fluttertoast.showToast(
          msg: activityDeleteResponse['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP);

      return;
    }

    Fluttertoast.showToast(
        msg: activityDeleteResponse['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  void _showActivityDialog([Activity? activity]) {
    showDialog(
      context: context,
      builder: (context) {
        if (isEditing && activity != null) {
          _activityNameController.text = activity.name;
          _activityDateController.text = activity.date;
          _activityTimeController.text = activity.time;
          _activityLocationController.text = activity.location;
          _activityNotesController.text = activity.notes;
        }

        return AlertDialog(
          title: Text(
              isEditing ? 'Edit Activity Details' : 'Add Activity Details'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _activityNameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _activityDateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
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
                            _activityDateController.text =
                                "${pickedDate.toLocal()}".split(' ')[0];
                          }
                        })
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _activityTimeController,
                      decoration: InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        ).then((pickedTime) {
                          if (pickedTime != null) {
                            String formattedTime =
                                "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                            _activityTimeController.text = formattedTime;
                          }
                        })
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _activityLocationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _activityNotesController,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                _activityNameController.clear();
                _activityDateController.clear();
                _activityTimeController.clear();
                _activityLocationController.clear();
                _activityNotesController.clear();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_activityNameController.text.isEmpty ||
                    _activityDateController.text.isEmpty ||
                    _activityTimeController.text.isEmpty ||
                    _activityLocationController.text.isEmpty ||
                    _activityNotesController.text.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "All fields are required",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white);
                  return;
                }

                if (isEditing) {
                  _editActivity(
                      activity!.id,
                      userId,
                      tripId,
                      _activityNameController.text,
                      _activityDateController.text,
                      _activityTimeController.text,
                      _activityLocationController.text,
                      _activityNotesController.text);
                } else {
                  _addActivity(
                      userId,
                      tripId,
                      _activityNameController.text,
                      _activityDateController.text,
                      _activityTimeController.text,
                      _activityLocationController.text,
                      _activityNotesController.text);
                }

                Navigator.pop(context);

                _activityNameController.clear();
                _activityDateController.clear();
                _activityTimeController.clear();
                _activityLocationController.clear();
                _activityNotesController.clear();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _addActivity(String userId, String tripId, String name, String date,
      String time, String location, String notes) async {
    final activityAddResponse = await ActivityService('https://xplora.fun')
        .addActivity(userId, tripId, name, date, time, location, notes);

    if (activityAddResponse['status_code'] == 201) {
      Fluttertoast.showToast(
          msg: activityAddResponse['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP);

      return;
    }

    Fluttertoast.showToast(
        msg: activityAddResponse['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  void _editActivity(
      String activityId,
      String userId,
      String tripId,
      String name,
      String date,
      String time,
      String location,
      String notes) async {
    final activityAddResponse = await ActivityService('https://xplora.fun')
        .editActivity(
            activityId, userId, tripId, name, date, time, location, notes);

    if (activityAddResponse['status_code'] == 201) {
      Fluttertoast.showToast(
          msg: activityAddResponse['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP);

      return;
    }

    Fluttertoast.showToast(
        msg: activityAddResponse['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  void _deleteActivity(Activity activity, String userId, String tripId) async {
    final activityDeleteResponse = await ActivityService("https://xplora.fun")
        .deleteActivity(activity.id, userId, tripId);

    if (activityDeleteResponse['status_code'] == 201) {
      Fluttertoast.showToast(
          msg: activityDeleteResponse['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP);

      return;
    }

    Fluttertoast.showToast(
        msg: activityDeleteResponse['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white);
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
                        _showFlightDialog,
                        _deleteFlight,
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
                        _showAccommodationDialog,
                        _deleteAccommodation,
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
                        (categoryName) => Icons.local_activity,
                        _showActivityDialog,
                        _deleteActivity,
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
    void Function([T? item]) showDialogWidget,
    void Function(T item, String userId, String tripId) onDeleteItem,
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
                    isEditing = false;
                    showDialogWidget();
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
                        return Dismissible(
                          key: ValueKey(item),
                          direction: DismissDirection
                              .endToStart, // Swipe left to delete
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            onDeleteItem(item, userId, tripId);
                          },
                          child: GestureDetector(
                            onTap: () {
                              isEditing = true;
                              showDialogWidget(item);
                            },
                            child: itemBuilder(context, item),
                          ),
                        );
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
