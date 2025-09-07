import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'background_verification_home_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Vision IQ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo.shade800,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
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
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.security,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Background Verification',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Intelligent fraud detection for video calls',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.to(
                          () => const BackgroundVerificationHomePage(),
                        ),
                        icon: const Icon(Icons.rocket_launch, size: 20),
                        label: const Text('Launch Verification System'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.indigo.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Legacy System Section (Simplified)
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(16),
              //     border: Border.all(color: Colors.grey.shade200),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.grey.withValues(alpha: 0.1),
              //         blurRadius: 10,
              //         offset: const Offset(0, 4),
              //       ),
              //     ],
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         children: [
              //           Container(
              //             padding: const EdgeInsets.all(8),
              //             decoration: BoxDecoration(
              //               color: Colors.orange.shade100,
              //               borderRadius: BorderRadius.circular(8),
              //             ),
              //             child: Icon(
              //               Icons.video_library,
              //               color: Colors.orange.shade600,
              //             ),
              //           ),
              //           const SizedBox(width: 12),
              //           const Text(
              //             'Legacy Video Analysis',
              //             style: TextStyle(
              //               fontSize: 18,
              //               fontWeight: FontWeight.w600,
              //             ),
              //           ),
              //         ],
              //       ),
              //       const SizedBox(height: 12),
              //       const Text(
              //         'Basic video frame analysis with Gemini AI',
              //         style: TextStyle(color: Colors.grey),
              //       ),
              //       const SizedBox(height: 16),
              //       Row(
              //         children: [
              //           Expanded(
              //             child: OutlinedButton.icon(
              //               onPressed: () async {
              //                 await VideoAnalyzer.pickVideo(
              //                   videoProvider: videoProvider,
              //                   context: context,
              //                 );
              //                 if (videoProvider
              //                     .geminiModel
              //                     .environmentType
              //                     .isNotEmpty) {
              //                   Get.to(() => const ResultPage());
              //                 } else {
              //                   ScaffoldMessenger.of(context).showSnackBar(
              //                     const SnackBar(
              //                       content: Text(
              //                         'Analysis failed - check API key',
              //                       ),
              //                       backgroundColor: Colors.red,
              //                     ),
              //                   );
              //                 }
              //               },
              //               icon: const Icon(Icons.video_file),
              //               label: const Text('Analyze Video'),
              //             ),
              //           ),
              //           const SizedBox(width: 12),
              //           OutlinedButton(
              //             onPressed: () {
              //               videoProvider.clear();
              //               ScaffoldMessenger.of(context).showSnackBar(
              //                 const SnackBar(
              //                   content: Text('Data cleared'),
              //                   backgroundColor: Colors.green,
              //                 ),
              //               );
              //             },
              //             child: const Icon(Icons.clear),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 24),

              // Feature Highlights
              const Row(
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('Environment Detection', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 20),
                  Icon(Icons.analytics, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text('Fraud Analysis', style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
