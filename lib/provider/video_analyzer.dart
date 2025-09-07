import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../model/gemini_model.dart';
import '../service/gemini_service.dart';
import '../component/kcustom_loading.dart';
import 'video_provider.dart';

class VideoAnalyzer {
  static Future<void> pickVideo({
    required VideoProvider videoProvider,
    required BuildContext context,
  }) async {
    var status = await Permission.videos.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final video = await picker.pickVideo(source: ImageSource.gallery);
      log("Video path: ${video?.path}");

      if (video != null) {
        final frame = await VideoThumbnail.thumbnailFile(
          video: video.path,
          imageFormat: ImageFormat.JPEG,
          timeMs: 2000,
          quality: 80,
        );
        log('Extracted frame path: $frame');
        final file = File(frame!);
        if (context.mounted) CustomPopups.showCustomLoading(context);
        GeminiModel? model = await GeminiService.extractDataFromImage(file);
        if (context.mounted) Navigator.pop(context);
        if (model == null) return;
        videoProvider.updateGeminiModel(newModel: model);
      }
    }
  }
}
