import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LocalLlmService {
  static final LocalLlmService _instance = LocalLlmService._internal();
  factory LocalLlmService() => _instance;
  LocalLlmService._internal();

  Llama? _llama;
  bool isLoaded = false;

  Future<void> loadModel(String filePath, {int contextSize = 2048}) async {
    // Copy file to app's internal storage (required for some Android versions)
    final appDir = await getApplicationDocumentsDirectory();
    final destPath = '${appDir.path}/tars_model.gguf';
    
    if (!await File(destPath).exists()) {
      await File(filePath).copy(destPath);
    }

    _llama = Llama();
    await _llama!.loadModel(
      modelPath: destPath,
      contextSize: contextSize,
      temperature: 0.7, // Tied to the sarcasm slider later
      topK: 40,
      topP: 0.95,
    );
    isLoaded = true;
  }

  Future<String> generate(String prompt) async {
    if (_llama == null || !isLoaded) return "Error: Model not loaded.";
    // This runs on the native thread. Use .generateSync() or .generate() with await.
    return await _llama!.generate(prompt);
  }

  void dispose() {
    _llama?.close();
  }
}
