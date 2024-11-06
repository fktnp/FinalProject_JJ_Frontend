import 'package:flutter/material.dart';

import '../model/theme.dart';

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
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: pastel.pastel1,
        child: const Icon(Icons.add),
      ),
    );
  }
}
