import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shot_alert/Screens/authentication/login.dart';
import 'package:shot_alert/Screens/authentication/phone_num.dart';
import 'package:shot_alert/wrapper.dart';
import 'package:shot_alert/services/logger_service.dart'; // Add this import

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool _isPasswordVisible = false;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    Logger.logNavigation("Previous Screen", "Signup Screen");
  }

  Future<void> signup() async {
    Logger.logUserAction("Attempting to create new account",
        {"email": emailController.text.trim()});

    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Logger.warning(Logger.USER, "Invalid email format",
          {"email": emailController.text.trim()});

      setState(() {
        errorMessage = "Please enter a valid email address";
        isLoading = false;
      });
      return;
    }

    if (passController.text.isEmpty) {
      Logger.warning(Logger.USER, "Empty password");

      setState(() {
        errorMessage = "Please enter a password";
        isLoading = false;
      });
      return;
    }

    if (passController.text.length < 6) {
      Logger.warning(Logger.USER, "Password too short",
          {"length": passController.text.length.toString()});

      setState(() {
        errorMessage = "Password must be at least 6 characters long";
        isLoading = false;
      });
      return;
    }

    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passController.text);

      Logger.logAuth("User registration successful",
          {"email": userCred.user?.email, "uid": userCred.user?.uid});

      Get.offAll(Wrapper());
    } on FirebaseAuthException catch (e) {
      Logger.error(Logger.AUTH, "Registration failed", e, {"code": e.code});

      setState(() {
        errorMessage = e.code == 'weak-password'
            ? 'The password provided is too weak.'
            : e.code == 'email-already-in-use'
                ? 'The account already exists for that email.'
                : "An error occurred: $e";
      });
    } catch (e) {
      Logger.error(Logger.AUTH, "Unexpected registration error", e);

      setState(() {
        errorMessage = "An error occurred: $e";
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loginWithGoogle() async {
    Logger.logUserAction("Attempting Google sign-in from signup screen");

    setState(() {
      isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Logger.logAuth("Google sign-in cancelled by user");
        setState(() {
          isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      Logger.logAuth("Google sign-in successful", {
        "email": userCred.user?.email,
        "name": userCred.user?.displayName,
        "newUser": userCred.additionalUserInfo?.isNewUser.toString()
      });

      Get.offAll(Wrapper());
    } catch (e) {
      Logger.error(Logger.AUTH, "Google sign-in failed", e);

      setState(() {
        errorMessage = "Google sign-in failed: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Logo - using ClipOval like in login page
                        ClipOval(
                          child: Image.asset(
                            'assets/Logo/logo.jpg',
                            height: 175,
                            width: 175,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.security_rounded,
                                size: 50,
                                color: Colors.orange,
                              );
                            },
                          ),
                        ),

                        // Email field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: emailController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Email@email.com',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: Colors.black,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                suffixIcon: const Icon(
                                  Icons.mail_outline,
                                  color: Colors.white,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ],
                        ),

                        // Password field
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: passController,
                              style: TextStyle(color: Colors.white),
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                hintText: '********',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.black,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Error message
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              errorMessage!,
                              style: TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Sign Up button
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 190, 193, 196),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        // OR divider
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey,
                                thickness: 0.5,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey,
                                thickness: 0.5,
                              ),
                            ),
                          ],
                        ),

                        // Google sign-in
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: loginWithGoogle,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 15),
                                child: Image.asset(
                                  'assets/Logo/google.webp',
                                  height: 35,
                                  width: 35,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => const Loginwithphone());
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 15),
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 100),

                        // Already have an account
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Get.to(() => const Login()),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
