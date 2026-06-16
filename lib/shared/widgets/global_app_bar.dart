import 'package:flutter/material.dart';

import 'package:surti_nova/core/services/storage_service.dart';
import 'package:surti_nova/core/theme/app_colors.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const GlobalAppBar({
    super.key,
    required this.title,
  });

  Future<void> _logout(BuildContext context) async {
    await StorageService.clearSession();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _logout(context),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}