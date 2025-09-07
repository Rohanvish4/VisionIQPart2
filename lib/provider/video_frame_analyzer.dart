import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../provider/background_verification_provider.dart';

class VideoFrameAnalyzer {
  /// Pick video and analyze frames for background verification
  static Future<void> pickVideoAndAnalyzeFrames({
    required BackgroundVerificationProvider verificationProvider,
  }) async {
    try {
      verificationProvider.updateStatus('Selecting video file...');

      final ImagePicker picker = ImagePicker();
      final XFile? videoFile = await picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (videoFile == null) {
        verificationProvider.updateStatus('No video selected');
        return;
      }

      verificationProvider.updateStatus('Extracting video frames...');

      // Extract thumbnail/frame from video
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 1080,
        quality: 90,
        timeMs: 1000, // Extract frame at 1 second
      );

      if (thumbnailPath != null) {
        final frameFile = File(thumbnailPath);

        // Analyze the extracted frame
        await verificationProvider.analyzeSingleFrame(
          frameFile,
          sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        // Clean up the temporary file
        if (await frameFile.exists()) {
          await frameFile.delete();
        }
      } else {
        verificationProvider.updateStatus('Failed to extract frame from video');
      }
    } catch (e) {
      verificationProvider.updateStatus('Error: ${e.toString()}');
    }
  }

  /// Pick image and analyze for background verification
  static Future<void> pickImageAndAnalyze({
    required BackgroundVerificationProvider verificationProvider,
  }) async {
    try {
      verificationProvider.updateStatus('Selecting image file...');

      final ImagePicker picker = ImagePicker();
      final XFile? imageFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxHeight: 1080,
        maxWidth: 1080,
      );

      if (imageFile == null) {
        verificationProvider.updateStatus('No image selected');
        return;
      }

      final file = File(imageFile.path);

      // Analyze the selected image
      await verificationProvider.analyzeSingleFrame(
        file,
        sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      verificationProvider.updateStatus('Error: ${e.toString()}');
    }
  }

  /// Extract multiple frames from video for comprehensive analysis
  static Future<List<File>> extractMultipleFrames(
    String videoPath, {
    int frameCount = 3,
    int intervalSeconds = 5,
  }) async {
    final frames = <File>[];

    for (int i = 0; i < frameCount; i++) {
      try {
        final timeMs = i * intervalSeconds * 1000;
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: videoPath,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 1080,
          quality: 90,
          timeMs: timeMs,
        );

        if (thumbnailPath != null) {
          frames.add(File(thumbnailPath));
        }
      } catch (e) {
        debugPrint('Failed to extract frame $i: $e');
      }
    }

    return frames;
  }

  /// Analyze multiple frames from video
  static Future<void> pickVideoAndAnalyzeMultipleFrames({
    required BackgroundVerificationProvider verificationProvider,
    int frameCount = 3,
    int intervalSeconds = 5,
  }) async {
    try {
      verificationProvider.updateStatus('Selecting video file...');

      final ImagePicker picker = ImagePicker();
      final XFile? videoFile = await picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (videoFile == null) {
        verificationProvider.updateStatus('No video selected');
        return;
      }

      verificationProvider.updateStatus('Extracting multiple frames...');

      // Extract multiple frames
      final frames = await extractMultipleFrames(
        videoFile.path,
        frameCount: frameCount,
        intervalSeconds: intervalSeconds,
      );

      if (frames.isNotEmpty) {
        // Analyze multiple frames
        await verificationProvider.analyzeVideoFrames(
          frames,
          sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        // Clean up temporary files
        for (final frame in frames) {
          if (await frame.exists()) {
            await frame.delete();
          }
        }
      } else {
        verificationProvider.updateStatus(
          'Failed to extract frames from video',
        );
      }
    } catch (e) {
      verificationProvider.updateStatus('Error: ${e.toString()}');
    }
  }

  /// Get temporary directory for frame storage
  static Future<Directory> getTemporaryDirectory() async {
    // In a real implementation, you'd use path_provider
    // For now, return a temporary directory path
    return Directory.systemTemp;
  }
}

/// Integration with existing VideoAnalyzer for backward compatibility
class VideoAnalyzerExtended {
  /// Enhanced video analysis with background verification
  static Future<void> analyzeVideoWithBackgroundVerification({
    required String videoPath,
    required BackgroundVerificationProvider verificationProvider,
  }) async {
    try {
      verificationProvider.updateStatus('Starting enhanced video analysis...');

      // Extract frame for background verification
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await VideoFrameAnalyzer.getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 1080,
        quality: 90,
        timeMs: 2000, // Extract frame at 2 seconds
      );

      if (thumbnailPath != null) {
        final frameFile = File(thumbnailPath);

        // Perform background verification analysis
        await verificationProvider.analyzeSingleFrame(
          frameFile,
          sessionId: 'enhanced_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Clean up
        if (await frameFile.exists()) {
          await frameFile.delete();
        }
      }
    } catch (e) {
      verificationProvider.updateStatus(
        'Enhanced analysis failed: ${e.toString()}',
      );
    }
  }
}
