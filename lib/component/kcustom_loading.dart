import 'package:flutter/material.dart';

class CustomPopups {
  static void showCustomLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const KCustomLoading(),
    );
  }
}

class KCustomLoading extends StatelessWidget {
  const KCustomLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
              "Analyzing Video",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              "Please Wait...",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
