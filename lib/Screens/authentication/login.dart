import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shot_alert/Screens/authentication/forgot_pass.dart';
import 'package:shot_alert/Screens/home.dart';
import 'package:shot_alert/Screens/authentication/phone_num.dart';
import 'package:shot_alert/Screens/authentication/signup.dart';
import 'package:shot_alert/services/logger_service.dart'; // Add this import

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  bool _isPasswordVisible = false;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    Logger.logNavigation("Previous Screen", "Login Screen");
  }

  login() async {
    Logger.logUserAction("Attempting Google sign-in");
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

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      Logger.logAuth("Google sign-in successful", {
        'email': userCredential.user?.email,
        'displayName': userCredential.user?.displayName,
        'newUser': userCredential.additionalUserInfo?.isNewUser,
      });

      Get.offAll(() => Homepage());
    } catch (e) {
      Logger.error(Logger.AUTH, "Google sign-in failed", e);
      setState(() {
        errorMessage = 'Google sign-in failed: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> signin() async {
    if (!mounted) return;

    Logger.logUserAction(
        "Attempting email sign-in", {'email': emailcontroller.text.trim()});

    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    if (emailcontroller.text.trim().isEmpty ||
        !GetUtils.isEmail(emailcontroller.text.trim())) {
      Logger.warning(Logger.USER, "Invalid email format",
          {'email': emailcontroller.text.trim()});

      setState(() {
        errorMessage = "Please enter a valid email address";
        isLoading = false;
      });
      return;
    }
    if (passcontroller.text.isEmpty) {
      Logger.warning(Logger.USER, "Empty password");

      setState(() {
        errorMessage = "Please enter your password";
        isLoading = false;
      });
      return;
    }
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailcontroller.text, password: passcontroller.text);

      Logger.logAuth("Email sign-in successful", {
        'email': userCredential.user?.email,
        'emailVerified': userCredential.user?.emailVerified
      });

      if (userCredential.user != null) {
        Get.offAll(() => Homepage());
      }
    } on FirebaseAuthException catch (e) {
      Logger.error(Logger.AUTH, "Email sign-in failed", e, {'code': e.code});

      setState(() {
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password.';
        } else if (e.code == 'invalid-credential') {
          errorMessage = 'The email or password is incorrect.';
        } else {
          errorMessage = 'Sign in failed: ${e.message}';
        }
      });
    } catch (e) {
      Logger.error(Logger.AUTH, "Unexpected error during sign-in", e);

      setState(() {
        errorMessage = 'An error occurred: $e';
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
      return Center(
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
                              controller: emailcontroller,
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
                              controller: passcontroller,
                              style: TextStyle(color: Colors.white),
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                hintText: '********',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.black,
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(14)),
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
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              errorMessage!,
                              style: TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: signin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 190, 193, 196),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => Get.to(() => const ForgotPass()),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
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
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: login,
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
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'New to ShotAlert? ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Get.to(() => const Signup()),
                                child: const Text(
                                  'Sign Up',
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
