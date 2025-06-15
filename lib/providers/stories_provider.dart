// lib/providers/stories_provider.dart
// FINAL AND CORRECTED VERSION

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StoriesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State for fetching the list of stories
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => _items;
  
  // --- ADDED: State for the "buy" action ---
  bool _isBuying = false;
  bool get isBuying => _isBuying;
  // -----------------------------------------

  Future<void> fetchStories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _apiService.getStories();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- ADDED: The missing buyStory method ---
  /// Calls the ApiService to purchase an item and manages loading state.
  /// Throws an exception if the purchase fails, which the UI can catch.
  Future<void> buyStory(String itemId) async {
    _isBuying = true;
    notifyListeners();

    try {
      // The API service will handle the actual network call
      await _apiService.buyStory(itemId);
    } catch (e) {
      // Re-throw the error so the UI can display a specific message
      rethrow;
    } finally {
      _isBuying = false;
      notifyListeners();
    }
  }
  // ------------------------------------------
}