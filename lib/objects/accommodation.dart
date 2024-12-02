class Accommodation {
  String id,
      userId,
      tripId,
      name,
      confirmationNum,
      address,
      checkInDate,
      checkOutDate,
      checkInTime,
      checkOutTime;

  Accommodation({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.name,
    required this.confirmationNum,
    required this.address,
    required this.checkInDate,
    required this.checkOutDate,
    required this.checkInTime,
    required this.checkOutTime,
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    return Accommodation(
      id: json['_id'],
      userId: json['user_id'],
      tripId: json['trip_id'],
      name: json['name'],
      confirmationNum: json['confirmation_num'],
      address: json['address'],
      checkInDate: json['checkin_date'],
      checkOutDate: json['checkout_date'],
      checkInTime: json['checkin_time'],
      checkOutTime: json['checkout_time'],
    );
  }
}
