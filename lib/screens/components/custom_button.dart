import 'package:fiap_farms/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function()? onPressed;
  final String text;
  final Color backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: SizedBox(
        height: height ?? 48,
        width: width ?? double.infinity,
        child: ElevatedButton(
          onPressed: isLoading || onPressed == null
              ? null
              : () {
                  final result = onPressed!();
                  if (result is Future) {
                    result.catchError((e) {
                      // Trate erros silenciosamente ou logue, se quiser
                      debugPrint("Erro no botão: $e");
                    });
                  }
                },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(width ?? double.infinity, height ?? 48),
            backgroundColor: backgroundColor,
            foregroundColor: textColor ?? AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
