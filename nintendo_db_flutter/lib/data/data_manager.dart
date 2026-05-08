import 'dart:convert';
import 'package:flutter/services.dart';

class DataManager {
  List<dynamic> characters = [];
  List<dynamic> consoles = [];
  List<dynamic> games = [];

  Future<void> loadData() async {
   
    final rawCharacters = await rootBundle.loadString("assets/data/characters.json");
    final rawConsoles = await rootBundle.loadString("assets/data/consoles.json");
    final rawGames = await rootBundle.loadString("assets/data/games.json");

    characters = jsonDecode(rawCharacters);
    consoles = jsonDecode(rawConsoles);
    games = jsonDecode(rawGames);
  }
}