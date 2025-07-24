// widgets/common/custom_app_bar.dart
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor,
      leading:
          leading ??
          (ModalRoute.of(context)?.canPop == true
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                )
              : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
