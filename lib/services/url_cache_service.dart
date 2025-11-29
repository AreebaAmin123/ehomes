import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class UrlCacheService {
  static final UrlCacheService _instance = UrlCacheService._internal();
  factory UrlCacheService() => _instance;
  UrlCacheService._internal();

  Database? _db;
  final Map<String, String> _memoryCache = {};
  static const _tableName = 'url_cache';

  Future<void> init() async {
    if (_db != null) return;

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'url_cache.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            base_url TEXT PRIMARY KEY,
            working_url TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );

    // Clean old entries on init
    await _cleanOldEntries();
  }

  Future<void> _cleanOldEntries() async {
    final db = _db;
    if (db == null) return;

    final thirtyMinutesAgo = DateTime.now()
        .subtract(const Duration(minutes: 30))
        .millisecondsSinceEpoch;
    await db.transaction((txn) async {
      await txn.delete(
        _tableName,
        where: 'timestamp < ?',
        whereArgs: [thirtyMinutesAgo],
      );
    });
  }

  Future<String> findWorkingImageUrl(
      String baseUrl, List<String> formats) async {
    // Check memory cache first
    final cachedUrl = _memoryCache[baseUrl];
    if (cachedUrl != null) {
      return cachedUrl;
    }

    // Initialize database if needed
    await init();
    final db = _db;
    if (db == null) {
      throw Exception('Database not initialized');
    }

    // Check database cache
    try {
      final result = await db.transaction((txn) async {
        final results = await txn.query(
          _tableName,
          where: 'base_url = ?',
          whereArgs: [baseUrl],
          limit: 1,
        );

        if (results.isNotEmpty) {
          final timestamp = results.first['timestamp'] as int;
          if (DateTime.now().millisecondsSinceEpoch - timestamp <
              const Duration(minutes: 30).inMilliseconds) {
            final workingUrl = results.first['working_url'] as String;
            _memoryCache[baseUrl] = workingUrl;
            return workingUrl;
          }
        }
        return null;
      });

      if (result != null) {
        return result;
      }
    } catch (e) {
      debugPrint('Error reading from cache: $e');
    }

    // If not in cache, check URLs in isolate
    final workingUrl =
        await compute(_checkUrls, _CheckUrlsParam(baseUrl, formats));

    if (workingUrl != null) {
      // Cache the working URL
      _memoryCache[baseUrl] = workingUrl;
      try {
        await db.transaction((txn) async {
          await txn.insert(
            _tableName,
            {
              'base_url': baseUrl,
              'working_url': workingUrl,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        });
      } catch (e) {
        debugPrint('Error writing to cache: $e');
      }
      return workingUrl;
    }

    throw Exception('No working image URL found for $baseUrl');
  }

  Future<void> clearCache() async {
    _memoryCache.clear();
    final db = _db;
    if (db != null) {
      await db.transaction((txn) async {
        await txn.delete(_tableName);
      });
    }
  }
}

class _CheckUrlsParam {
  final String baseUrl;
  final List<String> formats;

  _CheckUrlsParam(this.baseUrl, this.formats);
}

Future<String?> _checkUrls(_CheckUrlsParam param) async {
  final client = http.Client();
  try {
    for (final format in param.formats) {
      final url = '${param.baseUrl}$format';
      try {
        final uri = Uri.parse(url);
        final response = await client.get(
          uri,
          headers: {
            'Accept': 'image/*',
            'User-Agent': 'Flutter/1.0',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final contentType =
              response.headers['content-type']?.toLowerCase() ?? '';
          if (!contentType.contains('image/')) {
            continue;
          }

          // Validate image data
          try {
            final result =
                await compute(_validateImageData, response.bodyBytes);
            if (result) {
              return url;
            }
          } catch (e) {
            debugPrint('Error validating image data for $url: $e');
            continue;
          }
        }
      } catch (e) {
        debugPrint('Error checking URL $url: $e');
        continue;
      }
    }
    return null;
  } finally {
    client.close();
  }
}

Future<bool> _validateImageData(Uint8List bytes) async {
  try {
    // Check for common image format headers
    if (bytes.length < 12) return false;

    // Check for JPEG header (FF D8)
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return true;
    }

    // Check for PNG header (89 50 4E 47 0D 0A 1A 0A)
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return true;
    }

    // Check for WebP header (RIFF .... WEBP)
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return true;
    }

    return false;
  } catch (e) {
    debugPrint('Error in _validateImageData: $e');
    return false;
  }
}
