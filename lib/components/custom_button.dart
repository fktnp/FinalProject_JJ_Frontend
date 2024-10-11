import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class FixedBottomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color buttonColor;
  final Icon icon;

  const FixedBottomButton({
    super.key,
    required this.onPressed,
    this.buttonColor = Colors.blue,
    this.icon = const Icon(Icons.add),
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: const Color(0xFFFFDCBC),
        child: const Icon(Icons.add),
      ),
    );
  }
}
