/* Authored by: Maria Curly Ann Lumibao
Company: Eleutheria Ventures
Project: Gala
Feature: [GAL-002] Registration Screen
Description: This page is dedicated new users who have no account yet,
they can create one, or just sign-up using their google accounts.
 */

import 'package:flutter/material.dart';
import 'package:my_project/screens/onboarding/OnBoardingPage.dart';

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _selectedName = "User Not Found";
  String _selectedEmail = "usernotfound@gmail.com";
  String _selectedImage = "assets/user1.png";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (_currentPage == 0) {
            return buildFirstPage();
          } else if (_currentPage == 1) {
            return buildSecondPage();
          } else if (_currentPage == 2) {
            return buildChooseAccountPage();
          } else {
            return buildConfirmAccountPage();
          }
        },
      ),
    );
  }

  Widget buildFirstPage() {
    return Stack(
      children: [
        // Black background with semi-transparent image
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

        // Header text on top of the image
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
                        fontFamily: 'Inter', // if you want Inter font
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
                width: 350, // adjust as needed
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

        // Bottom white signup card container
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    buildTextField(
                      "Email address",
                      _emailController,
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      "First Name",
                      _firstNameController,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      "Last Name",
                      _lastNameController,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      "Username",
                      _usernameController,
                      icon: Icons.person_pin,
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKeyPage1.currentState!.validate()) {
                            setState(() {
                              _currentPage = 1;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color.fromARGB(
                            255,
                            0,
                            71,
                            165,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Next",
                          style: TextStyle(
                            color: Colors.white, // <-- Make text white
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

  Widget buildSecondPage() {
    return Stack(
      children: [
        // Black background with semi-transparent image
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

        // Header text on top of the image
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

        // Bottom white signup card container
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    buildPasswordField("Set password", _passwordController),
                    const SizedBox(height: 15),
                    buildPasswordField(
                      "Confirm password",
                      _confirmPasswordController,
                      matchPassword: _passwordController,
                    ),
                    const SizedBox(height: 50),
                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKeyPage2.currentState!.validate()) {
                            signUp();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            0,
                            71,
                            165,
                          ),
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

                    const SizedBox(height: 10),

                    // Or sign up with
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "or sign up with",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Google Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentPage =
                                2; // or call your Google sign-in method here
                          });
                        },
                        icon: Image.asset(
                          'assets/google_icon.png',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text(
                          "Google",
                          style: TextStyle(
                            color: Color.fromARGB(255, 243, 0, 0),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Already have an account? Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Color.fromARGB(255, 11, 113, 197),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

  Widget buildChooseAccountPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(showBack: true),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Choose an account",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    "to continue to Gala",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: 30),
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/user1.png'),
                  ),
                  title: Text("User Not Found"),
                  subtitle: Text("usernotfound@gmail.com"),
                  onTap: () {
                    setState(() {
                      _selectedName = "User Not Found";
                      _selectedEmail = "usernotfound@gmail.com";
                      _selectedImage = "assets/user1.png";
                      _currentPage = 3;
                    });
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/user2.png'),
                  ),
                  title: Text("Cat Knip"),
                  subtitle: Text("catnipols09@gmail.com"),
                  onTap: () {
                    setState(() {
                      _selectedName = "Cat Knip";
                      _selectedEmail = "catnipols09@gmail.com";
                      _selectedImage = "assets/user2.png";
                      _currentPage = 3;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person_add),
                  title: Text("Use another account"),
                  onTap: () {
                    // Here you can trigger a real Google Sign-In flow if needed
                    setState(() {
                      _currentPage = 3;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildConfirmAccountPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(showBack: true),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Sign up to Gala",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(_selectedImage),
                  ),
                  title: Text(_selectedName),
                  subtitle: Text(_selectedEmail),
                ),
                SizedBox(height: 20),
                Text(
                  "By continuing, Google will share your name, email address, "
                  "language preference, and profile picture with Gala. See Gala's Privacy Policy and Terms of Service.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                      ),
                      onPressed: () {
                        setState(() {
                          _currentPage = 2;
                        });
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        googleSignIn();
                      },
                      child: Text('Continue'),
                    ),
                  ],
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHeader({bool showBack = false}) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.70,
          color: Colors.black, // Black background added here
        ),
        Opacity(
          opacity: 0.4, // Adjust opacity here
          child: Container(
            height: MediaQuery.of(context).size.height * 0.70,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.70,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showBack)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _currentPage = 0;
                    });
                  },
                ),
              const SizedBox(height: 40), // spacing below back button or top
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Join the\n",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        fontFamily: 'Inter',
                      ),
                    ),
                    TextSpan(
                      text: "adventure!",
                      style: TextStyle(
                        color: Color.fromARGB(255, 72, 149, 220),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 330,
                child: const Text(
                  "Sign up to discover the best cafes, restaurants, and parks in Camarines Sur. Your journey starts here!",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) => value!.isEmpty ? 'Enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 119, 119, 119), // your desired label color
          fontSize: 15, // semi-bold font weight
        ),
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget buildPasswordField(
    String label,
    TextEditingController controller, {
    TextEditingController? matchPassword,
  }) {
    bool isPasswordVisible = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Enter password';
            if (matchPassword != null && value != matchPassword.text)
              return 'Passwords do not match';
            if (value.length < 6)
              return 'Password must be at least 6 characters';
            return null;
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              color: Color.fromARGB(
                255,
                119,
                119,
                119,
              ), // your desired label color
              fontSize: 15, // semi-bold font weight
            ),
            prefixIcon: Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed:
                  () => setState(() => isPasswordVisible = !isPasswordVisible),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  void signUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => OnboardingPage(
              onboardingCompleted: (BuildContext ctx) async {
                // Save onboarding completed flag or other logic
                Navigator.pushReplacementNamed(ctx, '/home');
              },
            ),
      ),
    );
  }

  void googleSignIn() {
    // Add Google Sign-In logic here (Firebase Auth or other)
    print('Google Sign-In clicked');
  }
}
