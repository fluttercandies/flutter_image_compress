import 'package:flutter/material.dart';

class TextButton extends StatelessWidget {
  const TextButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
