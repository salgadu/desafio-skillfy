import 'package:flutter/material.dart';

enum ButtonVariant { filled, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.filled,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  });

  const CustomButton.filled({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : variant = ButtonVariant.filled;

  const CustomButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : variant = ButtonVariant.outlined;

  const CustomButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : variant = ButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final child = _buildChild();
    final buttonOnPressed = isLoading ? null : onPressed;

    Widget button;

    switch (variant) {
      case ButtonVariant.filled:
        button = ElevatedButton(onPressed: buttonOnPressed, child: child);
        break;
      case ButtonVariant.outlined:
        button = OutlinedButton(onPressed: buttonOnPressed, child: child);
        break;
      case ButtonVariant.text:
        button = TextButton(onPressed: buttonOnPressed, child: child);
        break;
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [icon!, const SizedBox(width: 8), Text(text)],
      );
    }

    return Text(text);
  }
}
