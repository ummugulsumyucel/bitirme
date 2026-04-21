import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;
  final List<Widget>? actions;

  const CommonAppBar({
    super.key,
    required this.title,
    this.onToggleTheme,
    this.isDarkMode = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: const Color(0xFF1E3A8A),
      foregroundColor: Colors.white,
      actions: [
        if (actions != null) ...actions!,
        if (onToggleTheme != null)
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: onToggleTheme,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
