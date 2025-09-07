import 'dart:developer' as developer;
import 'dart:io';
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import '../model/verification_models.dart';

class BackgroundVerificationService {
  static const String _apiKey = "AIzaSyDQWM-YvzqUkGcIVDGHE6DSirDYa2fUOnQ";
  static const int _maxRetries = 3;
  static const Duration _initialDelay = Duration(seconds: 1);

  static String _cleanJson(String raw) {
    return raw
        .replaceAll(RegExp(r'^```json'), '')
        .replaceAll(RegExp(r'^```'), '')
        .replaceAll(RegExp(r'```$'), '')
        .trim();
  }

  /// Feature 1: Analyze video background in real time
  static Future<BackgroundVerificationResult?> analyzeVideoFrame(
    File videoFrame, {
    DeclaredData? declaredData,
    String? sessionId,
  }) async {
    if (_apiKey.isEmpty) {
      developer.log(
        'API Key not found. Configure BackgroundVerificationService._apiKey',
      );
      return null;
    }

    int retries = 0;
    Duration currentDelay = _initialDelay;

    while (retries < _maxRetries) {
      try {
        final model = GenerativeModel(
          model: 'gemini-2.0-flash-exp',
          apiKey: _apiKey,
        );

        final imageBytes = await videoFrame.readAsBytes();
        final prompt = _buildAnalysisPrompt(declaredData);

        final imagePart = DataPart('image/jpeg', imageBytes);

        final response = await model.generateContent([
          Content.multi([TextPart(prompt), imagePart]),
        ]);

        if (response.text != null) {
          developer.log(
            'Background Verification API raw response: ${response.text}',
          );

          try {
            final jsonMap = jsonDecode(_cleanJson(response.text!));
            final result = _processAnalysisResult(
              jsonMap,
              declaredData,
              sessionId,
            );
            developer.log('Background Verification completed successfully');
            return result;
          } catch (e) {
            developer.log('Error parsing JSON response: $e');
            return null;
          }
        } else {
          developer.log("Background Verification API returned no text.");
          return null;
        }
      } catch (e) {
        developer.log('Error calling Background Verification API: $e');
        retries++;
        if (retries < _maxRetries) {
          await Future.delayed(currentDelay);
          currentDelay *= 2;
        }
      }
    }

    developer.log('Max retries exceeded for Background Verification API');
    return null;
  }

  /// Feature 2: Extract video frames efficiently
  static Future<List<File>> extractVideoFrames(
    File videoFile, {
    int maxFrames = 5,
    Duration interval = const Duration(seconds: 2),
  }) async {
    // This would typically use ffmpeg or similar
    // For now, return the video file as a single frame
    // In a real implementation, you'd extract frames at intervals
    return [videoFile];
  }

  /// Feature 3: Classify environment type with high accuracy
  static String _buildAnalysisPrompt(DeclaredData? declaredData) {
    String basePrompt = '''
Analyze this video frame or image for intelligent background verification in a KYC/video call scenario.

Your task is to provide a comprehensive analysis in JSON format with the following structure:

{
  "environment_analysis": {
    "detected_environment": "home|office|shop|warehouse|outdoor|unknown",
    "confidence": 0.0-1.0,
    "supporting_evidence": ["list of specific visual elements that support the classification"],
    "detailed_description": "detailed description of the environment"
  },
  "detected_objects": [
    {
      "object_name": "specific object name",
      "category": "furniture|appliances|business_assets|office_items|vehicles|other",
      "detected_quantity": integer,
      "confidence": 0.0-1.0,
      "description": "detailed description including positioning and context"
    }
  ],
  "verification_comparison": {
    "mismatches": [
      {
        "type": "environment|quantity|item|other",
        "description": "detailed description of the mismatch",
        "declared": "what was declared",
        "detected": "what was actually detected",
        "severity": 0.0-1.0
      }
    ],
    "overall_match_score": 0.0-1.0,
    "matched_items": ["list of items that match declarations"],
    "missing_items": ["items declared but not found"],
    "unexpected_items": ["items found but not declared"]
  },
  "risk_assessment": {
    "risk_level": "low|medium|high|critical",
    "risk_score": 0.0-1.0,
    "recommendation": "Pass|Review Needed|Reject",
    "flagged_concerns": ["list of specific concerns"],
    "requires_human_review": true/false,
    "reason_for_flag": "primary reason for flagging if applicable"
  }
}

Focus on detecting:

FURNITURE: sofa, bed, table, chair, cupboard, wardrobe, shelf, desk, dining table, coffee table
APPLIANCES: TV, fridge, AC, washing machine, microwave, computer, laptop, monitor
SHOP/BUSINESS ASSETS: shelves, counters, products, inventory, cash register, display cases, storage boxes
OFFICE ITEMS: desk, computer, whiteboard, meeting table, office chair, filing cabinet, printer
VEHICLES: car, scooter, bike, motorcycle (if visible through windows or in frame)

Pay special attention to:
1. Environment classification accuracy
2. Object quantity counting
3. Context consistency (do the objects match the environment type?)
4. Professional vs personal setting indicators
5. Scale and inventory assessment for business environments

''';

    if (declaredData != null) {
      basePrompt +=
          '''

DECLARED DATA TO COMPARE AGAINST:
- Declared Environment: ${declaredData.declaredEnvironment}
- Business Type: ${declaredData.businessType}
- Declared Items: ${declaredData.declaredItems.map((item) => '${item.itemName}: ${item.expectedQuantity}').join(', ')}
- Additional Info: ${declaredData.additionalInfo}

Compare the visual evidence against these declarations and identify any mismatches or inconsistencies.
''';
    }

    basePrompt += '''
Provide accurate counts and high confidence scores. Be specific about object locations and context.
Return only valid JSON without markdown formatting.
''';

    return basePrompt;
  }

