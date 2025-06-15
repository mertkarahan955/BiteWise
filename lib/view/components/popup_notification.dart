import 'dart:async';
import 'package:flutter/material.dart';

enum PopupNotificationType { success, error, info }

class PopupNotification extends StatefulWidget {
  final String message;
  final PopupNotificationType type;
  final Duration duration;
  final VoidCallback? onClose;

  const PopupNotification({
    super.key,
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 2),
    this.onClose,
  });

  @override
  State<PopupNotification> createState() => _PopupNotificationState();
}

class _PopupNotificationState extends State<PopupNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    _timer = Timer(widget.duration, () {
      _controller.reverse().then((_) {
        widget.onClose?.call();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  IconData getIcon() {
    switch (widget.type) {
      case PopupNotificationType.success:
        return Icons.check_circle_rounded;
      case PopupNotificationType.error:
        return Icons.error_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color getColor() {
    switch (widget.type) {
      case PopupNotificationType.success:
        return Colors.green;
      case PopupNotificationType.error:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final barColor = getColor();
    return SlideTransition(
      position: _offsetAnimation,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Colored bar at the top
                  Container(
                    height: 5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(getIcon(), color: getColor(), size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress bar
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: 1.0 - _controller.value,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(getColor()),
                        minHeight: 4,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
