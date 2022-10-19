import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

enum Type { google, facebook }

class MyProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;

  bool _isSignedIn = false;
  get isSignedIn => _isSignedIn;

  Type? _type;
  get type => _type;

  String? _id;
  get id => _id;

  String? _name;
  get name => _name;

  String? _email;
  get email => _email;

  String? _imageUrl;
  get imageUrl => _imageUrl;

  String? _error;
  get error => _error;

  // sign in with google
  Future<void> signInWithGoogle() async {
    _type = Type.google;
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();

    if (googleSignInAccount != null) {
      //authentication
      try {
        final GoogleSignInAuthentication gsa =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: gsa.accessToken,
          idToken: gsa.idToken,
        );

        // signing to firebase user instance
        final User userDetails =
            (await firebaseAuth.signInWithCredential(credential)).user!;

        // now save all values
        _id = userDetails.uid;
        _name = userDetails.displayName;
        _email = userDetails.email;
        _imageUrl = userDetails.photoURL;

        _isSignedIn = true;
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    } else {
      _error = "Error Signing in";
      notifyListeners();
    }
  }

  // sign in with facebook
  Future<void> signInWithFacebook() async {
    _type = Type.facebook;
    final LoginResult result = await facebookAuth.login();
    // getting the profile
    final res = await http.get(Uri.parse(
        'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${result.accessToken!.token}'));

    final userData = jsonDecode(res.body);

    if (result.status == LoginStatus.success) {
      try {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        await firebaseAuth.signInWithCredential(credential);
        _id = userData['id'];
        _name = userData['name'];
        _email = userData['email'];
        _imageUrl = userData['picture']['data']['url'];
        _isSignedIn = true;

        notifyListeners();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    } else {
      _error = "Error Signing in";
      notifyListeners();
    }
  }

  // sign out of google
  Future<void> signOutOfGoogle() async {
    await firebaseAuth.signOut();
    await GoogleSignIn().signOut();
    _isSignedIn = false;
    notifyListeners();
  }

  // sign out of facebook
  Future<void> signOutOfFacebook() async {
    await firebaseAuth.signOut();
    await facebookAuth.logOut();
    _isSignedIn = false;
    notifyListeners();
  }

  // save data to firebase
  Future<void> saveDataToFirestore() async {
    final DocumentReference dr =
        FirebaseFirestore.instance.collection("users").doc(_id);
    await dr.set({
      "id": _id,
      "name": _name,
      "email": _email,
      "image_url": _imageUrl,
    });
  }
}
