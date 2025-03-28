import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shot_alert/services/logger_service.dart';
import 'login.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final user = FirebaseAuth.instance.currentUser;
  File? audioFile;
  String? audioFileName;
  bool isLoading = false;

  Future<void> signout() async {
    Logger.logUserAction("User initiated sign out");
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      Logger.logAuth("User signed out successfully");
      Get.offAll(() => Login());
    } catch (e) {
      Logger.error(Logger.AUTH, "Sign out failed", e);
    }
  }

  Future<void> pickAudioFile() async {
    Logger.logUserAction("Attempting to pick audio file");
    try {
      setState(() {
        isLoading = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          audioFile = File(result.files.single.path!);
          audioFileName = result.files.single.name;
          isLoading = false;
        });

        Logger.logFile("Audio file selected", {
          "fileName": audioFileName,
          "fileSize": audioFile?.lengthSync().toString(),
          "fileType": result.files.single.extension
        });

        Get.snackbar(
          "Audio Selected",
          "File selected: $audioFileName",
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        Logger.logUserAction("Audio file selection cancelled");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      Logger.error(Logger.FILE, "Audio file selection failed", e);
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        "Error",
        "Failed to select audio file: $e",
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'ShotAlert',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: signout,
          ),
        ],
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top section with app logo
              // ClipOval(
              //   child: Image.asset(
              //     'assets/Logo/logo.jpg',
              //     height: 100,
              //     width: 100,
              //     fit: BoxFit.cover,
              //     errorBuilder: (context, error, stackTrace) {
              //       return Icon(
              //         Icons.security_rounded,
              //         size: 50,
              //         color: Colors.orange,
              //       );
              //     },
              //   ),
              // ),

              SizedBox(height: 20),

              // User greeting
              Text(
                'Hello ${user?.displayName ?? user?.email ?? "User"}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 10),

              Text(
                'Upload an audio file to detect gunshots',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),

              SizedBox(height: 40),

              // Audio selection container
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Icon(
                      audioFile != null ? Icons.audiotrack : Icons.audio_file,
                      size: 50,
                      color: Colors.white,
                    ),

                    SizedBox(height: 16),

                    Text(
                      audioFile != null
                          ? audioFileName!
                          : "No audio file selected",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: audioFile != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20),

                    // Select file button
                    ElevatedButton(
                      onPressed: isLoading ? null : pickAudioFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 190, 193, 196),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            audioFile == null
                                ? Icons.upload_file
                                : Icons.file_upload,
                            color: Colors.black,
                          ),
                          SizedBox(width: 8),
                          Text(
                            audioFile == null
                                ? "Select Audio File"
                                : "Change File",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Process audio button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: audioFile == null
                      ? null
                      : () {
                          // Process the audio file
                          Get.snackbar(
                            "Processing",
                            "Analyzing audio for gunshots...",
                            backgroundColor: Colors.black,
                            colorText: Colors.white,
                          );

                          // Here you would add the actual processing logic
                          // For example, upload to Firebase Storage and analyze
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 190, 193, 196),
                    disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Detect Gunshots",
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
    );
  }
}
