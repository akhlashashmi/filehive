import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    this.obscureText,
    this.height,
    this.prefixIcon,
    this.prefix,
    this.maxLength,
    this.keyboardType,
    this.hintText,
    this.onChanged,
    this.controller,
    this.validator,
    this.onSaved,
    super.key,
    this.padding,
    this.suffixIcon,
    this.topLeftRadius,
    this.topRightRadius,
    this.bottomRightRadius,
    this.bottomLeftRadius,
    this.onFieldSubmitted,
    this.textAlign,
    this.maxLines,
    this.fillColor,
    this.enabled,
  });
  final void Function(String? value)? onChanged;
  final void Function(String? value)? onSaved;
  final String? Function(String? value)? validator;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? prefix;
  final int? maxLength;
  final EdgeInsetsGeometry? padding;
  final bool? obscureText;
  final Widget? suffixIcon;
  final double? height;
  final double? topLeftRadius;
  final double? topRightRadius;
  final double? bottomRightRadius;
  final double? bottomLeftRadius;
  final TextAlign? textAlign;
  final int? maxLines;
  final Color? fillColor;
  final void Function(String? value)? onFieldSubmitted;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText ?? false,
      maxLength: maxLength,
      keyboardType: keyboardType,
      controller: controller,
      validator: validator,
      maxLines: maxLines ?? 1,
      onSaved: onSaved,
      textAlign: (textAlign != null) ? textAlign! : TextAlign.left,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
      cursorColor: Theme.of(context).colorScheme.onBackground,
      decoration: InputDecoration(
        enabled: enabled ?? true,
        // contentPadding: EdgeInsets.fromLTRB(25, height ?? 23, 25, height ?? 23),
        filled: true,
        suffixIcon: (suffixIcon == null) ? null : suffixIcon,
        counterText: '',
        fillColor: fillColor ??
            Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
        hintText: 'Search files',
        prefixIcon: prefixIcon,
        prefix: prefix,

        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          // borderRadius: BorderRadius.circular(radius ?? 10),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeftRadius ?? 15),
            bottomLeft: Radius.circular(bottomLeftRadius ?? 15),
            bottomRight: Radius.circular(bottomRightRadius ?? 15),
            topRight: Radius.circular(topRightRadius ?? 15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeftRadius ?? 15),
            bottomLeft: Radius.circular(bottomLeftRadius ?? 15),
            bottomRight: Radius.circular(bottomRightRadius ?? 15),
            topRight: Radius.circular(topRightRadius ?? 15),
          ),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeftRadius ?? 15),
            bottomLeft: Radius.circular(bottomLeftRadius ?? 15),
            bottomRight: Radius.circular(bottomRightRadius ?? 15),
            topRight: Radius.circular(topRightRadius ?? 15),
          ),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeftRadius ?? 15),
            bottomLeft: Radius.circular(bottomLeftRadius ?? 15),
            bottomRight: Radius.circular(bottomRightRadius ?? 15),
            topRight: Radius.circular(topRightRadius ?? 15),
          ),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeftRadius ?? 15),
            bottomLeft: Radius.circular(bottomLeftRadius ?? 15),
            bottomRight: Radius.circular(bottomRightRadius ?? 15),
            topRight: Radius.circular(topRightRadius ?? 15),
          ),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}

InputDecoration searchDecoration(
  BuildContext context, {
  String? hint,
  double? radius,
  double? height,
  String? counterText,
  Icon? prefixIcon,
  Widget? suffixIcon,
  double? topLeftRadius,
  double? bottomLeftRadius,
  double? bottomRightRadius,
  double? topRightRadius,
  Color? backgroundColor,
}) {
  return InputDecoration(
    contentPadding: EdgeInsets.fromLTRB(25, height ?? 20, 25, height ?? 20),
    filled: true,
    suffixIcon: (suffixIcon == null) ? null : suffixIcon,
    counterText: counterText,
    fillColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
    hintText: hint ?? 'search',
    prefixIcon: prefixIcon,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: (radius != null)
          ? BorderRadius.circular(radius)
          : BorderRadius.only(
              topLeft: Radius.circular(topLeftRadius ?? 30),
              bottomLeft: Radius.circular(bottomLeftRadius ?? 30),
              bottomRight: Radius.circular(bottomRightRadius ?? 30),
              topRight: Radius.circular(topRightRadius ?? 30),
            ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius ?? 30),
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius ?? 30),
      borderSide: BorderSide.none,
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius ?? 30),
      borderSide: BorderSide.none,
    ),
  );
}
