import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaku/core/router/app_routes.dart';
import 'package:kaku/shared/widgets/app_bar_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final bool defaultActions;

  // Parámetros AppBar
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.defaultActions = false,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation,
    this.bottom,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      elevation: elevation,
      bottom: bottom,
      centerTitle: centerTitle,
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
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
