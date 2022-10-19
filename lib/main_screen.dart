import 'package:auth/login_screen.dart';
import 'package:auth/my_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MyProvider>();

    afterSignOut() {
      if (!provider.isSignedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const LoginScreen(),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.type == Type.google ? 'Google' : 'Facebook'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(provider.imageUrl),
            Text('Id : ${provider.id}'),
            Text('Name : ${provider.name}'),
            Text('Email : ${provider.email}'),
            ElevatedButton(
              onPressed: () async {
                if (provider.type == Type.google) {
                  await provider.signOutOfGoogle();
                } else if (provider.type == Type.facebook) {
                  await provider.signOutOfFacebook();
                }
                afterSignOut();
              },
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
