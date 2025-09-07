import '../model/verification_models.dart';

class SampleDataProvider {
  /// Sample declared data for home environment
  static DeclaredData getHomeSampleData() {
    return DeclaredData(
      declaredEnvironment: EnvironmentType.home,
      businessType: 'Residential',
      additionalInfo: 'Single-family home with modern furnishing',
      declaredItems: [
        DeclaredItem(
          itemName: 'Refrigerator',
          expectedQuantity: 1,
          description: 'Large white refrigerator in kitchen',
        ),
        DeclaredItem(
          itemName: 'Television',
          expectedQuantity: 2,
          description: 'Living room and bedroom TVs',
        ),
        DeclaredItem(
          itemName: 'Sofa',
          expectedQuantity: 1,
          description: 'Large sectional sofa in living room',
        ),
        DeclaredItem(
          itemName: 'Dining Table',
          expectedQuantity: 1,
          description: '6-seater wooden dining table',
        ),
      ],
    );
  }

  /// Sample declared data for shop environment
  static DeclaredData getShopSampleData() {
    return DeclaredData(
      declaredEnvironment: EnvironmentType.shop,
      businessType: 'Retail Grocery Store',
      additionalInfo: 'Small neighborhood grocery store with packaged goods',
      declaredItems: [
        DeclaredItem(
          itemName: 'Shelves',
          expectedQuantity: 8,
          description: 'Metal shelving units for product display',
        ),
        DeclaredItem(
          itemName: 'Refrigerated Display',
          expectedQuantity: 2,
          description: 'Glass-front refrigerators for beverages',
        ),
        DeclaredItem(
          itemName: 'Cash Counter',
          expectedQuantity: 1,
          description: 'Wooden cash counter with register',
        ),
        DeclaredItem(
          itemName: 'Storage Boxes',
          expectedQuantity: 20,
          description: 'Cardboard boxes for inventory storage',
        ),
        DeclaredItem(
          itemName: 'Bottled Products',
          expectedQuantity: 200,
          description: 'Various bottled beverages and products',
        ),
      ],
    );
  }

  /// Sample declared data for office environment
  static DeclaredData getOfficeSampleData() {
    return DeclaredData(
      declaredEnvironment: EnvironmentType.office,
      businessType: 'Software Development Company',
      additionalInfo: 'Modern open-plan office with workstations',
      declaredItems: [
        DeclaredItem(
          itemName: 'Desks',
          expectedQuantity: 12,
          description: 'Ergonomic office desks with adjustable height',
        ),
        DeclaredItem(
          itemName: 'Office Chairs',
          expectedQuantity: 12,
          description: 'Ergonomic office chairs with wheels',
        ),
        DeclaredItem(
          itemName: 'Monitors',
          expectedQuantity: 24,
          description: 'Dual monitor setup for each workstation',
        ),
        DeclaredItem(
          itemName: 'Meeting Table',
          expectedQuantity: 2,
          description: 'Large conference tables for meetings',
        ),
        DeclaredItem(
          itemName: 'Whiteboard',
          expectedQuantity: 3,
          description: 'Wall-mounted whiteboards for collaboration',
        ),
      ],
    );
  }

  /// Sample declared data for warehouse environment
  static DeclaredData getWarehouseSampleData() {
    return DeclaredData(
      declaredEnvironment: EnvironmentType.warehouse,
      businessType: 'Distribution Center',
      additionalInfo:
          'Large warehouse facility for product storage and distribution',
      declaredItems: [
        DeclaredItem(
          itemName: 'Storage Racks',
          expectedQuantity: 50,
          description: 'Industrial metal storage racks',
        ),
        DeclaredItem(
          itemName: 'Pallets',
          expectedQuantity: 200,
          description: 'Wooden pallets for goods transport',
        ),
        DeclaredItem(
          itemName: 'Forklift',
          expectedQuantity: 3,
          description: 'Electric forklifts for material handling',
        ),
        DeclaredItem(
          itemName: 'Shipping Containers',
          expectedQuantity: 8,
          description: 'Large metal containers for bulk storage',
        ),
        DeclaredItem(
          itemName: 'Loading Dock',
          expectedQuantity: 4,
          description: 'Truck loading and unloading stations',
        ),
      ],
    );
  }

