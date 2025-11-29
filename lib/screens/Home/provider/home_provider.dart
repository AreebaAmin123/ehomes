import 'package:flutter/foundation.dart';
import '../../../models/home screen/slider_model.dart';
import '../../../models/home screen/tag_model.dart';
import '../../../models/home screen/tag_product_model.dart';
import '../../../services/home_service.dart';
import '../../../models/home screen/exclusive_product_model.dart';
import '../../../Utils/constants/my_sharePrefs.dart';
import '../../../services/custom_image_provider.dart';
import 'dart:convert';
import 'dart:async';

class HomeProvider with ChangeNotifier {
  final HomeServices _homeServices = HomeServices();
  final MySharedPrefs _prefs = MySharedPrefs();

  // Add request tracking
  DateTime? _lastSliderFetch;
  DateTime? _lastTagsFetch;
  DateTime? _lastProductsFetch;
  final Map<int, DateTime> _lastTagProductsFetch = {};
  static const Duration _minFetchInterval = Duration(minutes: 30);

  // Add loading states
  bool _isLoadingSlider = false;
  bool _isLoadingTags = false;
  bool _isLoadingProducts = false;
  bool get isLoadingSlider => _isLoadingSlider;
  bool get isLoadingTags => _isLoadingTags;
  bool get isLoadingProducts => _isLoadingProducts;

  SliderModel? _sliderModel;
  SliderModel? get sliderModel => _sliderModel;

  TagModel? _tagModel;
  TagModel? get tagModel => _tagModel;

  TagProductModel? _tagProductModel;
  TagProductModel? get tagProductModel => _tagProductModel;

  int _selectedTagIndex = 0;
  int get selectedTagIndex => _selectedTagIndex;

  List<ExclusiveProductModel>? _exclusiveProducts;
  List<ExclusiveProductModel>? get exclusiveProducts => _exclusiveProducts;

  bool _exclusiveLoading = false;
  bool get exclusiveLoading => _exclusiveLoading;

  bool _shouldRefetch(DateTime? lastFetch) {
    if (lastFetch == null) return true;
    final timeSinceLastFetch = DateTime.now().difference(lastFetch);
    final shouldRefetch = timeSinceLastFetch > _minFetchInterval;
    if (!shouldRefetch) {
      debugPrint(
          'Skipping fetch - last fetch was ${timeSinceLastFetch.inMinutes} minutes ago');
    }
    return shouldRefetch;
  }

  int? getTagId() {
    if (_tagModel == null ||
        _tagModel!.tags == null ||
        _selectedTagIndex >= _tagModel!.tags!.length) {
      return null;
    }
    return _tagModel!.tags![_selectedTagIndex].id;
  }

  void selectTag(int value) {
    _selectedTagIndex = value;
    notifyListeners();
  }

  bool isSelected(int index) {
    return _selectedTagIndex == index;
  }

  // /// fetch the category name and icon
  // Future<void> getCategory() async {
  //   try {
  //     HomeCategoryModel response = await _homeServices.getCategory();
  //     if (response.success == true && response.categories!.isNotEmpty) {
  //       _homeCategoryModel = response;
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  /// Initialize home page data with caching and compute
  Future<void> initializeHomeData() async {
    debugPrint('Initializing home page data...');

    try {
      // Clear expired cache in the background
      unawaited(_prefs.clearExpiredCache().then((_) async {
        final stats = await _prefs.getCacheStats();
        debugPrint('Cache stats after cleanup:');
        debugPrint('Total entries: ${stats['total_entries']}');
        debugPrint('Valid entries: ${stats['valid_entries']}');
        debugPrint('Expired entries: ${stats['expired_entries']}');
        debugPrint(
            'Cache size: ${(stats['cache_size_bytes'] / 1024).toStringAsFixed(2)} KB');
      }));

      // Fetch all data in parallel using compute for JSON parsing
      await Future.wait([
        _getSliderDataInBackground(),
        _getTagsDataInBackground(),
        _getExclusiveProductsInBackground(),
      ], eagerError: true);

      debugPrint('Home page data initialization complete');
    } catch (e) {
      debugPrint('Error during home page initialization: $e');
    }
  }

