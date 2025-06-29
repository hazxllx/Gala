import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_project/screens/home/HomePage.dart';

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

        await userCredential.user?.updateDisplayName(
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        );

        await userCredential.user?.sendEmailVerification();

        // Navigate to HomePage with username
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(username: _usernameController.text.trim()),
          ),
        );

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

  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password': return 'Password is too weak';
      case 'email-already-in-use': return 'Email already in use';
      case 'invalid-email': return 'Invalid email';
      default: return 'Registration failed. Please try again';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (_currentPage == 0) return _buildFirstPage();
          if (_currentPage == 1) return _buildSecondPage();
          return Container();
        },
      ),
    );
  }

  Widget _buildFirstPage() {
    return Stack(
      children: [
        // Background
        Container(color: Colors.black),
        Opacity(
          opacity: 0.6,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // Header
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 100),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Join the\n",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: "adventure!",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color.fromARGB(255, 72, 149, 220),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: 350,
                child: Text(
                  "Sign up to discover the best cafes, restaurants, and parks in Camarines Sur. Your journey starts here!",
                  style: TextStyle(
                    color: Color.fromARGB(221, 255, 255, 255),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Form
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
              child: Form(
                key: _formKeyPage1,
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    const Center(
                      child: Text(
                        "Create an account",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField("Email address", _emailController, icon: Icons.email),
                    const SizedBox(height: 15),
                    _buildTextField("First Name", _firstNameController, icon: Icons.person),
                    const SizedBox(height: 15),
                    _buildTextField("Last Name", _lastNameController, icon: Icons.person_outline),
                    const SizedBox(height: 15),
                    _buildTextField("Username", _usernameController, icon: Icons.person_pin),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKeyPage1.currentState!.validate()) {
                            setState(() => _currentPage = 1);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color.fromARGB(255, 0, 71, 165),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Next",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondPage() {
    return Stack(
      children: [
        // Background
        Container(color: Colors.black),
        Opacity(
          opacity: 0.6,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // Header
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 100),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Join the\n",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: "adventure!",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color.fromARGB(255, 72, 149, 220),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: 350,
                child: Text(
                  "Sign up to discover the best cafes, restaurants, and parks in Camarines Sur. Your journey starts here!",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
        ),

        // Form
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
              child: Form(
                key: _formKeyPage2,
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    const Center(
                      child: Text(
                        "Create an account",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildPasswordField("Set password", _passwordController),
                    const SizedBox(height: 15),
                    _buildPasswordField("Confirm password", _confirmPasswordController),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 0, 71, 165),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "SIGN UP",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
            if (value.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(Icons.lock),
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
}