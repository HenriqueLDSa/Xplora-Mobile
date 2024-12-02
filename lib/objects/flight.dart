class Flight {
  String id,
      userId,
      tripId,
      confirmationNum,
      flightNum,
      departureAirport,
      arrivalAirport,
      departureTime,
      arrivalTime,
      departureDate,
      arrivalDate;

  Flight({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.confirmationNum,
    required this.flightNum,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureDate,
    required this.arrivalDate,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['_id'],
      userId: json['user_id'],
      tripId: json['trip_id'],
      confirmationNum: json['confirmation_num'],
      flightNum: json['flight_num'],
      departureAirport: json['departure_airport'],
      arrivalAirport: json['arrival_airport'],
      departureTime: json['departure_time'],
      arrivalTime: json['arrival_time'],
      departureDate: json['departure_date'],
      arrivalDate: json['arrival_date'],
    );
  }
}
