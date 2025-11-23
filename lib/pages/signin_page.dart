import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_note/auth_helper.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final AuthHelper authHelper = AuthHelper();
  TextEditingController emailController = TextEditingController();
  TextEditingController psswdController = TextEditingController();

  bool passwordVisible = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'Signin',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                SizedBox.square(dimension: 32),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Input Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                SizedBox.square(dimension: 16),
                TextField(
                  controller: psswdController,
                  obscureText: passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Input Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox.square(dimension: 16),
                ElevatedButton(
                  onPressed: () async {
                    _signInWithEmail();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('Signin'),
                    ),
                  ),
                ),
                SizedBox.square(dimension: 16),
                Text('or'),
                SizedBox.square(dimension: 16),
                ElevatedButton(
                  onPressed: () async {
                    _signInWithGoogle();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('Signin with Google'),
                    ),
                  ),
                ),
                SizedBox.square(dimension: 32),
                Row(
                  children: [
                    Text('Not have an account?'),
                    SizedBox.square(dimension: 4),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text('Signup'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _signInWithEmail() async {
    try {
      final result = await authHelper.signInWithEmailAndPassword(
        emailController.text,
        psswdController.text,
      );

      if (mounted) {
        _showSnackbar('Signin success as ${result.user?.email}');
        //Navigator.pushNamed(context, NavigationRoutes.movieList.name);
      }
    } on FirebaseAuthException catch (e) {
      _showSnackbar('Signin fail: ${e.message}');
    } catch (e) {
      _showSnackbar('Signin fail');
    }

    emailController.clear();
    psswdController.clear();
  }

  Future _signInWithGoogle() async {
    try {
      final result = await authHelper.signInWithGoogle();

      if (result != null) {
        if (mounted) {
          _showSnackbar('Signin success as ${result.user?.email}');
          //Navigator.pushNamed(context, NavigationRoutes.movieList.name);
        }
      }
    } on FirebaseAuthException catch (e) {
      _showSnackbar('Signin fail: ${e.message}');
    } on GoogleSignInException catch (e) {
      _showSnackbar('Signin fail: ${e.description}');
    } catch (e) {
      _showSnackbar('Signin fail: $e');
    }
  }

  _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}