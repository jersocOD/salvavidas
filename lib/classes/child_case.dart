class ChildCase {
  ChildCase({
    required this.userEmail,
    required this.coordinatesLongitude,
    required this.coordinatesLatitude,
    required this.videoUrl,
    required this.status,
    required this.timestamp,
  });

  ChildCase.fromJson(Map<String, Object?> json)
      : this(
          userEmail: json['userEmail']! as String,
          coordinatesLongitude: json['coordinatesLongitude']! as double,
          coordinatesLatitude: json['coordinatesLatitude']! as double,
          videoUrl: json['videoUrl']! as String,
          status: json['status']! as String,
          timestamp: json['timestamp']! as int,
        );
  final String userEmail;
  final double coordinatesLongitude;
  final double coordinatesLatitude;
  final String videoUrl;
  final String status;
  final int timestamp;
  Map<String, Object?> toJson() {
    return {
      'userEmail': userEmail,
      'coordinatesLongitude': coordinatesLongitude,
      'coordinatesLatitude': coordinatesLatitude,
      'videoUrl': videoUrl,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
