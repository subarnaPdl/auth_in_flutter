import 'package:auth/main_screen.dart';
import 'package:flutter/material.dart';
import 'my_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MyProvider>();

    afterSignIn() {
      provider.saveDataToFirestore();
      if (provider.isSignedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const MainScreen(),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await provider.signInWithGoogle();
                afterSignIn();
              },
              child: const Text('Google login'),
            ),
            ElevatedButton(
              onPressed: () async {
                provider.signInWithFacebook();
                afterSignIn();
              },
              child: const Text('Facebook login'),
            ),
            const SizedBox(height: 30),
            if (provider.error != null) Text(provider.error),
          ],
        ),
      ),
    );
  }
}
