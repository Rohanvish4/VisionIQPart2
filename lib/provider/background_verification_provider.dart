import 'dart:io';
import 'package:get/get.dart';
import '../model/verification_models.dart';
import '../service/background_verification_service.dart';

class BackgroundVerificationProvider extends GetxController {
  // Observable state variables
  final Rx<BackgroundVerificationResult?> _currentResult =
      Rx<BackgroundVerificationResult?>(null);
  final RxList<BackgroundVerificationResult> _analysisHistory =
      <BackgroundVerificationResult>[].obs;
  final RxBool _isAnalyzing = false.obs;
  final RxString _currentStatus = ''.obs;
  final Rx<FraudDetectionSummary?> _fraudSummary = Rx<FraudDetectionSummary?>(
    null,
  );
  final Rx<DeclaredData?> _declaredData = Rx<DeclaredData?>(null);

  // Getters
  BackgroundVerificationResult? get currentResult => _currentResult.value;
  List<BackgroundVerificationResult> get analysisHistory =>
      _analysisHistory.toList();
  bool get isAnalyzing => _isAnalyzing.value;
  String get currentStatus => _currentStatus.value;
  FraudDetectionSummary? get fraudSummary => _fraudSummary.value;
  DeclaredData? get declaredData => _declaredData.value;

  // Set declared data for comparison
  void setDeclaredData(DeclaredData data) {
    _declaredData.value = data;
    _currentStatus.value = 'Declared data set for verification';
  }

  // Update status message
  void updateStatus(String message) {
    _currentStatus.value = message;
  }

  // Simulate analysis result for demo purposes
  void simulateAnalysisResult(BackgroundVerificationResult result) {
    _currentResult.value = result;
    _analysisHistory.add(result);
    _updateFraudSummary();
    _currentStatus.value = 'Demo analysis completed';
  }

  // Analyze a single video frame
  Future<void> analyzeSingleFrame(File videoFrame, {String? sessionId}) async {
    try {
      _isAnalyzing.value = true;
      _currentStatus.value = 'Analyzing video frame...';

      final result = await BackgroundVerificationService.analyzeVideoFrame(
        videoFrame,
        declaredData: _declaredData.value,
        sessionId: sessionId,
      );

      if (result != null) {
        _currentResult.value = result;
        _analysisHistory.add(result);
        _updateFraudSummary();
        _currentStatus.value = 'Analysis completed successfully';
      } else {
        _currentStatus.value = 'Analysis failed - please try again';
      }
    } catch (e) {
      _currentStatus.value = 'Error during analysis: ${e.toString()}';
    } finally {
      _isAnalyzing.value = false;
    }
  }

  // Analyze multiple frames from a video
  Future<void> analyzeVideoFrames(
    List<File> frames, {
    String? sessionId,
  }) async {
    try {
      _isAnalyzing.value = true;
      _currentStatus.value = 'Analyzing ${frames.length} video frames...';

      final results = await BackgroundVerificationService.analyzeBatchFrames(
        frames,
        declaredData: _declaredData.value,
        sessionId: sessionId,
      );

      if (results.isNotEmpty) {
        _analysisHistory.addAll(results);
        _currentResult.value = results.last; // Use the last result as current
        _updateFraudSummary();
        _currentStatus.value =
            'Batch analysis completed: ${results.length} frames processed';
      } else {
        _currentStatus.value = 'Batch analysis failed - no results obtained';
      }
    } catch (e) {
      _currentStatus.value = 'Error during batch analysis: ${e.toString()}';
    } finally {
      _isAnalyzing.value = false;
    }
  }

  // Update fraud detection summary
  void _updateFraudSummary() {
    if (_analysisHistory.isNotEmpty) {
      _fraudSummary.value = BackgroundVerificationService.generateFraudSummary(
        _analysisHistory,
      );
    }
  }

  // Get environment mismatch information
  EnvironmentMismatchInfo? getEnvironmentMismatch() {
    final result = _currentResult.value;
    if (result == null || _declaredData.value == null) return null;

    final declared = _declaredData.value!.declaredEnvironment;
    final detected = result.environmentAnalysis.detectedEnvironment;

    if (declared != detected && declared != EnvironmentType.unknown) {
      return EnvironmentMismatchInfo(
        declaredEnvironment: declared,
        detectedEnvironment: detected,
        confidence: result.environmentAnalysis.confidence,
        severity: _calculateEnvironmentMismatchSeverity(declared, detected),
      );
    }

    return null;
  }

  // Calculate severity of environment mismatch
  double _calculateEnvironmentMismatchSeverity(
    EnvironmentType declared,
    EnvironmentType detected,
  ) {
    // Define severity matrix
    const Map<String, double> severityMatrix = {
      'home-shop': 0.9,
      'home-office': 0.6,
      'home-warehouse': 0.8,
      'office-shop': 0.7,
      'office-home': 0.6,
      'shop-home': 0.9,
      'shop-office': 0.7,
      'warehouse-home': 0.8,
      'warehouse-office': 0.7,
    };

    final key = '${declared.toString()}-${detected.toString()}';
    return severityMatrix[key] ?? 0.5;
  }

