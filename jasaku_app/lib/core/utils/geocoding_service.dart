import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static Future<String> reverse(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );
      final res = await http.get(url, headers: {
        'User-Agent': 'JasakuApp/1.0',
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['display_name'] ?? '$lat, $lng';
      }
    } catch (_) {}
    return '$lat, $lng';
  }
}
