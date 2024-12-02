class Activity {
  String id, userId, tripId, name, date, time, location, notes;

  Activity({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.notes,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
        id: json['_id'],
        userId: json['user_id'],
        tripId: json['trip_id'],
        name: json['name'],
        date: json['date'],
        time: json['time'],
        location: json['location'],
        notes: json['notes']);
  }
}
