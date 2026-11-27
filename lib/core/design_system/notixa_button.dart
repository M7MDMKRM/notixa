import 'package:flutter/material.dart';
import '../../app/theme/notixa_palette.dart';

enum NotixaButtonType { primary, secondary, outline, text }

class NotixaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final NotixaButtonType type;
  final double? width;
  final double height;
  final Color? customColor;

  const NotixaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.type = NotixaButtonType.primary,
    this.width,
    this.height = 52,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (type) {
      case NotixaButtonType.primary:
        bg = customColor ?? NotixaPalette.primary;
        fg = Colors.white;
        break;
      case NotixaButtonType.secondary:
        bg = customColor ?? (isDark ? NotixaPalette.darkSurface : NotixaPalette.lightSurface);
        fg = isDark ? NotixaPalette.textPrimaryDark : NotixaPalette.textPrimaryLight;
        border = BorderSide(color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder);
        break;
      case NotixaButtonType.outline:
        bg = Colors.transparent;
        fg = customColor ?? NotixaPalette.primary;
        border = BorderSide(color: customColor ?? NotixaPalette.primary);
        break;
      case NotixaButtonType.text:
        bg = Colors.transparent;
        fg = customColor ?? NotixaPalette.primary;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: border,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
