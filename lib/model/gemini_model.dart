class GeminiModel {
  final String environmentType;
  final List<DetectedItem> detectedItems;
  final List<InfrastructureItem> infrastructure;
  final List<InventoryItem> inventory;
  final int totalItemsCount;
  final String locationContext;
  final String useCase;
  final String structuredReportFormat;
  final double confidenceSummary;

  GeminiModel({
    required this.environmentType,
    required this.detectedItems,
    required this.infrastructure,
    required this.inventory,
    required this.totalItemsCount,
    required this.locationContext,
    required this.useCase,
    required this.structuredReportFormat,
    required this.confidenceSummary,
  });

  factory GeminiModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return GeminiModel.empty();
    }

    return GeminiModel(
      environmentType: json['environment_type'] ?? '',
      detectedItems:
          (json['detected_items'] as List<dynamic>?)
              ?.map((e) => DetectedItem.fromJson(e))
              .toList() ??
          [],
      infrastructure:
          (json['infrastructure'] as List<dynamic>?)
              ?.map((e) => InfrastructureItem.fromJson(e))
              .toList() ??
          [],
      inventory:
          (json['inventory'] as List<dynamic>?)
              ?.map((e) => InventoryItem.fromJson(e))
              .toList() ??
          [],
      totalItemsCount: (json['total_items_count'] as num?)?.toInt() ?? 0,
      locationContext: json['location_context'] ?? '',
      useCase: json['use_case'] ?? '',
      structuredReportFormat: json['structured_report_format'] ?? '',
      confidenceSummary:
          (json['confidence_summary'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory GeminiModel.empty() => GeminiModel(
    environmentType: '',
    detectedItems: [],
    infrastructure: [],
    inventory: [],
    totalItemsCount: 0,
    locationContext: '',
    useCase: '',
    structuredReportFormat: '',
    confidenceSummary: 0.0,
  );

  Map<String, dynamic> toJson() => {
    "environment_type": environmentType,
    "detected_items": detectedItems.map((e) => e.toJson()).toList(),
    "infrastructure": infrastructure.map((e) => e.toJson()).toList(),
    "inventory": inventory.map((e) => e.toJson()).toList(),
    "total_items_count": totalItemsCount,
    "location_context": locationContext,
    "use_case": useCase,
    "structured_report_format": structuredReportFormat,
    "confidence_summary": confidenceSummary,
  };
}

class DetectedItem {
  final String itemName;
  final int quantity;
  final double confidenceScore;

  DetectedItem({
    required this.itemName,
    required this.quantity,
    required this.confidenceScore,
  });

  factory DetectedItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DetectedItem(itemName: '', quantity: 0, confidenceScore: 0.0);
    }
    return DetectedItem(
      itemName: json['item_name'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    "item_name": itemName,
    "quantity": quantity,
    "confidence_score": confidenceScore,
  };
}

class InfrastructureItem {
  final String itemName;
  final int quantity;
  final double confidenceScore;

  InfrastructureItem({
    required this.itemName,
    required this.quantity,
    required this.confidenceScore,
  });

  factory InfrastructureItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return InfrastructureItem(
        itemName: '',
        quantity: 0,
        confidenceScore: 0.0,
      );
    }
    return InfrastructureItem(
      itemName: json['item_name'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    "item_name": itemName,
    "quantity": quantity,
    "confidence_score": confidenceScore,
  };
}

class InventoryItem {
  final String itemName;
  final int quantity;
  final double confidenceScore;

  InventoryItem({
    required this.itemName,
    required this.quantity,
    required this.confidenceScore,
  });

  factory InventoryItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return InventoryItem(itemName: '', quantity: 0, confidenceScore: 0.0);
    }
    return InventoryItem(
      itemName: json['item_name'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    "item_name": itemName,
    "quantity": quantity,
    "confidence_score": confidenceScore,
  };
}
