import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pixabay_image.dart';

class PixabayService {
  static const String apiKey = '52541097-b5343ef9bedd2e14a9f1a377d';
  static const String baseUrl = 'https://pixabay.com/api/';

  Future<List<PixabayImage>> fetchTrendingImages({
    int perPage = 50,
    String? searchQuery,
  }) async {
    String url = '$baseUrl?key=$apiKey&order=popular&per_page=$perPage';

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final encodedQuery = Uri.encodeComponent(searchQuery);
      url += '&q=$encodedQuery';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> hits = data['hits'];
      return hits.map((json) => PixabayImage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }
}