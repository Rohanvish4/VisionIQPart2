import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../provider/background_verification_provider.dart';
import '../provider/video_frame_analyzer.dart';
import '../model/verification_models.dart';
import '../utils/sample_data_provider.dart';
import 'verification_result_page.dart';
import 'declared_data_input_page.dart';

class BackgroundVerificationHomePage extends StatelessWidget {
  const BackgroundVerificationHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final verificationProvider = Get.put(BackgroundVerificationProvider());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Background Verification'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo.shade800,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              verificationProvider.clearData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear All Data',
          ),
        ],
      ),
      body: Obx(
        () => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildQuickActionsCard(context, verificationProvider),
                const SizedBox(height: 20),
                _buildDeclaredDataCard(context, verificationProvider),
                const SizedBox(height: 20),
                if (verificationProvider.currentStatus.isNotEmpty)
                  _buildStatusCard(verificationProvider),
                if (verificationProvider.currentResult != null) ...[
                  const SizedBox(height: 20),
                  _buildQuickResultsCard(context, verificationProvider),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(
    BuildContext context,
    BackgroundVerificationProvider provider,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.camera_alt, color: Colors.indigo.shade600),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Upload image or video for verification',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: provider.isAnalyzing
                      ? null
                      : () async {
                          await _pickAndAnalyzeImage(context, provider);
                        },
                  icon: provider.isAnalyzing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.image),
                  label: Text(
                    provider.isAnalyzing ? 'Analyzing...' : 'Analyze Image',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: provider.isAnalyzing
                      ? null
                      : () async {
                          await _pickAndAnalyzeVideo(context, provider);
                        },
                  icon: const Icon(Icons.video_file),
                  label: const Text('Analyze Video'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: provider.isAnalyzing
                      ? null
                      : () => _runDemoAnalysis(provider),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run Demo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple.shade600,
                    side: BorderSide(color: Colors.purple.shade600),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeclaredDataCard(
    BuildContext context,
    BackgroundVerificationProvider provider,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.assignment,
                      color: Colors.orange.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Declared Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Customer\'s declared environment',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => Get.to(() => const DeclaredDataInputPage()),
                icon: Icon(
                  provider.declaredData != null ? Icons.edit : Icons.add,
                  size: 16,
                ),
                label: Text(provider.declaredData != null ? 'Edit' : 'Set'),
              ),
            ],
          ),
          if (provider.declaredData != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Environment: ${provider.declaredData!.declaredEnvironment.toString().split('.').last.toUpperCase()} • ${provider.declaredData!.declaredItems.length} items declared',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(BackgroundVerificationProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          if (provider.isAnalyzing)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
              ),
            )
          else
            Icon(Icons.info, color: Colors.blue.shade600, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.currentStatus,
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickResultsCard(
    BuildContext context,
    BackgroundVerificationProvider provider,
  ) {
    final result = provider.currentResult!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Analysis Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildResultMetric(
                  'Environment',
                  result.environmentAnalysis.detectedEnvironment
                      .toString()
                      .split('.')
                      .last
                      .toUpperCase(),
                  '${(result.environmentAnalysis.confidence * 100).toInt()}%',
                  _getEnvironmentColor(
                    result.environmentAnalysis.detectedEnvironment,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultMetric(
                  'Risk Score',
                  '${(result.riskAssessment.riskScore * 100).toInt()}%',
                  result.riskAssessment.riskLevel
                      .toString()
                      .split('.')
                      .last
                      .toUpperCase(),
                  _getRiskColor(result.riskAssessment.riskLevel),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.to(() => const VerificationResultPage()),
              icon: const Icon(Icons.visibility),
              label: const Text('View Detailed Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultMetric(
    String label,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
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

  Future<void> _pickAndAnalyzeImage(
    BuildContext context,
    BackgroundVerificationProvider provider,
  ) async {
    await VideoFrameAnalyzer.pickImageAndAnalyze(
      verificationProvider: provider,
    );

    // Navigate to results if analysis completed successfully
    if (provider.currentResult != null) {
      Get.to(() => const VerificationResultPage());
    }
  }

  Future<void> _pickAndAnalyzeVideo(
    BuildContext context,
    BackgroundVerificationProvider provider,
  ) async {
    await VideoFrameAnalyzer.pickVideoAndAnalyzeFrames(
      verificationProvider: provider,
    );

    // Navigate to results if analysis completed successfully
    if (provider.currentResult != null) {
      Get.to(() => const VerificationResultPage());
    }
  }

  void _runDemoAnalysis(BackgroundVerificationProvider provider) {
    // Set sample declared data
    provider.setDeclaredData(SampleDataProvider.getHomeSampleData());

    // Simulate analysis result
    final sampleResult = SampleDataProvider.generateHighRiskSampleResult();
    provider.simulateAnalysisResult(sampleResult);

    // Navigate to results
    Get.to(() => const VerificationResultPage());

    ScaffoldMessenger.of(Get.context!).showSnackBar(
      const SnackBar(
        content: Text('Demo analysis completed with sample data'),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
