// widgets/common/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final String? initialValue;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
    this.focusNode,
    this.initialValue,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          onChanged: onChanged,
          onSaved: onSaved,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          readOnly: readOnly,
          enabled: enabled,
          onTap: onTap,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            counterText: maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }
}
