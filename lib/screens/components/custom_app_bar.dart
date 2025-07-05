import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showDrawer;
  final VoidCallback? onDrawerPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showDrawer = false,
    this.onDrawerPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      centerTitle: centerTitle,
      elevation: elevation,
      leading: showDrawer
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed:
                  onDrawerPressed ??
                  () {
                    Scaffold.of(context).openDrawer();
                  },
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// AppBar específica para telas com drawer
class DrawerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final String currentRoute;

  const DrawerAppBar({
    super.key,
    required this.title,
    this.actions,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(title: title, actions: actions, showDrawer: true);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// AppBar para telas de formulário (sem drawer)
class FormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const FormAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(title: title, actions: actions, showDrawer: false);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// AppBar para dashboards
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const DashboardAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(title: title, actions: actions, showDrawer: true);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// AppBar para telas com TabBar
class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TabController tabController;
  final List<Tab> tabs;
  final List<Widget>? actions;

  const TabAppBar({
    super.key,
    required this.title,
    required this.tabController,
    required this.tabs,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      actions: actions,
      bottom: TabBar(
        controller: tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: tabs,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48); // Altura da AppBar + TabBar
}
