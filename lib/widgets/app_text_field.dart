import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  final bool obscureText;
  final bool showPasswordIcon;

  final Color fillColor;

  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.showPasswordIcon = false,
    this.fillColor = AppColors.card,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: widget.controller,

        obscureText: _obscure,

        readOnly: widget.readOnly,

        onTap: widget.onTap,

        style: AppTextStyles.body,

        decoration: InputDecoration(
          hintText: widget.hintText,

          hintStyle: AppTextStyles.body,

          filled: true,

          fillColor: widget.fillColor,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),

          suffixIcon: widget.showPasswordIcon
              ? IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                )
              : null,

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.border),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.border, width: 2),
          ),
        ),
      ),
    );
  }
}
