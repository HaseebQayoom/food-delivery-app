import 'package:flutter/material.dart';

class AuthText extends StatelessWidget {
  const AuthText({
    super.key,
    required this.loginText,
    required this.loginText2,
  });

  final String loginText;
  final String loginText2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loginText, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(loginText2, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
