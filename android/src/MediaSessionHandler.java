// testimised adb-ga: adb shell dumpsys media_session
package org.tarmoj.bourdon;

import android.content.Intent;
import android.content.IntentFilter;
import android.content.Context;
import android.media.session.MediaSession;
import android.media.session.MediaSession.Callback;
import android.media.session.PlaybackState;
import android.view.KeyEvent;
import android.util.Log;
import android.os.Looper;
import android.os.Handler;

public class MediaSessionHandler {
    private static final String TAG = "MediaSessionHandler";
    private static MediaSessionHandler instance = null;
    private MediaSession mediaSession;

    static {
            System.loadLibrary("bourdon-app_arm64-v8a"); // Load your Qt native library NB! hardcoded of arm64, but this is theonly option with Csound anyway
    }

    private static native void nativeMediaButtonEvent(int action);


    // Initialize MediaSessionHandler
    public static void initialize(Context context) {
        Log.d(TAG, "Initialize MediaSessionHandler in Java code");

        // Ensure MediaSession is initialized on the main UI thread
        if (instance == null) {
            instance = new MediaSessionHandler(context);
            //instance.registerMediaButtonReceiver(context);
        }
    }

    private MediaSessionHandler(Context context) {
        // Check that we are running on the main thread
        if (Looper.myLooper() != Looper.getMainLooper()) {
            Log.d(TAG, "Not on the main thread, posting to the main thread");
            new Handler(Looper.getMainLooper()).post(() -> createMediaSession(context));
        } else {
            createMediaSession(context);
        }
    }

    private void createMediaSession(Context context) {
        Log.d(TAG, "Creating MediaSession...");

        // Create and configure the MediaSession
        mediaSession = new MediaSession(context, "BourdonMediaSession");
        mediaSession.setCallback(new MediaSession.Callback() {
                    // Handle media button events
                    @Override
                    public boolean onMediaButtonEvent(Intent mediaButtonIntent) {
                        //Log.d(TAG, "Media button event received: " + mediaButtonIntent);

                        KeyEvent event = mediaButtonIntent.getParcelableExtra(Intent.EXTRA_KEY_EVENT);
                        if (event != null) {
                            //Log.d(TAG, "Key event: " + event.toString());

                            if (event.getAction() == KeyEvent.ACTION_DOWN) {
                                switch (event.getKeyCode()) {
                                    case KeyEvent.KEYCODE_MEDIA_PLAY:
                                        Log.d(TAG, "Play button pressed");
                                        nativeMediaButtonEvent(1);
                                        break;
                                    case KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE:
                                        Log.d(TAG, "Play_Pause pressed");
                                        nativeMediaButtonEvent(2);
                                        break;
                                    case KeyEvent.KEYCODE_MEDIA_PAUSE:  // send STOP with pause and stop
                                        Log.d(TAG, "Pause button pressed");
                                        nativeMediaButtonEvent(3);
                                        break;
                                    case KeyEvent.KEYCODE_MEDIA_STOP:
                                        Log.
                                        d(TAG, "Stop button pressed");
                                        nativeMediaButtonEvent(3); // make both pause and stop act for stop
                                        break;
                                    case KeyEvent.KEYCODE_MEDIA_NEXT:
                                        Log.d(TAG, "Next track button pressed");
                                        nativeMediaButtonEvent(4);
                                        break;
                                    case KeyEvent.KEYCODE_MEDIA_PREVIOUS:
                                        Log.d(TAG, "Previous track button pressed");
                                        nativeMediaButtonEvent(5);
                                        break;

                                    default:
                                        Log.d(TAG, "Unhandled key event: " + event.getKeyCode());
                                }
                            }
                        }
                        return super.onMediaButtonEvent(mediaButtonIntent);
                    }

            // Override media button actions, etc.
            @Override
            public void onPlay() {
                Log.d(TAG, "Media play action received.");
            }

            @Override
            public void onPause() {
                Log.d(TAG, "Media pause action received.");
            }
        });

        // try:
        mediaSession.setMediaButtonReceiver(null);

        // Activate the MediaSession
        mediaSession.setActive(true);
    }

}

