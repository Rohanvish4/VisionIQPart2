import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/verification_models.dart';
import '../provider/background_verification_provider.dart';
import '../service/background_verification_service.dart';

class VerificationResultPage extends StatelessWidget {
  const VerificationResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Get.find<BackgroundVerificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Results'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _shareReport(context, provider),
            icon: const Icon(Icons.share),
            tooltip: 'Share Report',
          ),
          IconButton(
            onPressed: () => _exportReport(context, provider),
            icon: const Icon(Icons.download),
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: Obx(() {
        final result = provider.currentResult;
        if (result == null) {
          return const Center(child: Text('No analysis results available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverallSummary(result),
              const SizedBox(height: 24),
              _buildEnvironmentAnalysis(result.environmentAnalysis),
              const SizedBox(height: 24),
              _buildDetectedObjects(result.detectedObjects),
              const SizedBox(height: 24),
              _buildVerificationComparison(
                result.verificationComparison,
                provider,
              ),
              const SizedBox(height: 24),
              _buildRiskAssessment(result.riskAssessment),
              const SizedBox(height: 24),
              _buildFraudSummary(provider.fraudSummary),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOverallSummary(BackgroundVerificationResult result) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              _getRiskColor(
                result.riskAssessment.riskLevel,
              ).withValues(alpha: 0.1),
              _getRiskColor(
                result.riskAssessment.riskLevel,
              ).withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getRiskIcon(result.riskAssessment.riskLevel),
                  color: _getRiskColor(result.riskAssessment.riskLevel),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getRiskColor(result.riskAssessment.riskLevel),
                        ),
                      ),
                      Text(
                        'Session: ${result.sessionId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getRiskColor(result.riskAssessment.riskLevel),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    result.riskAssessment.recommendation,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryMetric(
                    'Risk Score',
                    '${(result.riskAssessment.riskScore * 100).toInt()}%',
                    _getRiskColor(result.riskAssessment.riskLevel),
                    Icons.warning,
                  ),
                ),
                Expanded(
                  child: _buildSummaryMetric(
                    'Environment',
                    result.environmentAnalysis.detectedEnvironment
                        .toString()
                        .toUpperCase(),
                    _getEnvironmentColor(
                      result.environmentAnalysis.detectedEnvironment,
                    ),
                    Icons.location_on,
                  ),
                ),
                Expanded(
                  child: _buildSummaryMetric(
                    'Confidence',
                    '${(result.environmentAnalysis.confidence * 100).toInt()}%',
                    result.environmentAnalysis.confidence > 0.7
                        ? Colors.green
                        : Colors.orange,
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentAnalysis(EnvironmentAnalysis analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.home,
                  color: _getEnvironmentColor(analysis.detectedEnvironment),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Environment Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detected: ${analysis.detectedEnvironment.toString().toUpperCase()}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getEnvironmentColor(
                            analysis.detectedEnvironment,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: analysis.confidence > 0.7
                              ? Colors.green
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(analysis.confidence * 100).toInt()}% confident',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    analysis.detailedDescription,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  if (analysis.supportingEvidence.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Supporting Evidence:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: analysis.supportingEvidence
                          .map(
                            (evidence) => Chip(
                              label: Text(
                                evidence,
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: Colors.green.shade100,
                              side: BorderSide(color: Colors.green.shade300),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedObjects(List<ObjectDetection> objects) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Detected Objects (${objects.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (objects.isEmpty)
              const Center(child: Text('No objects detected'))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: objects.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final object = objects[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              object.category,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getCategoryIcon(object.category),
                            color: _getCategoryColor(object.category),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                object.objectName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Category: ${object.category}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              if (object.description.isNotEmpty)
                                Text(
                                  object.description,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Qty: ${object.detectedQuantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: object.confidence > 0.7
                                    ? Colors.green
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${(object.confidence * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationComparison(
    VerificationComparison comparison,
    BackgroundVerificationProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare_arrows, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Verification Comparison',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildComparisonMetric(
                    'Match Score',
                    '${(comparison.overallMatchScore * 100).toInt()}%',
                    comparison.overallMatchScore > 0.7
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildComparisonMetric(
                    'Mismatches',
                    '${comparison.mismatches.length}',
                    comparison.mismatches.isEmpty ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            if (comparison.mismatches.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Detected Mismatches:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comparison.mismatches.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final mismatch = comparison.mismatches[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getMismatchIcon(mismatch.type),
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                mismatch.description,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getSeverityColor(mismatch.severity),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${(mismatch.severity * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (mismatch.declared.isNotEmpty ||
                            mismatch.detected.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (mismatch.declared.isNotEmpty)
                                Expanded(
                                  child: Text(
                                    'Declared: ${mismatch.declared}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              if (mismatch.detected.isNotEmpty)
                                Expanded(
                                  child: Text(
                                    'Detected: ${mismatch.detected}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAssessment(RiskAssessment assessment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: _getRiskColor(assessment.riskLevel),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Risk Assessment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getRiskColor(
                  assessment.riskLevel,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getRiskColor(
                    assessment.riskLevel,
                  ).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Risk Level: ${assessment.riskLevel.toString().toUpperCase()}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getRiskColor(assessment.riskLevel),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getRiskColor(assessment.riskLevel),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          assessment.recommendation,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (assessment.reasonForFlag.isNotEmpty)
                    Text(
                      'Reason: ${assessment.reasonForFlag}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _getRiskColor(assessment.riskLevel),
                      ),
                    ),
                  if (assessment.flaggedConcerns.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Flagged Concerns:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    ...assessment.flaggedConcerns.map(
                      (concern) => Padding(
                        padding: const EdgeInsets.only(left: 8, top: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(
                                color: _getRiskColor(assessment.riskLevel),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                concern,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFraudSummary(FraudDetectionSummary? summary) {
    if (summary == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Fraud Detection Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Analysis Count',
                    '${summary.analysisCount}',
                    Icons.analytics,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryCard(
                    'Avg Risk Score',
                    '${(summary.averageRiskScore * 100).toInt()}%',
                    Icons.trending_up,
                    _getRiskColor(summary.overallRiskLevel),
                  ),
                ),
              ],
            ),
            if (summary.keyFindings.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Key Findings:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...summary.keyFindings.map(
                (finding) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.arrow_right,
                        color: Colors.purple.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          finding,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.critical:
        return Colors.purple;
    }
  }

  IconData _getRiskIcon(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.medium:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.error;
      case RiskLevel.critical:
        return Icons.dangerous;
    }
  }

  Color _getEnvironmentColor(EnvironmentType environment) {
    switch (environment) {
      case EnvironmentType.home:
        return Colors.green;
      case EnvironmentType.office:
        return Colors.blue;
      case EnvironmentType.shop:
        return Colors.orange;
      case EnvironmentType.warehouse:
        return Colors.brown;
      case EnvironmentType.outdoor:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryColor(ObjectCategory category) {
    switch (category) {
      case ObjectCategory.furniture:
        return Colors.brown;
      case ObjectCategory.appliances:
        return Colors.blue;
      case ObjectCategory.businessAssets:
        return Colors.orange;
      case ObjectCategory.officeItems:
        return Colors.indigo;
      case ObjectCategory.vehicles:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(ObjectCategory category) {
    switch (category) {
      case ObjectCategory.furniture:
        return Icons.chair;
      case ObjectCategory.appliances:
        return Icons.kitchen;
      case ObjectCategory.businessAssets:
        return Icons.store;
      case ObjectCategory.officeItems:
        return Icons.business;
      case ObjectCategory.vehicles:
        return Icons.directions_car;
      default:
        return Icons.category;
    }
  }

  IconData _getMismatchIcon(MismatchType type) {
    switch (type) {
      case MismatchType.environment:
        return Icons.location_off;
      case MismatchType.quantity:
        return Icons.numbers;
      case MismatchType.item:
        return Icons.inventory_2;
      default:
        return Icons.error_outline;
    }
  }

  Color _getSeverityColor(double severity) {
    if (severity < 0.3) return Colors.green;
    if (severity < 0.6) return Colors.orange;
    if (severity < 0.8) return Colors.red;
    return Colors.purple;
  }

  void _shareReport(
    BuildContext context,
    BackgroundVerificationProvider provider,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality to be implemented')),
    );
  }

  void _exportReport(
    BuildContext context,
    BackgroundVerificationProvider provider,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality to be implemented')),
    );
  }
}
