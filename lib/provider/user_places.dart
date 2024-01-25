import 'dart:io';
import "package:path_provider/path_provider.dart" as syspaths;
import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:places_app/models/place.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql
      .getDatabasesPath(); //dbPath points to a directory where we might create a database
  final db = await sql.openDatabase(
    path.join(dbPath, 'placesDb.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL,address TEXT) ');
    },
    version: 1, //chnge the value whenever u chnge the table struc
  );
  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Places>> {
  UserPlacesNotifier() : super([]);

  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query(
        'user_places'); //returns a future that yields a map and this will be a list of database rows
    //every map will represent one row of databse
    //'query' queries the db table and gets data from the table
    //Conversion:converting every row to place Object using place class
    final places = data
        .map((row) => Places(
            id: row['id'] as String,
            title: row['title'] as String,
            image: File(row['image'] as String),
            location: PlaceLocation(
              latitude: row['lat'] as double,
              longitude: row['lng'] as double,
              address: row['address'] as String,
            )))
        .toList();

    state = places;
  }

  void addPlace(String title, File image, PlaceLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final filename = path.basename(image.path); //gets the filename
    final copiedImage = await image.copy('${appDir.path}/$filename');
    final newPlace =
        Places(title: title, image: copiedImage, location: location);

    final db = await _getDatabase();
    db.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'lat': newPlace.location.latitude,
      'lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });
    //join method  is used to construct a path...user_placesDb is the databse name
    //onCreate has a function which will be executed when the db is created for the first time
    //the func allows us to set up some initial work

    state = [newPlace, ...state]; //adding new place at the start of the list
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Places>>(
  (ref) => UserPlacesNotifier(),
);
