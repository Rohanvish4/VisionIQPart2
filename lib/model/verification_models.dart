// Models for Intelligent Background Verification System

class BackgroundVerificationResult {
  final EnvironmentAnalysis environmentAnalysis;
  final List<ObjectDetection> detectedObjects;
  final VerificationComparison verificationComparison;
  final RiskAssessment riskAssessment;
  final DateTime analysisTimestamp;
  final String sessionId;

  BackgroundVerificationResult({
    required this.environmentAnalysis,
    required this.detectedObjects,
    required this.verificationComparison,
    required this.riskAssessment,
    required this.analysisTimestamp,
    required this.sessionId,
  });

  factory BackgroundVerificationResult.fromJson(Map<String, dynamic> json) {
    return BackgroundVerificationResult(
      environmentAnalysis: EnvironmentAnalysis.fromJson(
        json['environment_analysis'] ?? {},
      ),
      detectedObjects:
          (json['detected_objects'] as List?)
              ?.map((e) => ObjectDetection.fromJson(e))
              .toList() ??
          [],
      verificationComparison: VerificationComparison.fromJson(
        json['verification_comparison'] ?? {},
      ),
      riskAssessment: RiskAssessment.fromJson(json['risk_assessment'] ?? {}),
      analysisTimestamp: DateTime.parse(
        json['analysis_timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      sessionId: json['session_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'environment_analysis': environmentAnalysis.toJson(),
    'detected_objects': detectedObjects.map((e) => e.toJson()).toList(),
    'verification_comparison': verificationComparison.toJson(),
    'risk_assessment': riskAssessment.toJson(),
    'analysis_timestamp': analysisTimestamp.toIso8601String(),
    'session_id': sessionId,
  };
}

class EnvironmentAnalysis {
  final EnvironmentType detectedEnvironment;
  final double confidence;
  final List<String> supportingEvidence;
  final String detailedDescription;

  EnvironmentAnalysis({
    required this.detectedEnvironment,
    required this.confidence,
    required this.supportingEvidence,
    required this.detailedDescription,
  });

  factory EnvironmentAnalysis.fromJson(Map<String, dynamic> json) {
    return EnvironmentAnalysis(
      detectedEnvironment: EnvironmentType.fromString(
        json['detected_environment'] ?? '',
      ),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      supportingEvidence: List<String>.from(json['supporting_evidence'] ?? []),
      detailedDescription: json['detailed_description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'detected_environment': detectedEnvironment.toString(),
    'confidence': confidence,
    'supporting_evidence': supportingEvidence,
    'detailed_description': detailedDescription,
  };
}

enum EnvironmentType {
  home,
  office,
  shop,
  warehouse,
  outdoor,
  unknown;

  factory EnvironmentType.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'home':
        return EnvironmentType.home;
      case 'office':
        return EnvironmentType.office;
      case 'shop':
        return EnvironmentType.shop;
      case 'warehouse':
        return EnvironmentType.warehouse;
      case 'outdoor':
        return EnvironmentType.outdoor;
      default:
        return EnvironmentType.unknown;
    }
  }

  @override
  String toString() {
    switch (this) {
      case EnvironmentType.home:
        return 'home';
      case EnvironmentType.office:
        return 'office';
      case EnvironmentType.shop:
        return 'shop';
      case EnvironmentType.warehouse:
        return 'warehouse';
      case EnvironmentType.outdoor:
        return 'outdoor';
      case EnvironmentType.unknown:
        return 'unknown';
    }
  }
}

class ObjectDetection {
  final String objectName;
  final ObjectCategory category;
  final int detectedQuantity;
  final double confidence;
  final List<BoundingBox> boundingBoxes;
  final String description;

  ObjectDetection({
    required this.objectName,
    required this.category,
    required this.detectedQuantity,
    required this.confidence,
    required this.boundingBoxes,
    required this.description,
  });

  factory ObjectDetection.fromJson(Map<String, dynamic> json) {
    return ObjectDetection(
      objectName: json['object_name'] ?? '',
      category: ObjectCategory.fromString(json['category'] ?? ''),
      detectedQuantity: (json['detected_quantity'] as num?)?.toInt() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      boundingBoxes:
          (json['bounding_boxes'] as List?)
              ?.map((e) => BoundingBox.fromJson(e))
              .toList() ??
          [],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'object_name': objectName,
    'category': category.toString(),
    'detected_quantity': detectedQuantity,
    'confidence': confidence,
    'bounding_boxes': boundingBoxes.map((e) => e.toJson()).toList(),
    'description': description,
  };
}

enum ObjectCategory {
  furniture,
  appliances,
  businessAssets,
  officeItems,
  vehicles,
  other;

  factory ObjectCategory.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'furniture':
        return ObjectCategory.furniture;
      case 'appliances':
        return ObjectCategory.appliances;
      case 'businessassets':
      case 'business_assets':
        return ObjectCategory.businessAssets;
      case 'officeitems':
      case 'office_items':
        return ObjectCategory.officeItems;
      case 'vehicles':
        return ObjectCategory.vehicles;
      default:
        return ObjectCategory.other;
    }
  }

  @override
  String toString() {
    switch (this) {
      case ObjectCategory.furniture:
        return 'furniture';
      case ObjectCategory.appliances:
        return 'appliances';
      case ObjectCategory.businessAssets:
        return 'business_assets';
      case ObjectCategory.officeItems:
        return 'office_items';
      case ObjectCategory.vehicles:
        return 'vehicles';
      case ObjectCategory.other:
        return 'other';
    }
  }
}

class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
  };
}

