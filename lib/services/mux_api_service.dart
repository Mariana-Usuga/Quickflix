import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mux_videos_app/models/mux_asset.dart';

class MuxApiService {
  static const String baseUrl = 'https://api.mux.com/video/v1';
  
  String? _tokenId;
  String? _tokenSecret;

  MuxApiService() {
    _tokenId = dotenv.env['MUX_TOKEN_ID'];
    _tokenSecret = dotenv.env['MUX_TOKEN_SECRET'];
  }

  String _getAuthHeader() {
    if (_tokenId == null || _tokenSecret == null) {
      throw Exception('Mux credentials not found. Please check your .env file.');
    }
    final credentials = '$_tokenId:$_tokenSecret';
    final bytes = utf8.encode(credentials);
    final base64Str = base64.encode(bytes);
    return 'Basic $base64Str';
  }

  Future<MuxAssetListResponse> listAssets({
    int? limit,
    int? page,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/assets').replace(
        queryParameters: {
          if (limit != null) 'limit': limit.toString(),
          if (page != null) 'page': page.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': _getAuthHeader(),
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return MuxAssetListResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load assets: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching assets: $e');
    }
  }
}

