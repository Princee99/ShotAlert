import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shot_alert/services/logger_service.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key});

  @override
  State<ForgotPass> createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  TextEditingController emailcontroller = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    Logger.logNavigation("Previous Screen", "Forgot Password Screen");
  }

  Future<void> reset() async {
    Logger.logUserAction(
        "Attempting password reset", {"email": emailcontroller.text.trim()});

    if (emailcontroller.text.trim().isEmpty ||
        !GetUtils.isEmail(emailcontroller.text.trim())) {
      Logger.warning(Logger.USER, "Invalid email format",
          {"email": emailcontroller.text.trim()});

      setState(() {
        errorMessage = "Please enter a valid email address";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailcontroller.text.trim());

      Logger.logAuth(
          "Password reset email sent", {"email": emailcontroller.text.trim()});

      Get.snackbar(
        "Password Reset",
        "A password reset link has been sent to your email",
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      // Optional: navigate back after successful reset
      Future.delayed(Duration(seconds: 2), () {
        Logger.logNavigation("Forgot Password Screen", "Login Screen",
            {"reason": "Password reset email sent"});
        Get.back();
      });
    } on FirebaseAuthException catch (e) {
      Logger.error(Logger.AUTH, "Password reset failed", e, {"code": e.code});

      setState(() {
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else {
          errorMessage = 'Error: ${e.message}';
        }
      });
    } catch (e) {
      Logger.error(Logger.AUTH, "Unexpected error during password reset", e);

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Instructions
                      Text(
                        "Forgot your password?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 12),

                      Text(
                        "Enter your email address and we'll send you a link to reset your password",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 40),

                      // Email field with label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),

                      SizedBox(height: 8),

                      TextFormField(
                        controller: emailcontroller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Email@email.com',
                          hintStyle: TextStyle(color: Colors.grey),
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
                          suffixIcon: Icon(
                            Icons.mail_outline,
                            color: Colors.white,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),

                      // Error message
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      SizedBox(height: 24),

                      // Reset button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : reset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 190, 193, 196),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            disabledBackgroundColor:
                                Colors.grey.withOpacity(0.3),
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
                              : Text(
                                  "Send Reset Link",
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
          ],
        ),
      ),
    );
  }
}
