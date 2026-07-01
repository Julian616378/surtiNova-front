import 'package:flutter/material.dart';
import '../../shared/theme/app_theme.dart';

class CarritoFab extends StatelessWidget {
  final int totalItems;
  final VoidCallback onTap;

  const CarritoFab({super.key, required this.totalItems, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) return const SizedBox.shrink();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton(
          onPressed: onTap,
          backgroundColor: AppTheme.primary,
          elevation: 4,
          child: const Icon(Icons.shopping_cart, color: Colors.white, size: 26),
        ),
        Positioned(
          top: -4, right: -4,
          child: Container(
            padding: const EdgeInsets.all(5),
            constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '$totalItems',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}