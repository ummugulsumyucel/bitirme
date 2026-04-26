import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final bool showDrawerButton;

  const CommonAppBar({
    super.key,
    required this.title,
    this.onToggleTheme,
    this.isDarkMode = false,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.showDrawerButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scaffold = Scaffold.maybeOf(context);
    final hasDrawer = scaffold?.hasDrawer ?? false;

    return AppBar(
      title: Text(title),
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: hasDrawer
          ? Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                tooltip: 'Menü',
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            )
          : null,
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
