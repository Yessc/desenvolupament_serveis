import 'dart:convert';
import 'package:flutter/services.dart';

class DataManager {
  List<dynamic> characters = [];
  List<dynamic> consoles = [];
  List<dynamic> games = [];

  Future<void> loadData() async {
    final rawCharacters = await rootBundle.loadString("assets/characters.json");
    final rawConsoles = await rootBundle.loadString("assets/consoles.json");
    final rawGames = await rootBundle.loadString("assets/games.json");

    characters = jsonDecode(rawCharacters);
    consoles = jsonDecode(rawConsoles);
    games = jsonDecode(rawGames);
  }
}