class Trip {
  String id, userId, name, city, startDate, endDate, notes;
  String? pictureUrl;

  Trip(
      {required this.id,
      required this.userId,
      required this.name,
      required this.city,
      required this.startDate,
      required this.endDate,
      required this.notes,
      this.pictureUrl});

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['_id'],
      userId: json['user_id'],
      name: json['name'],
      city: json['city'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      notes: json['notes'],
      pictureUrl: json['picture_url'],
    );
  }
}
