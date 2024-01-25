import 'dart:io';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class PlaceLocation {
  const PlaceLocation(
      {required this.latitude, required this.longitude, required this.address});

  final double latitude;
  final double longitude;
  final String address;
}

class Places {
  //Inside the constructor, there's an initializer list (: id = uuid.v4();).
  // This initializes the id property with the result of calling uuid.v4().
  Places({
    required this.title,
    required this.image,
    required this.location,
    String? id,
  }) : id = id ?? uuid.v4(); //?? means if it is null then uuid will be executed
  final String id;
  final String title;
  File image;
  final PlaceLocation location;
}
