import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectScreen extends StatelessWidget {
  final String title;
  final String description;
  const ProjectScreen(
      {super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B0D10);
    const text = Color(0xFFEEF1F4);
    const muted = Color(0xFF9AA5B1);
    const accent = Color(0xFF4CC2FF);

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w800, color: text)),
              const SizedBox(height: 12),
              Text(description,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 16, height: 1.7, color: muted)),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('← 홈으로',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: accent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
