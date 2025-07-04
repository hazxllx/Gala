import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int _currentPage = 0;
  final _formKeyPage1 = GlobalKey<FormState>();
  final _formKeyPage2 = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (_formKeyPage2.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = userCredential.user;
        if (user == null) {
          throw FirebaseAuthException(code: 'unknown', message: 'User creation failed');
        }

        await user.updateDisplayName(
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        );

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': _emailController.text.trim(),
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'username': _usernameController.text.trim(),
          'photoUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        await user.sendEmailVerification();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_completed', false);

        Navigator.pushReplacementNamed(context, '/onboarding');
      } on FirebaseAuthException catch (e) {
        String message = _handleFirebaseError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          final displayName = user.displayName?.split(' ') ?? ['', ''];
          final firstName = displayName[0];
          final lastName = displayName.length > 1 ? displayName[1] : '';

          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email ?? '',
            'firstName': firstName,
            'lastName': lastName,
            'username': user.email?.split('@')[0] ?? 'User',
            'photoUrl': user.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarding_completed', false);
          Navigator.pushReplacementNamed(context, '/onboarding');
        } else {
          final prefs = await SharedPreferences.getInstance();
          final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
          Navigator.pushReplacementNamed(context, onboardingCompleted ? '/home' : '/onboarding');
        }
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'invalid-email':
        return 'Invalid email';
      default:
        return 'Registration failed. Please try again';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPage == 0 ? _buildFirstPage() : _buildSecondPage(),
    );
  }

  Widget _buildFirstPage() {
    return _SignUpFormWrapper(
      backgroundImage: 'assets/login_background.png',
      top: _buildHeader(context),
      children: [
        const Text(
          "Create an account",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        Form(
          key: _formKeyPage1,
          child: Column(
            children: [
              _buildTextField("Email address", _emailController, icon: Icons.email),
              const SizedBox(height: 15),
              _buildTextField("First Name", _firstNameController, icon: Icons.person),
              const SizedBox(height: 15),
              _buildTextField("Last Name", _lastNameController, icon: Icons.person_outline),
              const SizedBox(height: 15),
              _buildTextField("Username", _usernameController, icon: Icons.person_pin),
              const SizedBox(height: 30),
              _buildButton("Next", () {
                if (_formKeyPage1.currentState!.validate()) {
                  setState(() => _currentPage = 1);
                }
              }),
              const SizedBox(height: 20),
              const Text("or", style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 10),
              _isLoading
                  ? const CircularProgressIndicator()
                  : _buildButtonWithIcon(
                      icon: Image.asset('assets/google_icon.png', height: 24),
                      text: "Sign up with Google",
                      onPressed: _signInWithGoogle,
                    ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSecondPage() {
    return _SignUpFormWrapper(
      backgroundImage: 'assets/login_background.png',
      top: _buildHeader(context),
      children: [
        const Text(
          "Set your password",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        Form(
          key: _formKeyPage2,
          child: Column(
            children: [
              _buildPasswordField("Password", _passwordController),
              const SizedBox(height: 15),
              _buildPasswordField("Confirm Password", _confirmPasswordController),
              const SizedBox(height: 50),
              _isLoading ? const CircularProgressIndicator() : _buildButton("SIGN UP", signUp),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo & Back button aligned
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/logoWhite.png', height: 28),
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () {
                    if (_currentPage == 1) {
                      setState(() => _currentPage = 0);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Join the\n",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: "adventure!",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF48A1E0),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Sign up to discover the best cafes, restaurants, and parks in Camarines Sur. Your journey starts here!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon}) {
    return TextFormField(
      controller: controller,
      validator: (value) => value!.isEmpty ? 'Enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    bool isPasswordVisible = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Enter password';
            if (label.contains("Confirm") && value != _passwordController.text) {
              return 'Passwords do not match';
            }
            if (value.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 0, 71, 165),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildButtonWithIcon({required Widget icon, required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}

class _SignUpFormWrapper extends StatelessWidget {
  final String backgroundImage;
  final Widget top;
  final List<Widget> children;

  const _SignUpFormWrapper({
    required this.backgroundImage,
    required this.top,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.black),
        Opacity(
          opacity: 0.6,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        top,
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.all(30),
            height: MediaQuery.of(context).size.height * 0.62,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Column(children: children),
            ),
          ),
        ),
      ],
    );
  }
}
