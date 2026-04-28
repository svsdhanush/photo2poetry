import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'poem_response.dart';

class PoemApiService {
  // Fetched from .env during runtime. Throws if missing.
  static String get apiUrl => dotenv.get('API_URL');

  static final ValueNotifier<int?> remainingRequests = ValueNotifier<int?>(null);
  static final ValueNotifier<int?> resetAt = ValueNotifier<int?>(null);

  static Future<PoemResponse> generatePoem(
    String imagePath,
    int poemLength,
    String userTheme, {
    String? roughDraft,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Attach the physical image file natively
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Send bounds and themes implicitly as fields
      request.fields['poem_length'] = poemLength.toString();
      request.fields['user_theme'] = userTheme;

      // Optional rough draft — if provided, backend refines instead of generating fresh
      if (roughDraft != null && roughDraft.isNotEmpty) {
        request.fields['rough_draft'] = roughDraft;
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Parse rate limit headers
      int? remaining;
      int? reset;
      final remainingHeader = response.headers['x-ratelimit-remaining'];
      final resetHeader = response.headers['x-ratelimit-reset'];

      if (remainingHeader != null) {
        remaining = int.tryParse(remainingHeader);
        remainingRequests.value = remaining;
      }
      if (resetHeader != null) {
        reset = int.tryParse(resetHeader);
        resetAt.value = reset;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        String poemText = "";
        try {
          final decoded = jsonDecode(responseBody);
          if (decoded is Map && decoded.containsKey('poem')) {
            poemText = _parseEscapes(decoded['poem'].toString());
          } else {
            poemText = _parseEscapes(decoded.toString());
          }
        } catch (e) {
          poemText = _parseEscapes(responseBody);
        }
        return PoemResponse(
          poem: poemText,
          remainingRequests: remaining,
          resetAt: reset,
        );
      } else if (response.statusCode == 429) {
        throw const FormatException('USER_LIMIT_REACHED');
      } else if (response.statusCode == 503) {
        throw const FormatException('PROVIDER_BUSY');
      } else {
        throw Exception(
          'Server failed with status ${response.statusCode}: $responseBody',
        );
      }
    } on SocketException {
      throw const FormatException('NETWORK_ERROR');
    } catch (e) {
      throw Exception('Failed to communicate with AI: $e');
    }
  }

  static String _parseEscapes(String text) {
    // Robust parsing: strip down raw escape sequences to physical newlines.
    return text.replaceAll('\\n', '\n').replaceAll('\\"', '"');
  }
}