  /// Get all sample data options
  static Map<String, DeclaredData> getAllSampleData() {
    return {
      'Home Environment': getHomeSampleData(),
      'Shop/Store Environment': getShopSampleData(),
      'Office Environment': getOfficeSampleData(),
      'Warehouse Environment': getWarehouseSampleData(),
    };
  }

  /// Generate sample verification results for testing
  static BackgroundVerificationResult generateSampleResult({
    EnvironmentType detectedEnvironment = EnvironmentType.shop,
    EnvironmentType declaredEnvironment = EnvironmentType.home,
    double environmentConfidence = 0.85,
    List<String>? mismatches,
  }) {
    // Sample detected objects
    final detectedObjects = <ObjectDetection>[
      ObjectDetection(
        objectName: 'Shelves',
        category: ObjectCategory.businessAssets,
        detectedQuantity: 5,
        confidence: 0.92,
        boundingBoxes: [],
        description: 'Metal shelving units visible in background',
      ),
      ObjectDetection(
        objectName: 'Cash Register',
        category: ObjectCategory.businessAssets,
        detectedQuantity: 1,
        confidence: 0.88,
        boundingBoxes: [],
        description: 'Electronic cash register on counter',
      ),
      ObjectDetection(
        objectName: 'Product Bottles',
        category: ObjectCategory.businessAssets,
        detectedQuantity: 150,
        confidence: 0.76,
        boundingBoxes: [],
        description: 'Multiple bottled products on shelves',
      ),
    ];

    // Sample verification comparison
    final comparison = VerificationComparison(
      declaredData: DeclaredData(
        declaredEnvironment: declaredEnvironment,
        declaredItems: [
          DeclaredItem(
            itemName: 'Refrigerator',
            expectedQuantity: 1,
            description: 'Home refrigerator',
          ),
        ],
        businessType: 'Residential',
        additionalInfo: 'Declared as home environment',
      ),
      mismatches: [
        Mismatch(
          type: MismatchType.environment,
          description: 'Environment type mismatch detected',
          declared: declaredEnvironment.toString(),
          detected: detectedEnvironment.toString(),
          severity: 0.85,
        ),
      ],
      overallMatchScore: 0.25,
      matchedItems: [],
      missingItems: ['Refrigerator', 'Television'],
      unexpectedItems: ['Shelves', 'Cash Register', 'Product Bottles'],
    );

    // Sample risk assessment
    final riskAssessment = RiskAssessment(
      riskLevel: RiskLevel.high,
      riskScore: 0.78,
      recommendation: 'Review Needed',
      flaggedConcerns: [
        'Environment type mismatch: Declared home but detected shop',
        'Missing declared home items',
        'Presence of commercial/business assets',
        'High discrepancy in object inventory',
      ],
      requiresHumanReview: true,
      reasonForFlag:
          'Significant mismatch between declared and detected environment',
    );

    return BackgroundVerificationResult(
      environmentAnalysis: EnvironmentAnalysis(
        detectedEnvironment: detectedEnvironment,
        confidence: environmentConfidence,
        supportingEvidence: [
          'Commercial shelving units',
          'Cash register presence',
          'Product inventory visible',
          'Commercial lighting setup',
        ],
        detailedDescription:
            'The environment appears to be a retail/commercial space with characteristics typical of a small shop or store.',
      ),
      detectedObjects: detectedObjects,
      verificationComparison: comparison,
      riskAssessment: riskAssessment,
      analysisTimestamp: DateTime.now(),
      sessionId: 'sample_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Generate low-risk sample result
  static BackgroundVerificationResult generateLowRiskSampleResult() {
    return generateSampleResult(
      detectedEnvironment: EnvironmentType.home,
      declaredEnvironment: EnvironmentType.home,
      environmentConfidence: 0.94,
    );
  }

  /// Generate high-risk sample result
  static BackgroundVerificationResult generateHighRiskSampleResult() {
    return generateSampleResult(
      detectedEnvironment: EnvironmentType.shop,
      declaredEnvironment: EnvironmentType.home,
      environmentConfidence: 0.89,
    );
  }
}