  Future<void> _getSliderDataInBackground() async {
    try {
      final cachedData = await _prefs.getSliderData();
      if (cachedData != null) {
        // Parse JSON in background
        final model = await compute(_parseSliderData, cachedData);
        if (model != null) {
          _sliderModel = model;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error in slider background task: $e');
    }
  }

  Future<void> _getTagsDataInBackground() async {
    try {
      final cachedData = await _prefs.getTagsData();
      if (cachedData != null) {
        // Parse JSON in background
        final model = await compute(_parseTagsData, cachedData);
        if (model != null) {
          _tagModel = model;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error in tags background task: $e');
    }
  }

  Future<void> _getExclusiveProductsInBackground() async {
    try {
      final cachedData = await _prefs.getExclusiveProductsData();
      if (cachedData != null) {
        // Parse JSON in background
        final products = await compute(_parseExclusiveProducts, cachedData);
        if (products != null) {
          _exclusiveProducts = products;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error in exclusive products background task: $e');
    }
  }

  // Static methods for compute operations
  static SliderModel? _parseSliderData(String jsonStr) {
    try {
      final response = jsonDecode(jsonStr);
      if (response['success'] == true) {
        return SliderModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error parsing slider data: $e');
    }
    return null;
  }

  static TagModel? _parseTagsData(String jsonStr) {
    try {
      final response = jsonDecode(jsonStr);
      if (response['success'] == true) {
        return TagModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error parsing tags data: $e');
    }
    return null;
  }

  static List<ExclusiveProductModel>? _parseExclusiveProducts(String jsonStr) {
    try {
      final response = jsonDecode(jsonStr);
      if (response['success'] == true) {
        return (response['products'] as List)
            .map((product) => ExclusiveProductModel.fromJson(product))
            .toList();
      }
    } catch (e) {
      debugPrint('Error parsing exclusive products: $e');
    }
    return null;
  }

  /// Process and validate image URLs
  String _processImageUrl(String? url) {
    return CustomNetworkImageProvider.fixImageUrl(url);
  }

  /// Fetch Slider Data with caching and compute
  Future<void> getSlider() async {
    if (_isLoadingSlider) {
      debugPrint('Slider fetch already in progress');
      return;
    }

    if (!_shouldRefetch(_lastSliderFetch)) {
      debugPrint('Skipping slider fetch - too soon since last fetch');
      return;
    }

    try {
      _isLoadingSlider = true;
      notifyListeners();

      debugPrint('Fetching slider data...');

      // Try to get cached data first
      final cachedData = await _prefs.getSliderData();
      if (cachedData != null) {
        final response = jsonDecode(cachedData);
        if (response['success'] == true) {
          _sliderModel = SliderModel.fromJson(response);
          debugPrint('Slider data loaded from cache');
          notifyListeners();
          return;
        }
      }

      // If no cache or cache invalid, fetch from API
      debugPrint('Fetching slider data from API...');
      final response = await _homeServices.getSlider();
      if (response.sliders?.isNotEmpty ?? false) {
        // Process image URLs before caching
        for (var slider in response.sliders!) {
          slider.sliderImage = _processImageUrl(slider.sliderImage);
          debugPrint('Processed slider image: ${slider.sliderImage}');
        }

        _sliderModel = response;
        // Cache the response
        await _prefs.saveSliderData(jsonEncode(response.toJson()));
        debugPrint('Slider data fetched from API and cached');

        // Update last fetch time
        _lastSliderFetch = DateTime.now();

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching slider data: $e');
    } finally {
      _isLoadingSlider = false;
      notifyListeners();
    }
  }

  /// Fetch Tags with caching and debouncing
  Future<void> getTags() async {
    if (!_shouldRefetch(_lastTagsFetch)) {
      debugPrint('Skipping tags fetch - too soon since last fetch');
      return;
    }

    if (_isLoadingTags) {
      debugPrint('Tags fetch already in progress');
      return;
    }

    try {
      _isLoadingTags = true;
      notifyListeners();

      debugPrint('Fetching tags...');
      _lastTagsFetch = DateTime.now();

      // Try to get cached data first
      final cachedData = await _prefs.getTagsData();
      if (cachedData != null) {
        final response = jsonDecode(cachedData);
        if (response['success'] == true) {
          _tagModel = TagModel.fromJson(response);
          debugPrint(
              'Tags loaded from cache (${_tagModel?.tags?.length ?? 0} tags)');
          notifyListeners();
          return;
        }
      }

      // If no cache or cache invalid, fetch from API
      debugPrint('Fetching tags from API...');
      final response = await _homeServices.getTags();
      if (response.tags?.isNotEmpty ?? false) {
        _tagModel = response;
        // Cache the response
        await _prefs.saveTagsData(jsonEncode(response.toJson()));
        debugPrint(
            'Tags fetched from API and cached (${response.tags?.length ?? 0} tags)');
        notifyListeners();
      } else {
        debugPrint('No tags found from API');
      }
    } catch (e) {
      debugPrint('Error fetching tags: $e');
      rethrow;
    } finally {
      _isLoadingTags = false;
      notifyListeners();
    }
  }

  /// Fetch Tag Products with caching and debouncing
  Future<void> getTagProducts(int tagId) async {
    final cacheKey = 'tag_products_${tagId}_cache';

    if (!_shouldRefetch(_lastTagProductsFetch[tagId])) {
      debugPrint(
          'Skipping products fetch for tag $tagId - too soon since last fetch');
      return;
    }

    if (_isLoadingProducts) {
      debugPrint('Products fetch already in progress');
      return;
    }

    try {
      _isLoadingProducts = true;
      notifyListeners();

      debugPrint('Fetching products for tag $tagId...');
      _lastTagProductsFetch[tagId] = DateTime.now();

      // Try to get cached data first
      final cachedData = await _prefs.getString(cacheKey);
      if (cachedData != null) {
        try {
        final response = jsonDecode(cachedData);
          if (response['success'] == true && response['timestamp'] != null) {
            final timestamp = DateTime.parse(response['timestamp']);
            if (DateTime.now().difference(timestamp) < Duration(hours: 12)) {
              _tagProductModel = TagProductModel.fromJson(response['data']);
          debugPrint(
                  'Products loaded from cache for tag $tagId (${_tagProductModel?.products?.length ?? 0} products)');
          notifyListeners();
          return;
            } else {
              debugPrint('Cache expired for tag $tagId');
            }
          }
        } catch (e) {
          debugPrint('Error parsing cached data: $e');
        }
      }

      // If no cache, cache expired, or invalid, fetch from API
      debugPrint('Fetching products from API for tag $tagId...');
      final response = await _homeServices.getProduct();
      if (response.products?.isNotEmpty ?? false) {
        _tagProductModel = response;

        // Cache the response with timestamp
        await _prefs.setString(
            cacheKey,
            jsonEncode({
              'success': true,
              'timestamp': DateTime.now().toIso8601String(),
              'data': response.toJson(),
            }));

        debugPrint(
            'Products fetched from API and cached for tag $tagId (${response.products?.length ?? 0} products)');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  /// Fetch Exclusive Products with caching
  Future<void> getExclusiveProducts() async {
    _exclusiveLoading = true;
    notifyListeners();

    try {
      debugPrint('Fetching exclusive products...');

      // Try to get cached data first
      final cachedData = await _prefs.getExclusiveProductsData();
      if (cachedData != null) {
        final response = jsonDecode(cachedData);
        if (response['success'] == true) {
          _exclusiveProducts = (response['products'] as List)
              .map((product) => ExclusiveProductModel.fromJson(product))
              .toList();
          debugPrint(
              'Exclusive products loaded from cache (${_exclusiveProducts?.length ?? 0} products)');
          notifyListeners();
          return;
        }
      }

      // If no cache or cache invalid, fetch from API
      debugPrint('Fetching exclusive products from API...');
      final response = await _homeServices.getExclusiveProducts();
      if (response.isNotEmpty) {
        _exclusiveProducts = response;
        // Cache the response
        await _prefs.saveExclusiveProductsData(jsonEncode({
          'success': true,
          'products': response.map((product) => product.toJson()).toList(),
        }));
        debugPrint(
            'Exclusive products fetched from API and cached (${response.length} products)');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching exclusive products: $e');
      _exclusiveProducts = [];
    } finally {
      _exclusiveLoading = false;
      notifyListeners();
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    debugPrint('Clearing home page cache...');
    await _prefs.clearHomePageCache();
    debugPrint('Home page cache cleared');
  }
}
