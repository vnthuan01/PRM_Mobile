import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? child; // Thêm child để hỗ trợ icon + text
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;

  const CustomButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.loading = false,
    this.enabled = true,
  }) : assert(text != null || child != null, "Phải có text hoặc child");

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? color : color.withOpacity(0.5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: enabled && !loading ? onPressed : null,
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : child ?? Text(
                text!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }
}
