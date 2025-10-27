import 'package:flutter/material.dart';

class FloatingChatButton extends StatefulWidget {
  final VoidCallback onTap;
  const FloatingChatButton({super.key, required this.onTap});

  @override
  State<FloatingChatButton> createState() => _FloatingChatButtonState();
}

class _FloatingChatButtonState extends State<FloatingChatButton> {
  Offset position = const Offset(350, 750); // Vị trí khởi tạo

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            // Cập nhật vị trí button khi kéo
            position += details.delta;

            // Giới hạn button trong màn hình
            final screenSize = MediaQuery.of(context).size;
            final buttonSize = 64.0; // chiều rộng + padding
            position = Offset(
              position.dx.clamp(0.0, screenSize.width - buttonSize),
              position.dy.clamp(0.0, screenSize.height - buttonSize),
            );
          });
        },
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: const Icon(
            Icons.chat_bubble_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
