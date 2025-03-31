import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shot_alert/Screens/home.dart';
import 'package:shot_alert/Screens/authentication/login.dart';
import 'package:shot_alert/Screens/authentication/verifyemail.dart';
import 'package:shot_alert/services/logger_service.dart'; // Add this import

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    Logger.debug(Logger.SYSTEM, "Building Wrapper");
    Logger.debug(Logger.AUTH, "Current user",
        {"user": FirebaseAuth.instance.currentUser?.email});

    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            Logger.debug(Logger.AUTH, "Auth state changed", {
              "connectionState": snapshot.connectionState.toString(),
              "hasData": snapshot.hasData.toString()
            });

            if (snapshot.hasData && snapshot.data != null) {
              User user = snapshot.data!;
              Logger.info(Logger.AUTH, "User authenticated", {
                "uid": user.uid,
                "email": user.email,
                "displayName": user.displayName
              });

              bool isGoogleUser = user.providerData
                  .any((element) => element.providerId == 'google.com');

              Logger.debug(Logger.AUTH, "User provider details", {
                "isGoogleUser": isGoogleUser,
                "emailVerified": user.emailVerified
              });

              if (isGoogleUser || user.emailVerified) {
                Logger.logNavigation("Wrapper", "Homepage");
                return Homepage();
              } else {
                Logger.logNavigation("Wrapper", "Verify Email");
                return Verify();
              }
            } else {
              Logger.logNavigation("Wrapper", "Login");
              return const Login();
            }
          }),
    );
  }
}
