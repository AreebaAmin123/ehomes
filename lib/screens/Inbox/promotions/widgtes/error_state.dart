import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  const ErrorState({super.key, required this.error, this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red.shade200),
          SizedBox(height: 16),
          Text(
            error,
            style: TextStyle(fontSize: 16, color: Colors.red.shade700),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
