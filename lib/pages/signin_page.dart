import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_note/auth_helper.dart';
import 'package:flutter_note/firestore_user_helper.dart';
import 'package:flutter_note/models/user_model.dart';
import 'package:flutter_note/widgets/animated_mascot.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> with TickerProviderStateMixin {
  final AuthHelper authHelper = AuthHelper();
  final firestoreUserHelper = FirestoreUserHelper();
  TextEditingController emailController = TextEditingController();
  TextEditingController psswdController = TextEditingController();

  bool passwordVisible = true;
  MascotState _mascotState = MascotState.idle;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation for entire page
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Slide animation for form fields
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Scale animation for buttons
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _scaleController.forward();
      }
    });

    // Listen to text field changes
    emailController.addListener(_onEmailChanged);
    psswdController.addListener(_onPasswordChanged);
  }

  void _onEmailChanged() {
    if (emailController.text.isNotEmpty && _mascotState == MascotState.idle) {
      setState(() {
        _mascotState = MascotState.typing;
      });
    } else if (emailController.text.isEmpty && psswdController.text.isEmpty) {
      setState(() {
        _mascotState = MascotState.idle;
      });
    }
  }

  void _onPasswordChanged() {
    if (psswdController.text.isNotEmpty) {
      setState(() {
        _mascotState = MascotState.coveringEyes;
      });
    } else if (emailController.text.isNotEmpty) {
      setState(() {
        _mascotState = MascotState.typing;
      });
    } else {
      setState(() {
        _mascotState = MascotState.idle;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    emailController.removeListener(_onEmailChanged);
    psswdController.removeListener(_onPasswordChanged);
    emailController.dispose();
    psswdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isLoading
                    ? [Colors.orange.shade100, Colors.orange.shade50]
                    : _mascotState == MascotState.success
                    ? [Colors.green.shade100, Colors.green.shade50]
                    : _mascotState == MascotState.failed
                    ? [Colors.red.shade100, Colors.red.shade50]
                    : [Colors.blue.shade50, Colors.white],
              ),
            ),
          ),
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Mascot
                        Hero(
                          tag: 'mascot',
                          child: AnimatedMascot(state: _mascotState),
                        ),
                        const SizedBox(height: 32),
                        SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Sign In',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Animated Email TextField
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 30 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: emailController.text.isNotEmpty
                                        ? [
                                            BoxShadow(
                                              color: Colors.blue.withValues(
                                                alpha: 0.2,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: TextField(
                                    controller: emailController,
                                    enabled: !_isLoading,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'Input Email',
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: emailController.text.isNotEmpty
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Animated Password TextField
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 30 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: psswdController.text.isNotEmpty
                                        ? [
                                            BoxShadow(
                                              color: Colors.purple.withValues(
                                                alpha: 0.2,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: TextField(
                                    controller: psswdController,
                                    obscureText: passwordVisible,
                                    enabled: !_isLoading,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      hintText: 'Input Password',
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: Icon(
                                        Icons.lock_outlined,
                                        color: psswdController.text.isNotEmpty
                                            ? Colors.purple
                                            : Colors.grey,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: Colors.purple,
                                          width: 2,
                                        ),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          passwordVisible
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            passwordVisible = !passwordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Animated Sign In Button
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: !_isLoading
                                        ? [
                                            BoxShadow(
                                              color: Colors.blue.withValues(
                                                alpha: 0.4,
                                              ),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () async {
                                            _signInWithEmail();
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const SpinKitThreeBounce(
                                            color: Colors.white,
                                            size: 24,
                                          )
                                        : const Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text('or'),
                              const SizedBox(height: 16),
                              // Google Sign In Button
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: double.infinity,
                                  height: 56,
                                  child: OutlinedButton.icon(
                                    onPressed: _isLoading
                                        ? null
                                        : () async {
                                            _signInWithGoogle();
                                          },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                    icon: Image.network(
                                      'https://www.google.com/favicon.ico',
                                      height: 24,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.login,
                                              color: Colors.red,
                                            );
                                          },
                                    ),
                                    label: const Text(
                                      'Sign in with Google',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Not have an account?'),
                                  const SizedBox(width: 4),
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            Navigator.pushNamed(
                                              context,
                                              '/signup',
                                            );
                                          },
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _signInWithEmail() async {
    // Show loading state
    setState(() {
      _isLoading = true;
      _mascotState = MascotState.loading;
    });

    try {
      final result = await authHelper.signInWithEmailAndPassword(
        emailController.text,
        psswdController.text,
      );

      // Create user document in Firestore if it doesn't exist
      if (result.user != null) {
        final userModel = UserModel(
          userId: result.user!.uid,
          userName:
              result.user!.displayName ?? emailController.text.split('@')[0],
          userEmail: result.user!.email ?? emailController.text,
        );
        await firestoreUserHelper.addUser(userModel);
      }

      // Show success animation
      setState(() {
        _mascotState = MascotState.success;
        _isLoading = false;
      });

      // Wait a bit to show success animation
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        _showSnackbar('Signin success as ${result.user?.email}');
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      // Show failed animation
      setState(() {
        _mascotState = MascotState.failed;
        _isLoading = false;
      });

      _showSnackbar('Signin fail: ${e.message}');

      // Reset to idle after showing error
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {
        setState(() {
          _mascotState = MascotState.idle;
        });
      }
    } catch (e) {
      // Show failed animation
      setState(() {
        _mascotState = MascotState.failed;
        _isLoading = false;
      });

      _showSnackbar('Signin fail: $e');

      // Reset to idle after showing error
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {
        setState(() {
          _mascotState = MascotState.idle;
        });
      }
    }

    emailController.clear();
    psswdController.clear();
  }

  Future _signInWithGoogle() async {
    // Show loading state
    setState(() {
      _isLoading = true;
      _mascotState = MascotState.loading;
    });

    try {
      final result = await authHelper.signInWithGoogle();

      if (result != null && result.user != null) {
        // Create user document in Firestore if new user
        final userModel = UserModel(
          userId: result.user!.uid,
          userName:
              result.user!.displayName ??
              result.user!.email?.split('@')[0] ??
              'User',
          userEmail: result.user!.email ?? '',
        );
        await firestoreUserHelper.addUser(userModel);

        // Show success animation
        setState(() {
          _mascotState = MascotState.success;
          _isLoading = false;
        });

        // Wait a bit to show success animation
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          _showSnackbar('Signin success as ${result.user?.email}');
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() {
          _isLoading = false;
          _mascotState = MascotState.idle;
        });
      }
    } on FirebaseAuthException catch (e) {
      // Show failed animation
      setState(() {
        _mascotState = MascotState.failed;
        _isLoading = false;
      });

      _showSnackbar('Signin fail: ${e.message}');

      // Reset to idle after showing error
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {
        setState(() {
          _mascotState = MascotState.idle;
        });
      }
    } on GoogleSignInException catch (e) {
      // Show failed animation
      setState(() {
        _mascotState = MascotState.failed;
        _isLoading = false;
      });

      _showSnackbar('Signin fail: ${e.description}');

      // Reset to idle after showing error
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {
        setState(() {
          _mascotState = MascotState.idle;
        });
      }
    } catch (e) {
      // Show failed animation
      setState(() {
        _mascotState = MascotState.failed;
        _isLoading = false;
      });

      _showSnackbar('Signin fail: $e');

      // Reset to idle after showing error
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {
        setState(() {
          _mascotState = MascotState.idle;
        });
      }
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
