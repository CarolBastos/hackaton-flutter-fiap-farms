import 'package:fiap_farms/utils/app_colors.dart';
import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, danger, success, outline, text }

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool iconOnly;
  final double? customWidth;
  final double? customHeight;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.iconOnly = false,
    this.customWidth,
    this.customHeight,
    this.padding,
    this.borderRadius,
  });

  const CustomButton.small({
    super.key,
    required this.onPressed,
    required this.text,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconOnly = false,
    this.customWidth,
    this.customHeight,
    this.padding,
    this.borderRadius,
  }) : size = ButtonSize.small;

  const CustomButton.large({
    super.key,
    required this.onPressed,
    required this.text,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.iconOnly = false,
    this.customWidth,
    this.customHeight,
    this.padding,
    this.borderRadius,
  }) : size = ButtonSize.large;

  const CustomButton.icon({
    super.key,
    required this.onPressed,
    required this.icon,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customWidth,
    this.customHeight,
    this.padding,
    this.borderRadius,
  }) : text = '',
       iconOnly = true;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final buttonSize = _getButtonSize();

    Widget buttonChild = _buildButtonChild();

    if (isLoading) {
      buttonChild = SizedBox(
        width: _getLoadingSize(),
        height: _getLoadingSize(),
        child: CircularProgressIndicator(
          color: _getTextColor(),
          strokeWidth: 2,
        ),
      );
    }

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: buttonChild,
    );

    if (isFullWidth || customWidth != null) {
      return SizedBox(
        width: customWidth ?? double.infinity,
        height: customHeight ?? buttonSize.height,
        child: button,
      );
    }

    return SizedBox(
      width: customWidth,
      height: customHeight ?? buttonSize.height,
      child: button,
    );
  }

  Widget _buildButtonChild() {
    if (iconOnly) {
      return Icon(icon, size: _getIconSize());
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          Text(text, style: _getTextStyle()),
        ],
      );
    }

    return Text(text, style: _getTextStyle());
  }

  ButtonStyle _getButtonStyle() {
    final colors = _getColors();
    final size = _getButtonSize();

    return ElevatedButton.styleFrom(
      backgroundColor: colors.backgroundColor,
      foregroundColor: colors.foregroundColor,
      disabledBackgroundColor: colors.disabledBackgroundColor,
      disabledForegroundColor: colors.disabledForegroundColor,
      elevation:
          variant == ButtonVariant.outline || variant == ButtonVariant.text
          ? 0
          : 2,
      shadowColor: Colors.transparent,
      padding: padding ?? size.padding,
      minimumSize: Size(size.width, size.height),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(size.borderRadius),
        side: variant == ButtonVariant.outline
            ? BorderSide(color: colors.borderColor, width: 1.5)
            : BorderSide.none,
      ),
    );
  }

  _ButtonColors _getColors() {
    switch (variant) {
      case ButtonVariant.primary:
        return _ButtonColors(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          disabledBackgroundColor: AppColors.greyLight,
          disabledForegroundColor: AppColors.textSecondary,
          borderColor: AppColors.primary,
        );
      case ButtonVariant.secondary:
        return _ButtonColors(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textWhite,
          disabledBackgroundColor: AppColors.greyLight,
          disabledForegroundColor: AppColors.textSecondary,
          borderColor: AppColors.secondary,
        );
      case ButtonVariant.danger:
        return _ButtonColors(
          backgroundColor: AppColors.danger,
          foregroundColor: AppColors.textWhite,
          disabledBackgroundColor: AppColors.greyLight,
          disabledForegroundColor: AppColors.textSecondary,
          borderColor: AppColors.danger,
        );
      case ButtonVariant.success:
        return _ButtonColors(
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.textWhite,
          disabledBackgroundColor: AppColors.greyLight,
          disabledForegroundColor: AppColors.textSecondary,
          borderColor: AppColors.success,
        );
      case ButtonVariant.outline:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.greyLight,
          disabledForegroundColor: AppColors.textSecondary,
          borderColor: AppColors.primary,
        );
      case ButtonVariant.text:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.textSecondary,
          borderColor: Colors.transparent,
        );
    }
  }

  _ButtonSize _getButtonSize() {
    switch (size) {
      case ButtonSize.small:
        return _ButtonSize(
          height: 32,
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          borderRadius: 6,
          fontSize: 12,
        );
      case ButtonSize.medium:
        return _ButtonSize(
          height: 40,
          width: 120,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: 8,
          fontSize: 14,
        );
      case ButtonSize.large:
        return _ButtonSize(
          height: 48,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          borderRadius: 10,
          fontSize: 16,
        );
    }
  }

  TextStyle _getTextStyle() {
    final buttonSize = _getButtonSize();
    return TextStyle(
      fontSize: buttonSize.fontSize,
      fontWeight: FontWeight.w600,
      color: _getTextColor(),
    );
  }

  Color _getTextColor() {
    final colors = _getColors();
    return isLoading ? colors.disabledForegroundColor : colors.foregroundColor;
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }
}

class _ButtonColors {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color disabledBackgroundColor;
  final Color disabledForegroundColor;
  final Color borderColor;

  _ButtonColors({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.disabledBackgroundColor,
    required this.disabledForegroundColor,
    required this.borderColor,
  });
}

class _ButtonSize {
  final double height;
  final double width;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double fontSize;

  _ButtonSize({
    required this.height,
    required this.width,
    required this.padding,
    required this.borderRadius,
    required this.fontSize,
  });
}
