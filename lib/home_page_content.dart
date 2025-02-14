import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xplora/services/trip_service.dart';
import 'package:xplora/trip_details_page.dart';
import 'objects/trip.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

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
  File? _photoFile;

  Future<List<Trip>>? futureTrips;

  late String userId;

  @override
  void initState() {
    super.initState();
    _getUserID();
    _loadTrips();
  }

  Future<void> _getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId')!;
    });
  }

  Future<void> _loadTrips() async {
    setState(() {
      futureTrips = TripService('https://xplora.fun').fetchTrips(userId);
    });
  }

  void _addTrip(String userId, String name, String city, String startDate,
      String endDate, String notes, File? photo) async {
    final tripAddResponse = await TripService('https://xplora.fun')
        .addTrip(userId, name, city, startDate, endDate, notes, photo);

    if (tripAddResponse['status_code'] == 201) {
      Fluttertoast.showToast(
          msg: tripAddResponse['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP);

      return;
    }

    Fluttertoast.showToast(
        msg: tripAddResponse['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  void navigateToTripDetails(BuildContext context, Trip trip) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsPage(
          userId: userId,
          tripId: trip.id,
          tripName: trip.name,
          tripCity: trip.city,
          tripStartDate: trip.startDate,
          tripEndDate: trip.endDate,
          tripNotes: trip.notes,
          tripPicUrl: trip.pictureUrl!,
        ),
      ),
    );

    if (result == 'delete' || result == 'back') {
      _loadTrips();
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

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Trip Details'),
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
                if (_tripNameController.text == "" ||
                    _tripLocationController.text == "" ||
                    _tripStartDateController.text == "" ||
                    _tripEndDateController.text == "") {
                  Fluttertoast.showToast(
                      msg: "All fields are required",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white);
                  return;
                }

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

                _addTrip(
                    userId,
                    _tripNameController.text,
                    _tripLocationController.text,
                    _tripStartDateController.text,
                    _tripEndDateController.text,
                    _tripNotesController.text,
                    _photoFile);
                Navigator.of(context).pop();
                _tripNameController.clear();
                _tripLocationController.clear();
                _tripStartDateController.clear();
                _tripEndDateController.clear();
                _tripNotesController.clear();
                _photoNameController.clear();
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
    return Navigator(onGenerateRoute: (RouteSettings settings) {
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
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
                    future: futureTrips,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              snapshot.error
                                  .toString()
                                  .replaceFirst('Exception: ', ''),
                              style: TextStyle(fontSize: 22),
                            ),
                            SizedBox(height: 5),
                            ElevatedButton(
                              onPressed: () {
                                _loadTrips();
                              },
                              child: Text('Refresh'),
                            ),
                          ],
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No trips found',
                              style: TextStyle(fontSize: 22),
                            ),
                            SizedBox(height: 5),
                            ElevatedButton(
                              onPressed: () {
                                _loadTrips();
                              },
                              child: Text('Refresh'),
                            ),
                          ],
                        );
                      } else {
                        return RefreshIndicator(
                          onRefresh: _loadTrips,
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var trip = snapshot.data![index];
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                child: InkWell(
                                  onTap: () =>
                                      navigateToTripDetails(context, trip),
                                  child: Container(
                                    width: double.infinity,
                                    height: 110,
                                    decoration: BoxDecoration(
                                        color: Color(0xFFEAEAEA),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  trip.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      trip.city,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                    Text(
                                                      '${trip.startDate} - ${trip.endDate}',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        SizedBox(
                                          width: 110,
                                          height: 110,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              'https://xplora.fun${trip.pictureUrl}',
                                              fit: BoxFit.cover,
                                              alignment: Alignment.center,
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            (loadingProgress
                                                                    .expectedTotalBytes ??
                                                                1)
                                                        : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object error,
                                                      StackTrace? stackTrace) {
                                                return Text(
                                                  'Failed to load image',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
