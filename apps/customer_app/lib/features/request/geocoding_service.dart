import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceResult {
  final String label;
  final double lat;
  final double lng;
  const PlaceResult({required this.label, required this.lat, required this.lng});
}

/// Free, keyless geocoding via OpenStreetMap's Nominatim — matches the
/// "Google Maps or Mapbox abstraction" spec requirement without needing an
/// API key for this demo. Swapping to a paid provider later only touches
/// this file.
class GeocodingService {
  static const _headers = {'User-Agent': 'MadadgaarDemoApp/1.0 (hackathon demo)'};

  Future<List<PlaceResult>> search(String query) async {
    if (query.trim().length < 3) return [];
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'jsonv2',
      'countrycodes': 'pk',
      'limit': '6',
    });
    try {
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return [];
      final list = jsonDecode(res.body) as List;
      return list
          .map((e) => PlaceResult(
                label: e['display_name'] as String,
                lat: double.parse(e['lat'] as String),
                lng: double.parse(e['lon'] as String),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> reverse(double lat, double lng) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': '$lat',
      'lon': '$lng',
      'format': 'jsonv2',
    });
    try {
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      return decoded['display_name'] as String?;
    } catch (_) {
      return null;
    }
  }
}
