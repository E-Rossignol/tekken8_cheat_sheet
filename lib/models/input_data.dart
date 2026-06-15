/// Represents an input token (code) and its associated asset path.
/// Used to map string codes to icon images in the UI.
class InputData {
  /// Input code string (ex: "1", "f", "ZEN").
  final String code;

  /// Asset path to the icon representing the code.
  final String assetPath;

  const InputData(this.code, this.assetPath);
}
