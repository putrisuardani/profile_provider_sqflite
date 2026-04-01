import 'package:flutter/material.dart';
import '../helpers/db_helper.dart'; // jangan lupa ini!
import '../models/profile.dart';

class ProfileProvider with ChangeNotifier {
  List<Profile> _profiles = [];
  List<Profile> get profiles => _profiles;

  Profile _myProfile = Profile(
    name: 'Luh Gede Putri',
    phone: '+6281337136811',
    profilePhoto: 'https://i.pravatar.cc/150?img=25',
    coverPhoto: 'https://picsum.photos/600/200?xrandom=25',
    quote:
        '“Jangan jadi orang lucu karena ujung-ujungnya cuma enak dijadiin temen.”',
  );
  Profile get myProfile => _myProfile;

  void updateMyProfile(Profile profile) {
    _myProfile = profile;
    notifyListeners();
  }

  Future<void> fetchProfiles() async {
    try {
      _profiles = await DBHelper.getProfiles();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching profiles: $e');
    }
  }

  Future<void> addProfile() async {
    try {
      final int random = DateTime.now().millisecondsSinceEpoch % 100;
      final profileWithoutID = Profile(
        name: "Putri $random",
        phone: "+62812$random",
        profilePhoto: "https://i.pravatar.cc/150?img=$random",
        coverPhoto: "https://picsum.photos/600/200?random=$random",
        quote: "Semangat terus yaa 💪",
        id: null,
      );
      final int insertedId = await DBHelper.insertProfile(profileWithoutID);
      final newProfile = profileWithoutID.copyWith(id: insertedId);

      DBHelper.insertProfile(newProfile);
      _profiles.add(newProfile);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding profile: $e');
    }
  }

  Future<void> updateProfile(int id, Profile profile) async {
    final db = await DBHelper.database;
    await db.update(
      'profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    await fetchProfiles();
  }

  Future<void> deleteProfile(int id) async {
    final db = await DBHelper.database;
    await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
    _profiles.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
