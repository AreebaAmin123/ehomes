import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class MySharedPrefs {
  static const String _userKey = 'user_data';
  static const String _loginStatusKey = 'is_logged_in';
  static const String _billingDetailsKey = 'billing_details';

  // Home Page Cache Keys
  static const String _sliderCacheKey = 'home_slider_cache';
  static const String _sliderCacheTimeKey = 'home_slider_cache_time';
  static const String _tagsCacheKey = 'home_tags_cache';
  static const String _tagsCacheTimeKey = 'home_tags_cache_time';
  static const String _productsCacheKey = 'home_products_cache';
  static const String _productsCacheTimeKey = 'home_products_cache_time';
  static const String _exclusiveProductsCacheKey =
      'home_exclusive_products_cache';
  static const String _exclusiveProductsCacheTimeKey =
      'home_exclusive_products_cache_time';

  // Vendor Cache Keys
  static const String _vendorsCacheKey = 'vendors_cache';
  static const String _vendorsCacheTimeKey = 'vendors_cache_time';
  static const String _vendorProductsCacheKeyPrefix = 'vendor_products_cache_';
  static const String _vendorProductsCacheTimeKeyPrefix =
      'vendor_products_cache_time_';

  // Categories Cache Keys
  static const String _categoriesCacheKey = 'categories_cache';
  static const String _categoriesCacheTimeKey = 'categories_cache_time';

  // SubCategories Cache Keys (using category ID as part of key)
  static const String _subCategoriesCacheKeyPrefix = 'subcategories_cache_';
  static const String _subCategoriesCacheTimeKeyPrefix =
      'subcategories_cache_time_';

  // Products Cache Keys (using subcategory ID as part of key)
  static const String _productsCacheKeyPrefix = 'products_cache_';
  static const String _productsCacheTimeKeyPrefix = 'products_cache_time_';

  // Brand Products Cache Keys
  static const String _brandProductsCacheKeyPrefix = 'brand_products_cache_';
  static const String _brandProductsCacheTimeKeyPrefix =
      'brand_products_cache_time_';

  // Cache Duration (12 hours in milliseconds)
  static const int _cacheDuration = 12 * 60 * 60 * 1000;

  // Search Results Cache Keys
  static const String _searchResultsCacheKeyPrefix = 'search_results_cache_';
  static const String _searchResultsCacheTimeKeyPrefix =
      'search_results_cache_time_';

  static const String _cartCacheKey = 'cart_data';
  static const String _cartCacheTimeKey = 'cart_data_time';

  static SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// ✅ Stores user data (e.g., user JSON)
  Future<void> setUserData(String userData) async {
    await _init();
    await _prefs?.setString(_userKey, userData);
    await _prefs?.setBool(_loginStatusKey, true);
  }

  /// ✅ Retrieves stored user data
  Future<String?> getUserData() async {
    await _init();
    return _prefs?.getString(_userKey);
  }

  /// ✅ Checks if user is logged in
  Future<bool> isUserLoggedIn() async {
    await _init();
    return _prefs?.getBool(_loginStatusKey) ?? false;
  }

  /// ✅ Logs out the user (Clears session data)
  Future<void> clearUserSession() async {
    await _init();
    await _prefs?.remove(_userKey);
    await _prefs?.setBool(_loginStatusKey, false);
  }

  Future<void> saveBillingDetails(Map<String, String> details) async {
    await _init();
    await _prefs?.setString(_billingDetailsKey, jsonEncode(details));
  }

  Future<Map<String, String>?> getBillingDetails() async {
    await _init();
    final jsonString = _prefs?.getString(_billingDetailsKey);
    if (jsonString == null) return null;
    final Map<String, dynamic> map = jsonDecode(jsonString);
    return map.map((k, v) => MapEntry(k, v.toString()));
  }

  /// ✅ Generic method to check if cache is valid
  Future<bool> isCacheValid(String timeKey) async {
    await _init();
    final timestamp = _prefs?.getInt(timeKey);
    if (timestamp == null) {
      debugPrint('Cache miss: No timestamp found for $timeKey');
      return false;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final isValid = now - timestamp <= _cacheDuration;
    debugPrint(
        'Cache ${isValid ? 'hit' : 'expired'} for $timeKey (age: ${(now - timestamp) ~/ 1000}s)');
    return isValid;
  }

  /// ✅ Generic method to save data with timestamp and logging
  Future<void> _saveDataWithTimestamp(
      String dataKey, String timeKey, String data) async {
    await _init();
    await _prefs?.setString(dataKey, data);
    await _prefs?.setInt(timeKey, DateTime.now().millisecondsSinceEpoch);
    debugPrint('Cache saved: $dataKey');
  }

  /// ✅ Generic method to get cached data if not expired with logging
  Future<String?> _getCachedData(String dataKey, String timeKey) async {
    await _init();
    final timestamp = _prefs?.getInt(timeKey);
    final data = _prefs?.getString(dataKey);

    if (timestamp == null || data == null) {
      debugPrint('Cache miss: No data found for $dataKey');
      return null;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - timestamp > _cacheDuration) {
      debugPrint(
          'Cache expired for $dataKey (age: ${(now - timestamp) ~/ 1000}s)');
      // Cache expired, clear it
      await _prefs?.remove(dataKey);
      await _prefs?.remove(timeKey);
      return null;
    }

    debugPrint('Cache hit: $dataKey (age: ${(now - timestamp) ~/ 1000}s)');
    return data;
  }

  /// ✅ Save Home Page Slider Data
  Future<void> saveSliderData(String sliderData) async {
    await _saveDataWithTimestamp(
        _sliderCacheKey, _sliderCacheTimeKey, sliderData);
  }

  /// ✅ Get Cached Slider Data
  Future<String?> getSliderData() async {
    return _getCachedData(_sliderCacheKey, _sliderCacheTimeKey);
  }

  /// ✅ Save Home Page Tags Data
  Future<void> saveTagsData(String tagsData) async {
    await _saveDataWithTimestamp(_tagsCacheKey, _tagsCacheTimeKey, tagsData);
  }

  /// ✅ Get Cached Tags Data
  Future<String?> getTagsData() async {
    return _getCachedData(_tagsCacheKey, _tagsCacheTimeKey);
  }

  /// ✅ Save Home Page Products Data
  Future<void> saveProductsData(String productsData) async {
    await _saveDataWithTimestamp(
        _productsCacheKey, _productsCacheTimeKey, productsData);
  }

  /// ✅ Get Cached Products Data
  Future<String?> getProductsData() async {
    return _getCachedData(_productsCacheKey, _productsCacheTimeKey);
  }

  /// ✅ Save Home Page Exclusive Products Data
  Future<void> saveExclusiveProductsData(String exclusiveProductsData) async {
    await _saveDataWithTimestamp(_exclusiveProductsCacheKey,
        _exclusiveProductsCacheTimeKey, exclusiveProductsData);
  }

  /// ✅ Get Cached Exclusive Products Data
  Future<String?> getExclusiveProductsData() async {
    return _getCachedData(
        _exclusiveProductsCacheKey, _exclusiveProductsCacheTimeKey);
  }

  /// ✅ Clear all Home Page cache
  Future<void> clearHomePageCache() async {
    await _init();
    await _prefs?.remove(_sliderCacheKey);
    await _prefs?.remove(_sliderCacheTimeKey);
    await _prefs?.remove(_tagsCacheKey);
    await _prefs?.remove(_tagsCacheTimeKey);
    await _prefs?.remove(_productsCacheKey);
    await _prefs?.remove(_productsCacheTimeKey);
    await _prefs?.remove(_exclusiveProductsCacheKey);
    await _prefs?.remove(_exclusiveProductsCacheTimeKey);
  }

  /// ✅ Save Categories Data
  Future<void> saveCategoriesData(String categoriesData) async {
    await _saveDataWithTimestamp(
        _categoriesCacheKey, _categoriesCacheTimeKey, categoriesData);
  }

  /// ✅ Get Cached Categories Data
  Future<String?> getCategoriesData() async {
    return _getCachedData(_categoriesCacheKey, _categoriesCacheTimeKey);
  }

  /// ✅ Save SubCategories Data for a specific category
  Future<void> saveSubCategoriesData(
      String categoryId, String subCategoriesData) async {
    final dataKey = '$_subCategoriesCacheKeyPrefix$categoryId';
    final timeKey = '$_subCategoriesCacheTimeKeyPrefix$categoryId';
    await _saveDataWithTimestamp(dataKey, timeKey, subCategoriesData);
  }

  /// ✅ Get Cached SubCategories Data for a specific category
  Future<String?> getSubCategoriesData(String categoryId) async {
    final dataKey = '$_subCategoriesCacheKeyPrefix$categoryId';
    final timeKey = '$_subCategoriesCacheTimeKeyPrefix$categoryId';
    return _getCachedData(dataKey, timeKey);
  }

  /// ✅ Save Products Data for a specific subcategory
  Future<void> saveSubcategoryProductsData(
      String subcategoryId, String productsData) async {
    final dataKey = '$_productsCacheKeyPrefix$subcategoryId';
    final timeKey = '$_productsCacheTimeKeyPrefix$subcategoryId';
    await _saveDataWithTimestamp(dataKey, timeKey, productsData);
  }

  /// ✅ Get Cached Products Data for a specific subcategory
  Future<String?> getSubcategoryProductsData(String subcategoryId) async {
    final dataKey = '$_productsCacheKeyPrefix$subcategoryId';
    final timeKey = '$_productsCacheTimeKeyPrefix$subcategoryId';
    return _getCachedData(dataKey, timeKey);
  }

  /// ✅ Clear all Categories related cache
  Future<void> clearCategoriesCache() async {
    await _init();
    final prefs = _prefs;

    // Clear main categories cache
    await prefs?.remove(_categoriesCacheKey);
    await prefs?.remove(_categoriesCacheTimeKey);

    // Get all keys
    final allKeys = prefs?.getKeys() ?? {};

    // Clear all subcategories cache
    for (final key in allKeys) {
      if (key.startsWith(_subCategoriesCacheKeyPrefix) ||
          key.startsWith(_subCategoriesCacheTimeKeyPrefix)) {
        await prefs?.remove(key);
      }
    }

    // Clear all products cache
    for (final key in allKeys) {
      if (key.startsWith(_productsCacheKeyPrefix) ||
          key.startsWith(_productsCacheTimeKeyPrefix)) {
        await prefs?.remove(key);
      }
    }
  }

  /// ✅ Clear expired cache entries
  Future<void> clearExpiredCache() async {
    await _init();
    final prefs = _prefs;
    final now = DateTime.now().millisecondsSinceEpoch;
    int clearedCount = 0;

    final allKeys = prefs?.getKeys() ?? {};
    for (final key in allKeys) {
      if (key.endsWith('_cache_time')) {
        final timestamp = prefs?.getInt(key);
        if (timestamp != null && now - timestamp > _cacheDuration) {
          final dataKey = key.replaceAll('_cache_time', '_cache');
          await prefs?.remove(dataKey);
          await prefs?.remove(key);
          clearedCount++;
        }
      }
    }

    if (clearedCount > 0) {
      debugPrint('Cleared $clearedCount expired cache entries');
    }
  }

  /// ✅ Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    await _init();
    final prefs = _prefs;
    final now = DateTime.now().millisecondsSinceEpoch;
    final stats = <String, dynamic>{
      'total_entries': 0,
      'valid_entries': 0,
      'expired_entries': 0,
      'cache_size_bytes': 0,
    };

    final allKeys = prefs?.getKeys() ?? {};
    for (final key in allKeys) {
      if (key.endsWith('_cache')) {
        stats['total_entries']++;
        final timeKey = '${key}_time';
        final timestamp = prefs?.getInt(timeKey);
        if (timestamp != null) {
          if (now - timestamp <= _cacheDuration) {
            stats['valid_entries']++;
          } else {
            stats['expired_entries']++;
          }
        }
        final data = prefs?.getString(key);
        if (data != null) {
          stats['cache_size_bytes'] += data.length;
        }
      }
    }

    return stats;
  }

  /// ✅ Save Vendors Data
  Future<void> saveVendorsData(String vendorsData) async {
    await _saveDataWithTimestamp(
        _vendorsCacheKey, _vendorsCacheTimeKey, vendorsData);
  }

  /// ✅ Get Cached Vendors Data
  Future<String?> getVendorsData() async {
    return _getCachedData(_vendorsCacheKey, _vendorsCacheTimeKey);
  }

  /// ✅ Save Vendor Products Data
  Future<void> saveVendorProductsData(
      String vendorId, String productsData) async {
    final dataKey = '$_vendorProductsCacheKeyPrefix$vendorId';
    final timeKey = '$_vendorProductsCacheTimeKeyPrefix$vendorId';
    await _saveDataWithTimestamp(dataKey, timeKey, productsData);
  }

  /// ✅ Get Cached Vendor Products Data
  Future<String?> getVendorProductsData(String vendorId) async {
    final dataKey = '$_vendorProductsCacheKeyPrefix$vendorId';
    final timeKey = '$_vendorProductsCacheTimeKeyPrefix$vendorId';
    return _getCachedData(dataKey, timeKey);
  }

  /// ✅ Clear Vendor Cache
  Future<void> clearVendorCache() async {
    await _init();
    final prefs = _prefs;

    // Clear vendors list cache
    await prefs?.remove(_vendorsCacheKey);
    await prefs?.remove(_vendorsCacheTimeKey);

    // Clear all vendor products cache
    final allKeys = prefs?.getKeys() ?? {};
    for (final key in allKeys) {
      if (key.startsWith(_vendorProductsCacheKeyPrefix) ||
          key.startsWith(_vendorProductsCacheTimeKeyPrefix)) {
        await prefs?.remove(key);
      }
    }
    debugPrint('Vendor cache cleared');
  }

  /// ✅ Save Brand Products Data
  Future<void> saveBrandProductsData(
      String brandName, String productsData) async {
    final dataKey = '$_brandProductsCacheKeyPrefix$brandName';
    final timeKey = '$_brandProductsCacheTimeKeyPrefix$brandName';
    await _saveDataWithTimestamp(dataKey, timeKey, productsData);
  }

  /// ✅ Get Cached Brand Products Data
  Future<String?> getBrandProductsData(String brandName) async {
    final dataKey = '$_brandProductsCacheKeyPrefix$brandName';
    final timeKey = '$_brandProductsCacheTimeKeyPrefix$brandName';
    return _getCachedData(dataKey, timeKey);
  }

  /// ✅ Clear Brand Products Cache
  Future<void> clearBrandProductsCache() async {
    await _init();
    final prefs = _prefs;
    final allKeys = prefs?.getKeys() ?? {};
    for (final key in allKeys) {
      if (key.startsWith(_brandProductsCacheKeyPrefix) ||
          key.startsWith(_brandProductsCacheTimeKeyPrefix)) {
        await prefs?.remove(key);
      }
    }
    debugPrint('Brand products cache cleared');
  }

  /// ✅ Save Search Results Data
  Future<void> saveSearchResults(String query, String searchData) async {
    final dataKey = '$_searchResultsCacheKeyPrefix$query';
    final timeKey = '$_searchResultsCacheTimeKeyPrefix$query';
    await _saveDataWithTimestamp(dataKey, timeKey, searchData);
  }

  /// ✅ Get Cached Search Results Data
  Future<String?> getSearchResults(String query) async {
    final dataKey = '$_searchResultsCacheKeyPrefix$query';
    final timeKey = '$_searchResultsCacheTimeKeyPrefix$query';
    return _getCachedData(dataKey, timeKey);
  }

  /// ✅ Get string data from SharedPreferences
  Future<String?> getString(String key) async {
    await _init();
    return _prefs?.getString(key);
  }

  /// ✅ Set string data in SharedPreferences
  Future<void> setString(String key, String value) async {
    await _init();
    await _prefs?.setString(key, value);
  }

  /// ✅ Remove data from SharedPreferences
  Future<void> remove(String key) async {
    await _init();
    await _prefs?.remove(key);
  }

  /// ✅ Save Cart Data
  Future<void> saveCartData(String cartData) async {
    await _saveDataWithTimestamp(_cartCacheKey, _cartCacheTimeKey, cartData);
  }

  /// ✅ Get Cached Cart Data
  Future<String?> getCartData() async {
    return _getCachedData(_cartCacheKey, _cartCacheTimeKey);
  }

  /// ✅ Clear all data
  Future<void> clearAll() async {
    await _init();
    await _prefs?.clear();
  }

  // Promotion Data
  Future<void> savePromotionData(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('promotion_cache', data);
    await prefs.setString(
        'promotion_cache_timestamp', DateTime.now().toIso8601String());
  }

  Future<String?> getPromotionData() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString('promotion_cache_timestamp');
    if (timestamp != null) {
      final lastFetch = DateTime.parse(timestamp);
      if (DateTime.now().difference(lastFetch) < const Duration(hours: 1)) {
        return prefs.getString('promotion_cache');
      }
    }
    return null;
  }

  // Profile Data
  Future<void> saveProfileData(int userId, String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_cache_$userId', data);
    await prefs.setString(
        'profile_cache_${userId}_timestamp', DateTime.now().toIso8601String());
  }

  Future<String?> getProfileData(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString('profile_cache_${userId}_timestamp');
    if (timestamp != null) {
      final lastFetch = DateTime.parse(timestamp);
      if (DateTime.now().difference(lastFetch) < const Duration(minutes: 30)) {
        return prefs.getString('profile_cache_$userId');
      }
    }
    return null;
  }
}
