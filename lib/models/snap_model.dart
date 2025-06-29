/// Represents a single snap, containing the image and an optional description.
class Snap {
  final String imagePath;
  final String? userDescription;
  String? aiDescription; // To store the description generated by Gemini

  Snap({
    required this.imagePath,
    this.userDescription,
    this.aiDescription,
  });
}
