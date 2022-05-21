class ChildCase {
  ChildCase({
    required this.userEmail,
    required this.userID,
    required this.authID,
    required this.coordinatesLongitude,
    required this.coordinatesLatitude,
    required this.videoUrl,
    required this.status,
    required this.videoThumbnailUrl,
    required this.referencia,
    required this.comentarios,
    required this.observacion,
    required this.timestamp,
    required this.placemark,
  });

  ChildCase.fromJson(Map<String, Object?> json)
      : this(
          userEmail: json['userEmail']! as String,
          userID: json['userID']! as String,
          authID: json['authID']! as String,
          coordinatesLongitude: json['coordinatesLongitude']! as double,
          coordinatesLatitude: json['coordinatesLatitude']! as double,
          videoUrl: json['videoUrl']! as String,
          status: json['status']! as String,
          videoThumbnailUrl: json['videoThumbnailUrl']! as String,
          observacion: json['observacion']! as String,
          referencia: json['referencia']! as String,
          comentarios: json['comentarios']! as String,
          placemark: json['placemark']! as String,
          timestamp: json['timestamp']! as int,
        );
  final String userEmail;
  final String userID;
  final String authID;
  final double coordinatesLongitude;
  final double coordinatesLatitude;
  final String videoUrl;
  final String videoThumbnailUrl;
  final String status;
  final String observacion;
  final String referencia;
  final String comentarios;
  final String placemark;
  final int timestamp;
  Map<String, Object?> toJson() {
    return {
      'userEmail': userEmail,
      'userID': userID,
      'authID': authID,
      'coordinatesLongitude': coordinatesLongitude,
      'coordinatesLatitude': coordinatesLatitude,
      'videoUrl': videoUrl,
      'videoThumbnailUrl': videoThumbnailUrl,
      'status': status,
      'observacion': observacion,
      'referencia': referencia,
      'comentarios': comentarios,
      'placemark': placemark,
      'timestamp': timestamp,
    };
  }
}