class VerificationComparison {
  final DeclaredData declaredData;
  final List<Mismatch> mismatches;
  final double overallMatchScore;
  final List<String> matchedItems;
  final List<String> missingItems;
  final List<String> unexpectedItems;

  VerificationComparison({
    required this.declaredData,
    required this.mismatches,
    required this.overallMatchScore,
    required this.matchedItems,
    required this.missingItems,
    required this.unexpectedItems,
  });

  factory VerificationComparison.fromJson(Map<String, dynamic> json) {
    return VerificationComparison(
      declaredData: DeclaredData.fromJson(json['declared_data'] ?? {}),
      mismatches:
          (json['mismatches'] as List?)
              ?.map((e) => Mismatch.fromJson(e))
              .toList() ??
          [],
      overallMatchScore:
          (json['overall_match_score'] as num?)?.toDouble() ?? 0.0,
      matchedItems: List<String>.from(json['matched_items'] ?? []),
      missingItems: List<String>.from(json['missing_items'] ?? []),
      unexpectedItems: List<String>.from(json['unexpected_items'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'declared_data': declaredData.toJson(),
    'mismatches': mismatches.map((e) => e.toJson()).toList(),
    'overall_match_score': overallMatchScore,
    'matched_items': matchedItems,
    'missing_items': missingItems,
    'unexpected_items': unexpectedItems,
  };
}

class DeclaredData {
  final EnvironmentType declaredEnvironment;
  final List<DeclaredItem> declaredItems;
  final String businessType;
  final String additionalInfo;

  DeclaredData({
    required this.declaredEnvironment,
    required this.declaredItems,
    required this.businessType,
    required this.additionalInfo,
  });

  factory DeclaredData.fromJson(Map<String, dynamic> json) {
    return DeclaredData(
      declaredEnvironment: EnvironmentType.fromString(
        json['declared_environment'] ?? '',
      ),
      declaredItems:
          (json['declared_items'] as List?)
              ?.map((e) => DeclaredItem.fromJson(e))
              .toList() ??
          [],
      businessType: json['business_type'] ?? '',
      additionalInfo: json['additional_info'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'declared_environment': declaredEnvironment.toString(),
    'declared_items': declaredItems.map((e) => e.toJson()).toList(),
    'business_type': businessType,
    'additional_info': additionalInfo,
  };
}

class DeclaredItem {
  final String itemName;
  final int expectedQuantity;
  final String description;

  DeclaredItem({
    required this.itemName,
    required this.expectedQuantity,
    required this.description,
  });

  factory DeclaredItem.fromJson(Map<String, dynamic> json) {
    return DeclaredItem(
      itemName: json['item_name'] ?? '',
      expectedQuantity: (json['expected_quantity'] as num?)?.toInt() ?? 0,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'item_name': itemName,
    'expected_quantity': expectedQuantity,
    'description': description,
  };
}

class Mismatch {
  final MismatchType type;
  final String description;
  final String declared;
  final String detected;
  final double severity; // 0.0 to 1.0

  Mismatch({
    required this.type,
    required this.description,
    required this.declared,
    required this.detected,
    required this.severity,
  });

  factory Mismatch.fromJson(Map<String, dynamic> json) {
    return Mismatch(
      type: MismatchType.fromString(json['type'] ?? ''),
      description: json['description'] ?? '',
      declared: json['declared'] ?? '',
      detected: json['detected'] ?? '',
      severity: (json['severity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'description': description,
    'declared': declared,
    'detected': detected,
    'severity': severity,
  };
}

enum MismatchType {
  environment,
  quantity,
  item,
  other;

  factory MismatchType.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'environment':
        return MismatchType.environment;
      case 'quantity':
        return MismatchType.quantity;
      case 'item':
        return MismatchType.item;
      default:
        return MismatchType.other;
    }
  }

  @override
  String toString() {
    switch (this) {
      case MismatchType.environment:
        return 'environment';
      case MismatchType.quantity:
        return 'quantity';
      case MismatchType.item:
        return 'item';
      case MismatchType.other:
        return 'other';
    }
  }
}

class RiskAssessment {
  final RiskLevel riskLevel;
  final double riskScore; // 0.0 to 1.0
  final String recommendation;
  final List<String> flaggedConcerns;
  final bool requiresHumanReview;
  final String reasonForFlag;

  RiskAssessment({
    required this.riskLevel,
    required this.riskScore,
    required this.recommendation,
    required this.flaggedConcerns,
    required this.requiresHumanReview,
    required this.reasonForFlag,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      riskLevel: RiskLevel.fromString(json['risk_level'] ?? ''),
      riskScore: (json['risk_score'] as num?)?.toDouble() ?? 0.0,
      recommendation: json['recommendation'] ?? '',
      flaggedConcerns: List<String>.from(json['flagged_concerns'] ?? []),
      requiresHumanReview: json['requires_human_review'] ?? false,
      reasonForFlag: json['reason_for_flag'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'risk_level': riskLevel.toString(),
    'risk_score': riskScore,
    'recommendation': recommendation,
    'flagged_concerns': flaggedConcerns,
    'requires_human_review': requiresHumanReview,
    'reason_for_flag': reasonForFlag,
  };
}

enum RiskLevel {
  low,
  medium,
  high,
  critical;

  factory RiskLevel.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return RiskLevel.low;
      case 'medium':
        return RiskLevel.medium;
      case 'high':
        return RiskLevel.high;
      case 'critical':
        return RiskLevel.critical;
      default:
        return RiskLevel.low;
    }
  }

  @override
  String toString() {
    switch (this) {
      case RiskLevel.low:
        return 'low';
      case RiskLevel.medium:
        return 'medium';
      case RiskLevel.high:
        return 'high';
      case RiskLevel.critical:
        return 'critical';
    }
  }
}
