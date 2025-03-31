import 'dart:async';
import 'package:shot_alert/services/logger_service.dart';
import 'package:shot_alert/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Verify extends StatefulWidget {
  const Verify({Key? key}) : super(key: key);

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  Timer? timer;
  bool isLoading = false;
  String? errorMessage;
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Send verification email when screen loads
    Logger.logSystem("Email verification screen loaded");
    sendVerifyLink();

    // Start a timer to check every 3 seconds if email is verified
    timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        User? user = auth.currentUser;
        if (user != null) {
          await user.reload();
          user = auth.currentUser; // Get the refreshed user
          if (user != null && user.emailVerified) {
            Logger.logAuth("Email successfully verified");
            timer.cancel();
            Get.offAll(() => Wrapper());
          }
        }
      } catch (e) {
        Logger.error(Logger.AUTH, "Error checking verification status", e);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> sendVerifyLink() async {
    Logger.logUserAction("Sending verification email");
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      User? user = auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        Logger.logAuth("Verification email sent", {'email': user.email});
        Get.snackbar(
          "Email Verification",
          "A verification link has been sent to ${user.email}",
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        Logger.warning(Logger.AUTH, "No user signed in for verification");
        setState(() {
          errorMessage = "No user is signed in";
        });
      }
    } catch (e) {
      Logger.error(Logger.AUTH, "Failed to send verification email", e);
      setState(() {
        errorMessage = "Failed to send verification email: ${e.toString()}";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkVerification() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      User? user = auth.currentUser;
      if (user != null) {
        await user.reload();
        // Get the refreshed user
        user = auth.currentUser;

        if (user != null && user.emailVerified) {
          Get.offAll(() => Wrapper());
        } else {
          Get.snackbar(
            "Verification Pending",
            "Your email is not verified yet. Please check your inbox and spam folder.",
            backgroundColor: Colors.black,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      } else {
        setState(() {
          errorMessage = "No user is signed in";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to check verification: ${e.toString()}";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(height: 40),
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'We\'ve sent a verification link to your email. Please check your inbox and click the link to activate your account.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 40),

                // Resend Verification Email button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : sendVerifyLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Resend Verification Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // I have verified my email button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : checkVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'I have verified my email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
