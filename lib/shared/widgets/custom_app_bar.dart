import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/shared/widgets/app_bar_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final bool defaultActions;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.defaultActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: [
        ...?actions,
        if (defaultActions) ...[
          AppBarButton(
            icon: Icons.settings,
            tooltip: 'Configuración',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
