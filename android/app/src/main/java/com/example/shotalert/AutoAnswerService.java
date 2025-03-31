package com.example.shotalert;

import android.accessibilityservice.AccessibilityService;
import android.view.accessibility.AccessibilityEvent;
import android.content.Context;
import android.media.MediaPlayer;
import android.telecom.TelecomManager;
import android.os.Handler;
import android.os.Looper;

public class AutoAnswerService extends AccessibilityService {
    private MediaPlayer mediaPlayer;

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        if (event.getEventType() == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            String className = event.getClassName().toString();

            // Detect incoming call screen
            if (className.contains("com.android.incallui")) {
                answerCall();
            }
        }
    }

    private void answerCall() {
        TelecomManager telecomManager = (TelecomManager) getSystemService(Context.TELECOM_SERVICE);
        if (telecomManager != null) {
            try {
                telecomManager.acceptRingingCall();
                playSiren();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private void playSiren() {
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            if (mediaPlayer == null) {
                mediaPlayer = MediaPlayer.create(this, R.raw.siren);
                mediaPlayer.setLooping(true);
                mediaPlayer.start();
            }
        }, 1000);
    }

    @Override
    public void onInterrupt() {
        if (mediaPlayer != null) {
            mediaPlayer.stop();
            mediaPlayer.release();
            mediaPlayer = null;
        }
    }
}
