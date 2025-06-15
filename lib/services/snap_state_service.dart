import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ecosnap_1/models/snap_model.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import package

/// A service to manage snap state, eco-score, and interact with the Gemini API.
class SnapStateService {
  SnapStateService._internal();
  static final SnapStateService instance = SnapStateService._internal();

  static const String _ecoCountKey = 'ecoActionsCount';
  late SharedPreferences _prefs;

  // IMPORTANT: Replace with your actual Gemini API Key.
  final String _apiKey = "AIzaSyBUifFJ7loGJIWqx8Ce4ynJmi7aL71Arxg";

  // State for eco-friendly actions
  int ecoActionsCount = 0;
  final int maxEcoActions = 4; // Updated max actions to 4

  final Map<String, List<Snap>> _unreadSnaps = {};

  /// ** NEW: Initialize the service and load data from storage **
  /// This should be called once when the app starts.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    ecoActionsCount = _prefs.getInt(_ecoCountKey) ?? 0;
  }

  /// ** NEW: Save data to storage **
  Future<void> _saveEcoActionsCount() async {
    await _prefs.setInt(_ecoCountKey, ecoActionsCount);
  }

  /// Analyzes the snap, updates the eco-action score, and adds the snap to recipients.
  Future<void> addSnap(Set<String> users, Snap snap) async {
    bool isEcoFriendly = await _isSnapEcoFriendly(snap.imagePath, snap.userDescription);
    snap.aiDescription = isEcoFriendly ? "Eco-friendly action! +1 Point" : "A nice snap!";

    // If the action is eco-friendly, increment the score by 1 and save it.
    if (isEcoFriendly && ecoActionsCount < maxEcoActions) {
      ecoActionsCount++;
      await _saveEcoActionsCount(); // Save the new score to local storage
    }

    for (final user in users) {
      _unreadSnaps.putIfAbsent(user, () => []);
      _unreadSnaps[user]!.add(snap);
    }
  }

  /// Calls the Gemini API to check if a snap contains an eco-friendly action.
  Future<bool> _isSnapEcoFriendly(String imagePath, String? userDescription) async {
    try {
      final imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final url = Uri.parse("https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$_apiKey");

      String prompt = """
      Analyze the image and description for eco-friendly actions (reusing, reducing waste, etc.).
      Respond ONLY with a valid JSON object with one key: "isEcoFriendly" (boolean).
      Description: "${userDescription ?? 'None'}"
      """;

      final requestBody = jsonEncode({
        "contents": [{"role": "user", "parts": [{"inline_data": {"mime_type": "image/jpeg", "data": base64Image}}, {"text": prompt}]}],
        "generationConfig": {"responseMimeType": "application/json"}
      });

      final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: requestBody);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data["candidates"]?[0]["content"]?["parts"]?[0]["text"]?.trim() ?? '{}';
        print("✅ Gemini Response JSON: $content");
        final result = jsonDecode(content);
        return result['isEcoFriendly'] ?? false;
      } else {
        print("❌ Gemini API Error: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error during API call: $e");
      return false;
    }
  }
  
  bool hasUnreadSnaps(String userName) => _unreadSnaps[userName]?.isNotEmpty ?? false;
  List<Snap>? getUnreadSnaps(String userName) => _unreadSnaps[userName];
  void clearSnaps(String userName) => _unreadSnaps.remove(userName);
}
