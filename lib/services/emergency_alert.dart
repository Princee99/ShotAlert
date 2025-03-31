import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:torch_light/torch_light.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyAlert {
  final AudioPlayer _player = AudioPlayer();

  /// 🔊 Play Loud Emergency Siren
  Future<void> playSiren() async {
    try {
      await _player.setSource(AssetSource('assets/sound/alert.wav'));
      await _player.resume();
    } catch (e) {
      print("Error playing siren: $e");
    }
  }

  /// 📩 Send Emergency SMS
  Future<void> sendEmergencySMS(String phoneNumber) async {
    try {
      if (await Permission.sms.request().isGranted) {
        await sendSMS(
          message: "⚠️ GUNSHOT DETECTED! CALL ME ASAP!",
          recipients: [phoneNumber],
        );
      } else {
        print("SMS permission denied.");
      }
    } catch (e) {
      print("Error sending SMS: $e");
    }
  }

  /// 🔦 Flash Torchlight for Alert
  Future<void> flashTorch() async {
    try {
      for (int i = 0; i < 5; i++) {
        await TorchLight.enableTorch();
        await Future.delayed(Duration(milliseconds: 500));
        await TorchLight.disableTorch();
        await Future.delayed(Duration(milliseconds: 500));
      }
    } catch (e) {
      print("Torchlight error: $e");
    }
  }

  /// 🚨 Trigger Full Emergency Alert 🚨
  Future<void> triggerEmergency(String phoneNumber) async {
    playSiren();
    sendEmergencySMS(phoneNumber);
    flashTorch();
  }
}
