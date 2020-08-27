class Coordinate{
  final double lat;
  final double lng;

  Coordinate(this.lat, this.lng);

  factory Coordinate.fromJSON(Map<String, dynamic> json){
    return new Coordinate(
        json['lat'],
        json['lng']
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng
  };
}