  // Get object quantity mismatches
  List<ObjectQuantityMismatch> getObjectQuantityMismatches() {
    final result = _currentResult.value;
    if (result == null || _declaredData.value == null) return [];

    final mismatches = <ObjectQuantityMismatch>[];

    for (final declaredItem in _declaredData.value!.declaredItems) {
      final detectedObjects = result.detectedObjects
          .where(
            (obj) => obj.objectName.toLowerCase().contains(
              declaredItem.itemName.toLowerCase(),
            ),
          )
          .toList();

      if (detectedObjects.isEmpty) {
        // Item declared but not found
        mismatches.add(
          ObjectQuantityMismatch(
            itemName: declaredItem.itemName,
            declaredQuantity: declaredItem.expectedQuantity,
            detectedQuantity: 0,
            mismatchType: QuantityMismatchType.missing,
            severity: 0.8,
          ),
        );
      } else {
        final totalDetected = detectedObjects
            .map((obj) => obj.detectedQuantity)
            .reduce((a, b) => a + b);

        if (totalDetected != declaredItem.expectedQuantity) {
          mismatches.add(
            ObjectQuantityMismatch(
              itemName: declaredItem.itemName,
              declaredQuantity: declaredItem.expectedQuantity,
              detectedQuantity: totalDetected,
              mismatchType: totalDetected > declaredItem.expectedQuantity
                  ? QuantityMismatchType.excess
                  : QuantityMismatchType.deficit,
              severity: _calculateQuantityMismatchSeverity(
                declaredItem.expectedQuantity,
                totalDetected,
              ),
            ),
          );
        }
      }
    }

    return mismatches;
  }

  // Calculate quantity mismatch severity
  double _calculateQuantityMismatchSeverity(int declared, int detected) {
    if (declared == 0) return detected > 0 ? 0.7 : 0.0;

    final ratio = (detected - declared).abs() / declared;
    return (ratio * 0.8).clamp(0.0, 1.0);
  }

  // Get risk indicators
  List<RiskIndicator> getRiskIndicators() {
    final result = _currentResult.value;
    if (result == null) return [];

    final indicators = <RiskIndicator>[];

    // Environment confidence indicator
    if (result.environmentAnalysis.confidence < 0.6) {
      indicators.add(
        RiskIndicator(
          type: RiskIndicatorType.lowConfidence,
          description:
              'Low confidence in environment detection (${(result.environmentAnalysis.confidence * 100).toInt()}%)',
          severity: 1.0 - result.environmentAnalysis.confidence,
        ),
      );
    }

    // Environment mismatch indicator
    final envMismatch = getEnvironmentMismatch();
    if (envMismatch != null) {
      indicators.add(
        RiskIndicator(
          type: RiskIndicatorType.environmentMismatch,
          description:
              'Environment mismatch: declared ${envMismatch.declaredEnvironment} but detected ${envMismatch.detectedEnvironment}',
          severity: envMismatch.severity,
        ),
      );
    }

    // Object quantity mismatches
    final objMismatches = getObjectQuantityMismatches();
    for (final mismatch in objMismatches) {
      indicators.add(
        RiskIndicator(
          type: RiskIndicatorType.quantityMismatch,
          description:
              '${mismatch.itemName}: declared ${mismatch.declaredQuantity}, detected ${mismatch.detectedQuantity}',
          severity: mismatch.severity,
        ),
      );
    }

    return indicators..sort((a, b) => b.severity.compareTo(a.severity));
  }

  // Clear all data
  void clearData() {
    _currentResult.value = null;
    _analysisHistory.clear();
    _fraudSummary.value = null;
    _declaredData.value = null;
    _currentStatus.value = '';
  }

  // Generate verification report
  VerificationReport generateReport() {
    return VerificationReport(
      sessionId: _currentResult.value?.sessionId ?? 'unknown',
      analysisTimestamp: DateTime.now(),
      analysisCount: _analysisHistory.length,
      currentResult: _currentResult.value,
      fraudSummary: _fraudSummary.value,
      environmentMismatch: getEnvironmentMismatch(),
      objectMismatches: getObjectQuantityMismatches(),
      riskIndicators: getRiskIndicators(),
      overallRecommendation:
          _fraudSummary.value?.recommendation ?? 'No Analysis',
    );
  }
}

// Supporting classes for the provider
class EnvironmentMismatchInfo {
  final EnvironmentType declaredEnvironment;
  final EnvironmentType detectedEnvironment;
  final double confidence;
  final double severity;

  EnvironmentMismatchInfo({
    required this.declaredEnvironment,
    required this.detectedEnvironment,
    required this.confidence,
    required this.severity,
  });
}

class ObjectQuantityMismatch {
  final String itemName;
  final int declaredQuantity;
  final int detectedQuantity;
  final QuantityMismatchType mismatchType;
  final double severity;

  ObjectQuantityMismatch({
    required this.itemName,
    required this.declaredQuantity,
    required this.detectedQuantity,
    required this.mismatchType,
    required this.severity,
  });
}

enum QuantityMismatchType { missing, deficit, excess }

class RiskIndicator {
  final RiskIndicatorType type;
  final String description;
  final double severity;

  RiskIndicator({
    required this.type,
    required this.description,
    required this.severity,
  });
}

enum RiskIndicatorType {
  environmentMismatch,
  quantityMismatch,
  lowConfidence,
  unexpectedObject,
}

class VerificationReport {
  final String sessionId;
  final DateTime analysisTimestamp;
  final int analysisCount;
  final BackgroundVerificationResult? currentResult;
  final FraudDetectionSummary? fraudSummary;
  final EnvironmentMismatchInfo? environmentMismatch;
  final List<ObjectQuantityMismatch> objectMismatches;
  final List<RiskIndicator> riskIndicators;
  final String overallRecommendation;

  VerificationReport({
    required this.sessionId,
    required this.analysisTimestamp,
    required this.analysisCount,
    required this.currentResult,
    required this.fraudSummary,
    required this.environmentMismatch,
    required this.objectMismatches,
    required this.riskIndicators,
    required this.overallRecommendation,
  });
}
