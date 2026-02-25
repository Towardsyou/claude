import 'package:flutter/material.dart';

/// Error page - Captures and displays Flutter build errors
/// This page is used for Maestro testing to detect red screen errors
class ErrorPage extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;

  const ErrorPage({this.errorDetails, super.key});

  @override
  Widget build(BuildContext context) {
    final errorMessage = errorDetails?.exception.toString() ?? 'Unknown error';

    return Semantics(
      // Critical marker for Maestro detection
      label: 'ERROR_SCREEN_DETECTED',
      child: Container(
        color: const Color(0xFFD32F2F),
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.yellow, size: 48),
              const SizedBox(height: 16),
              const Text('ERROR',
                  style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(errorMessage,
                      style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 14,
                          fontFamily: 'monospace')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
