import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

enum TextFieldVariant { outlined, filled, underlined }

enum TextFieldSize { small, medium, large }

/// Campo de texto personalizado com validação
///
/// ## Uso básico:
/// ```dart
/// CustomTextField(
///   controller: _controller,
///   labelText: 'Nome',
/// )
/// ```
///
/// ## Com validação:
/// ```dart
/// CustomTextField(
///   controller: _emailController,
///   labelText: 'Email',
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) {
///     if (value?.isEmpty == true) return 'Email obrigatório';
///     if (!value!.contains('@')) return 'Email inválido';
///     return null;
///   },
/// )
/// ```
///
/// ## Com ícone:
/// ```dart
/// CustomTextField(
///   controller: _passwordController,
///   labelText: 'Senha',
///   isPassword: true,
///   prefixIcon: Icons.lock,
/// )
/// ```
///
/// ## Parâmetros obrigatórios:
/// - [controller]: Controlador do campo
///
/// ## Parâmetros opcionais:
/// - [labelText]: Rótulo do campo
/// - [hintText]: Texto de dica
/// - [isRequired]: Se é obrigatório (padrão: false)
/// - [validator]: Função de validação
/// - [prefixIcon]: Ícone à esquerda
/// - [variant]: Estilo visual (padrão: outlined)
/// - [size]: Tamanho do campo (padrão: medium)
class CustomTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool isRequired;
  final bool isEnabled;
  final bool isReadOnly;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final TextFieldVariant variant;
  final TextFieldSize size;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? fillColor;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool enableSuggestions;

  const CustomTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.isRequired = false,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.variant = TextFieldVariant.outlined,
    this.size = TextFieldSize.medium,
    this.contentPadding,
    this.borderRadius,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.fillColor,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  const CustomTextField.small({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.isRequired = false,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.variant = TextFieldVariant.outlined,
    this.contentPadding,
    this.borderRadius,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.fillColor,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.autocorrect = true,
    this.enableSuggestions = true,
  }) : size = TextFieldSize.small;

  const CustomTextField.large({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.isRequired = false,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.variant = TextFieldVariant.outlined,
    this.contentPadding,
    this.borderRadius,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.fillColor,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.autocorrect = true,
    this.enableSuggestions = true,
  }) : size = TextFieldSize.large;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fieldSize = _getFieldSize();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Row(
            children: [
              Text(
                widget.labelText!,
                style: TextStyle(
                  fontSize: fieldSize.labelFontSize,
                  fontWeight: FontWeight.w500,
                  color: widget.isEnabled
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    fontSize: fieldSize.labelFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword ? _obscureText : false,
          enabled: widget.isEnabled,
          readOnly: widget.isReadOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          autofocus: widget.autofocus,
          textCapitalization: widget.textCapitalization,
          textInputAction: widget.textInputAction,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          decoration: _buildInputDecoration(fieldSize),
        ),
        if (widget.helperText != null && widget.errorText == null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildInputDecoration(_TextFieldSize fieldSize) {
    final colors = _getColors();

    return InputDecoration(
      hintText: widget.hintText,
      hintStyle: TextStyle(
        color: AppColors.textSecondary,
        fontSize: fieldSize.fontSize,
      ),
      helperText: widget.helperText,
      errorText: widget.errorText,
      prefixIcon: widget.prefixIcon != null
          ? Icon(
              widget.prefixIcon,
              color: colors.iconColor,
              size: fieldSize.iconSize,
            )
          : null,
      suffixIcon: _buildSuffixIcon(fieldSize),
      contentPadding: widget.contentPadding ?? fieldSize.contentPadding,
      filled: widget.variant == TextFieldVariant.filled,
      fillColor:
          widget.fillColor ??
          (widget.variant == TextFieldVariant.filled
              ? AppColors.greyLight
              : null),
      border: _buildBorder(colors.borderColor),
      enabledBorder: _buildBorder(colors.borderColor),
      focusedBorder: _buildBorder(colors.focusedBorderColor, width: 2),
      errorBorder: _buildBorder(colors.errorBorderColor),
      focusedErrorBorder: _buildBorder(colors.errorBorderColor, width: 2),
      disabledBorder: _buildBorder(AppColors.greyLight),
    );
  }

  Widget? _buildSuffixIcon(_TextFieldSize fieldSize) {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textSecondary,
          size: fieldSize.iconSize,
        ),
        onPressed: _toggleVisibility,
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: AppColors.textSecondary,
          size: fieldSize.iconSize,
        ),
        onPressed: widget.onSuffixIconPressed,
      );
    }

    return null;
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius:
          widget.borderRadius ??
          BorderRadius.circular(_getFieldSize().borderRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  _TextFieldColors _getColors() {
    if (!widget.isEnabled) {
      return _TextFieldColors(
        borderColor: AppColors.greyLight,
        focusedBorderColor: AppColors.greyLight,
        errorBorderColor: AppColors.greyLight,
        iconColor: AppColors.textSecondary,
      );
    }

    if (widget.errorText != null) {
      return _TextFieldColors(
        borderColor: AppColors.danger,
        focusedBorderColor: AppColors.danger,
        errorBorderColor: AppColors.danger,
        iconColor: AppColors.danger,
      );
    }

    return _TextFieldColors(
      borderColor: widget.borderColor ?? AppColors.grey,
      focusedBorderColor: widget.focusedBorderColor ?? AppColors.primary,
      errorBorderColor: widget.errorBorderColor ?? AppColors.danger,
      iconColor: AppColors.textSecondary,
    );
  }

  _TextFieldSize _getFieldSize() {
    switch (widget.size) {
      case TextFieldSize.small:
        return _TextFieldSize(
          height: 40,
          fontSize: 14,
          labelFontSize: 14,
          iconSize: 18,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          borderRadius: 6,
        );
      case TextFieldSize.medium:
        return _TextFieldSize(
          height: 48,
          fontSize: 16,
          labelFontSize: 16,
          iconSize: 20,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          borderRadius: 8,
        );
      case TextFieldSize.large:
        return _TextFieldSize(
          height: 56,
          fontSize: 18,
          labelFontSize: 18,
          iconSize: 22,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          borderRadius: 10,
        );
    }
  }
}

class _TextFieldColors {
  final Color borderColor;
  final Color focusedBorderColor;
  final Color errorBorderColor;
  final Color iconColor;

  _TextFieldColors({
    required this.borderColor,
    required this.focusedBorderColor,
    required this.errorBorderColor,
    required this.iconColor,
  });
}

class _TextFieldSize {
  final double height;
  final double fontSize;
  final double labelFontSize;
  final double iconSize;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;

  _TextFieldSize({
    required this.height,
    required this.fontSize,
    required this.labelFontSize,
    required this.iconSize,
    required this.contentPadding,
    required this.borderRadius,
  });
}
