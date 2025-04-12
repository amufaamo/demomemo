// lib/widgets/loading_indicator.dart
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0), // 上下の余白
        child: CircularProgressIndicator(),
      ),
    );
  }
}