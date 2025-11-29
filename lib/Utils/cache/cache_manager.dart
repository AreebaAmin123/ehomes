import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/my_sharePrefs.dart';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final MySharedPrefs _prefs = MySharedPrefs();
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _lastFetchTimes = {};

  static const Duration defaultCacheDuration = Duration(hours: 12);
  static const Duration minRequestInterval = Duration(seconds: 5);

  /// Check if a new request should be allowed
  bool shouldAllowNewRequest(String key) {
    final lastRequest = _lastFetchTimes[key];
    if (lastRequest == null) return true;
    return DateTime.now().difference(lastRequest) > minRequestInterval;
  }

  /// Update request timestamp
  void updateRequestTime(String key) {
    _lastFetchTimes[key] = DateTime.now();
  }

  /// Get data from cache with validation
  Future<T?> get<T>(String key, {Duration? duration}) async {
    duration ??= defaultCacheDuration;

    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      final cacheEntry = _memoryCache[key];
      if (cacheEntry != null &&
          cacheEntry['timestamp'] != null &&
          DateTime.now().difference(cacheEntry['timestamp']) < duration) {
        debugPrint('📦 Cache hit (memory): $key');
        return cacheEntry['data'] as T?;
      }
    }

    // Check persistent storage
    try {
      final jsonStr = await _prefs.getString(key);
      if (jsonStr != null) {
        final data = jsonDecode(jsonStr);
        if (data['timestamp'] != null) {
          final timestamp = DateTime.parse(data['timestamp']);
          if (DateTime.now().difference(timestamp) < duration) {
            // Update memory cache
            _memoryCache[key] = {
              'data': data['data'],
              'timestamp': timestamp,
            };
            debugPrint('📦 Cache hit (persistent): $key');
            return data['data'] as T?;
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error reading cache: $e');
    }

    return null;
  }

  /// Save data to cache
  Future<void> set<T>(String key, T data) async {
    final timestamp = DateTime.now();

    // Save to memory cache
    _memoryCache[key] = {
      'data': data,
      'timestamp': timestamp,
    };

    // Save to persistent storage
    try {
      final jsonData = {
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };
      await _prefs.setString(key, jsonEncode(jsonData));
      debugPrint('💾 Cache saved: $key');
    } catch (e) {
      debugPrint('❌ Error saving cache: $e');
    }
  }

  /// Clear specific cache entry
  Future<void> clear(String key) async {
    _memoryCache.remove(key);
    _lastFetchTimes.remove(key);
    await _prefs.remove(key);
    debugPrint('🗑️ Cache cleared: $key');
  }

  /// Clear all cache
  Future<void> clearAll() async {
    _memoryCache.clear();
    _lastFetchTimes.clear();
    await _prefs.clearAll();
    debugPrint('🗑️ All cache cleared');
  }

  /// Check if cache exists and is valid
  Future<bool> isValid(String key, {Duration? duration}) async {
    duration ??= defaultCacheDuration;

    // Check memory cache
    if (_memoryCache.containsKey(key)) {
      final cacheEntry = _memoryCache[key];
      if (cacheEntry != null &&
          cacheEntry['timestamp'] != null &&
          DateTime.now().difference(cacheEntry['timestamp']) < duration) {
        return true;
      }
    }

    // Check persistent storage
    try {
      final jsonStr = await _prefs.getString(key);
      if (jsonStr != null) {
        final data = jsonDecode(jsonStr);
        if (data['timestamp'] != null) {
          final timestamp = DateTime.parse(data['timestamp']);
          return DateTime.now().difference(timestamp) < duration;
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking cache validity: $e');
    }

    return false;
  }
}
