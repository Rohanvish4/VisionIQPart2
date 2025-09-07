import 'package:get/get.dart';
import '../model/gemini_model.dart';

class VideoProvider extends GetxController {
  final _geminiModel = GeminiModel.empty().obs;

  GeminiModel get geminiModel => _geminiModel.value;

  void updateGeminiModel({required GeminiModel newModel}) {
    _geminiModel.value = newModel;
    update();
  }

  void clear() {
    _geminiModel.value = GeminiModel.empty();
    update();
  }
}
