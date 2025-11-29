
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

import '../../../services/search_bar_services.dart';
import '../../../models/search_model.dart';
import '../../../Utils/constants/my_sharePrefs.dart';

class SearchBarProvider extends ChangeNotifier {
  final SearchBarServices _searchBarServices = SearchBarServices();
  final MySharedPrefs _prefs = MySharedPrefs();

  SearchModel? _searchModel;
  SearchModel? get searchModel => _searchModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  List<String> _categories = ['All'];
  List<String> get categories => _categories;

  // Add request tracking
  final Map<String, DateTime> _lastSearches = {};
  static const Duration _minSearchInterval = Duration(seconds: 2);

  bool _shouldSearch(String query) {
    final lastSearch = _lastSearches[query];
    if (lastSearch == null) return true;
    return DateTime.now().difference(lastSearch) > _minSearchInterval;
  }

  Future<void> searchQuery(String query) async {
    if (query.isEmpty) {
      _searchModel = null;
      _error = null;
      notifyListeners();
      return;
    }

    if (!_shouldSearch(query)) {
      debugPrint('Skipping search - too soon since last query');
      return;
    }

    if (_isLoading) {
      debugPrint('Search already in progress');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Convert query to lowercase for case-insensitive search
      final lowercaseQuery = query.toLowerCase();

      // Get search results
      final results = await _searchBarServices.searchQuery(lowercaseQuery);

      if (results != null) {
        // Create a new SearchModel instance to avoid modifying the original
        final updatedResults = SearchModel(
          query: lowercaseQuery,
          products: results.products,
          brands: results.brands,
          categories: results.categories,
        );

        // Filter results based on selected category
        if (_selectedCategory != 'All' && updatedResults.products != null) {
          final filteredProducts = updatedResults.products!.where((product) {
            return product.categoryName?.toLowerCase() ==
                    _selectedCategory.toLowerCase() ||
                product.subCategoryName?.toLowerCase() ==
                    _selectedCategory.toLowerCase();
          }).toList();
          updatedResults.products = filteredProducts;
        }

        // Update categories list
        _categories = ['All'];
        final products = updatedResults.products;
        if (products != null) {
          final uniqueCategories = products
              .map((p) => p.categoryName)
              .where((c) => c != null)
              .toSet()
              .toList();
          final uniqueSubCategories = products
              .map((p) => p.subCategoryName)
              .where((c) => c != null)
              .toSet()
              .toList();

          _categories.addAll(
            [...uniqueCategories, ...uniqueSubCategories]
                .where((c) => c != null)
                .map((c) => c!)
                .toSet()
                .toList()
                .cast<String>(),
          );
        }

        _searchModel = updatedResults;

        // Cache the response
        await _prefs.saveSearchResults(
            query, jsonEncode(_searchModel?.toJson()));
        debugPrint(
            'Search results fetched from API and cached (${_searchModel?.products?.length ?? 0} results)');
      } else {
        _searchModel = null;
      }
    } catch (e) {
      debugPrint('Error during search: $e');
      _error = e.toString();
      _searchModel = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    // Re-run search with current query if any
    if (_searchModel != null) {
      final currentQuery = _searchModel?.query ?? '';
      searchQuery(currentQuery);
    }
  }

  void clearSearch() {
    _searchModel = null;
    _selectedCategory = 'All';
    _error = null;
    notifyListeners();
  }

  // Static methods for compute isolation
  static SearchModel? _parseSearchJson(String jsonStr) {
    final data = jsonDecode(jsonStr);
    return data != null ? SearchModel.fromJson(data) : null;
  }

  static SearchModel _parseSearchResponse(dynamic response) {
    return response;
  }
}
