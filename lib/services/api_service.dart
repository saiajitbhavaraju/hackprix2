// lib/services/api_service.dart
// FINAL VERSION WITH LOGGING FOR DEBUGGING

import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for print statements
import 'package:http/http.dart' as http;
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/organisation.dart';
import '../models/charity.dart';

class ApiService {
  // === URL DEFINITIONS ===
  static const String _friendBaseUrl = 'http://65.2.83.136:3000/api';
  static const String _storiesBaseUrl = 'https://33ijxn2vqj.execute-api.ap-south-1.amazonaws.com/Prod/api';

  final String _mockUserId = 'dabe0791-c4cc-40d0-9dad-383202e70b46';
  String get currentUserId => _mockUserId;

  // ===============================================
  // === Functions using your FRIEND'S backend ===
  // ===============================================

  // --- Chat Functions ---
  Future<List<Conversation>> getConversations() async {
    final uri = Uri.parse('$_friendBaseUrl/chat/conversations');
    final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: json.encode({'userId': _mockUserId}));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Conversation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  Future<List<Message>> getMessages(String otherUserId) async {
    final uri = Uri.parse('$_friendBaseUrl/chat/messages/history');
    final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: json.encode({'userId': _mockUserId, 'otherUserId': otherUserId}));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }
  
  Future<void> sendMessage(String receiverId, String content) async {
      final uri = Uri.parse('$_friendBaseUrl/chat/messages');
      final response = await http.post(uri, headers: { 'Content-Type': 'application/json' }, body: json.encode({ 'senderId': _mockUserId, 'receiverId': receiverId, 'content': content, }), );
      if (response.statusCode != 201) {
          throw Exception('Failed to send message: ${response.body}');
      }
  }

  // --- Organisation Functions ---
  Future<List<Organisation>> listOrganizations() async {
    final uri = Uri.parse('$_friendBaseUrl/orgs/');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> orgsJson = json.decode(response.body);
      return orgsJson.map((json) => Organisation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load organizations');
    }
  }

  Future<void> signupForOrganization(String orgId) async {
    final uri = Uri.parse('$_friendBaseUrl/orgs/$orgId/signup');
    final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: json.encode({'userId': _mockUserId}));
    if (response.statusCode != 200 && response.statusCode != 409) {
      throw Exception('Failed to join organization');
    }
  }

  Future<Set<String>> getJoinedOrganizationIds() async {
    final uri = Uri.parse('$_friendBaseUrl/orgs/user/$currentUserId');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> orgIdsJson = json.decode(response.body);
      return orgIdsJson.cast<String>().toSet();
    } else {
      throw Exception('Failed to load joined organizations');
    }
  }

  // --- Charity Functions ---
  Future<List<Charity>> listCharities() async {
    final uri = Uri.parse('$_friendBaseUrl/charities');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Charity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load charities');
    }
  }

  Future<Set<String>> getJoinedCharityIds() async {
    final uri = Uri.parse('$_friendBaseUrl/charities/user/$currentUserId');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.cast<String>().toSet();
    } else {
      throw Exception('Failed to load joined charities');
    }
  }

  Future<void> signupForCharity(String charityId) async {
    final uri = Uri.parse('$_friendBaseUrl/charities/$charityId/signup');
    final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: json.encode({'userId': _mockUserId}));
    if (response.statusCode != 200 && response.statusCode != 409) {
      throw Exception('Failed to join charity');
    }
  }

  // ===============================================
  // === Functions using YOUR new AWS backend ===
  // ===============================================
  
  // THIS IS THE FUNCTION WITH LOGGING ADDED
  Future<List<Map<String, dynamic>>> getStories() async {
    debugPrint('--- [ApiService] Attempting to fetch stories... ---');
    
    final uri = Uri.parse('$_storiesBaseUrl/stories');
    
    debugPrint('--- [ApiService] Requesting URL: ${uri.toString()} ---');

    try {
      final response = await http.get(uri);

      debugPrint('--- [ApiService] Response Status Code: ${response.statusCode} ---');
      debugPrint('--- [ApiService] Response Body: ${response.body} ---');

      if (response.statusCode == 200) {
        final List<dynamic> storiesJson = json.decode(response.body);
        return storiesJson.cast<Map<String, dynamic>>().toList();
      } else {
        throw Exception('Failed to load stories: Status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('--- [ApiService] An error occurred during the network call: ${e.toString()} ---');
      rethrow;
    }
  }

  Future<void> buyStory(String itemId) async {
    final uri = Uri.parse('$_storiesBaseUrl/stories/buy/$itemId');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': _mockUserId}),
    );
    if (response.statusCode != 200) {
      final errorBody = json.decode(response.body);
      throw Exception('Failed to buy story: ${errorBody['message']}');
    }
  }
}