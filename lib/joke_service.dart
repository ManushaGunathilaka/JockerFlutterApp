import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class JokeService {
  final Dio _dio = Dio();

  Future<List<dynamic>> fetchJokesFromApi() async {
    try {
      final response = await _dio.get(
        'https://v2.jokeapi.dev/joke/Any?amount=5',
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['jokes'];
      } else {
        throw Exception('Failed to load jokes');
      }
    } catch (e) {
      throw Exception('Error fetching jokes: $e');
    }
  }

  Future<void> saveJokesToCache(List<dynamic> jokes) async {
    final prefs = await SharedPreferences.getInstance();
    final jokesString = jsonEncode(jokes);
    await prefs.setString('cachedJokes', jokesString);
  }

  Future<List<dynamic>> fetchJokesFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jokesString = prefs.getString('cachedJokes');
    if (jokesString != null) {
      return jsonDecode(jokesString);
    }
    return [];
  }
}