  /// Feature 4: Process and structure the analysis result
  static BackgroundVerificationResult _processAnalysisResult(
    Map<String, dynamic> jsonMap,
    DeclaredData? declaredData,
    String? sessionId,
  ) {
    // Parse environment analysis
    final envAnalysis = EnvironmentAnalysis.fromJson(
      jsonMap['environment_analysis'] ?? {},
    );

    // Parse detected objects
    final detectedObjects =
        (jsonMap['detected_objects'] as List?)
            ?.map((e) => ObjectDetection.fromJson(e))
            .toList() ??
        [];

    // Parse verification comparison
    var verificationComparison = VerificationComparison.fromJson(
      jsonMap['verification_comparison'] ?? {},
    );

    // If no declared data was provided, create a basic comparison
    if (declaredData == null) {
      verificationComparison = VerificationComparison(
        declaredData: DeclaredData(
          declaredEnvironment: EnvironmentType.unknown,
          declaredItems: [],
          businessType: '',
          additionalInfo: '',
        ),
        mismatches: [],
        overallMatchScore: 1.0,
        matchedItems: [],
        missingItems: [],
        unexpectedItems: [],
      );
    }

    // Parse risk assessment
    final riskAssessment = RiskAssessment.fromJson(
      jsonMap['risk_assessment'] ?? {},
    );

    return BackgroundVerificationResult(
      environmentAnalysis: envAnalysis,
      detectedObjects: detectedObjects,
      verificationComparison: verificationComparison,
      riskAssessment: riskAssessment,
      analysisTimestamp: DateTime.now(),
      sessionId: sessionId ?? _generateSessionId(),
    );
  }

  /// Feature 5: Generate session ID for tracking
  static String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Feature 6: Batch analysis for multiple frames
  static Future<List<BackgroundVerificationResult>> analyzeBatchFrames(
    List<File> frames, {
    DeclaredData? declaredData,
    String? sessionId,
  }) async {
    final results = <BackgroundVerificationResult>[];

    for (int i = 0; i < frames.length; i++) {
      developer.log('Analyzing frame ${i + 1}/${frames.length}');
      final result = await analyzeVideoFrame(
        frames[i],
        declaredData: declaredData,
        sessionId: sessionId,
      );

      if (result != null) {
        results.add(result);
      }

      // Add small delay between requests to avoid rate limiting
      if (i < frames.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    return results;
  }

  /// Feature 7: Generate fraud detection summary
  static FraudDetectionSummary generateFraudSummary(
    List<BackgroundVerificationResult> results,
  ) {
    if (results.isEmpty) {
      return FraudDetectionSummary.empty();
    }

    // Aggregate risk scores
    final riskScores = results.map((r) => r.riskAssessment.riskScore).toList();
    final avgRiskScore = riskScores.reduce((a, b) => a + b) / riskScores.length;

    // Find highest risk level
    var highestRiskLevel = RiskLevel.low;
    for (final result in results) {
      if (result.riskAssessment.riskLevel.index > highestRiskLevel.index) {
        highestRiskLevel = result.riskAssessment.riskLevel;
      }
    }

    // Collect all mismatches
    final allMismatches = <Mismatch>[];
    for (final result in results) {
      allMismatches.addAll(result.verificationComparison.mismatches);
    }

    // Determine if human review is required
    final requiresReview =
        results.any((r) => r.riskAssessment.requiresHumanReview) ||
        avgRiskScore > 0.6 ||
        allMismatches.any((m) => m.severity > 0.7);

    return FraudDetectionSummary(
      overallRiskLevel: highestRiskLevel,
      averageRiskScore: avgRiskScore,
      totalMismatches: allMismatches.length,
      requiresHumanReview: requiresReview,
      recommendation: requiresReview ? 'Review Needed' : 'Pass',
      keyFindings: _extractKeyFindings(results),
      analysisCount: results.length,
    );
  }

  static List<String> _extractKeyFindings(
    List<BackgroundVerificationResult> results,
  ) {
    final findings = <String>[];

    // Environment consistency
    final environments = results
        .map((r) => r.environmentAnalysis.detectedEnvironment)
        .toSet();
    if (environments.length > 1) {
      findings.add('Inconsistent environment detection across frames');
    }

    // High-severity mismatches
    for (final result in results) {
      for (final mismatch in result.verificationComparison.mismatches) {
        if (mismatch.severity > 0.7) {
          findings.add('High-severity mismatch: ${mismatch.description}');
        }
      }
    }

    // Low confidence detections
    for (final result in results) {
      if (result.environmentAnalysis.confidence < 0.5) {
        findings.add(
          'Low confidence environment detection (${(result.environmentAnalysis.confidence * 100).toStringAsFixed(0)}%)',
        );
      }
    }

    return findings.take(5).toList(); // Limit to top 5 findings
  }
}

class FraudDetectionSummary {
  final RiskLevel overallRiskLevel;
  final double averageRiskScore;
  final int totalMismatches;
  final bool requiresHumanReview;
  final String recommendation;
  final List<String> keyFindings;
  final int analysisCount;

  FraudDetectionSummary({
    required this.overallRiskLevel,
    required this.averageRiskScore,
    required this.totalMismatches,
    required this.requiresHumanReview,
    required this.recommendation,
    required this.keyFindings,
    required this.analysisCount,
  });

  factory FraudDetectionSummary.empty() {
    return FraudDetectionSummary(
      overallRiskLevel: RiskLevel.low,
      averageRiskScore: 0.0,
      totalMismatches: 0,
      requiresHumanReview: false,
      recommendation: 'No Analysis',
      keyFindings: [],
      analysisCount: 0,
    );
  }
}
