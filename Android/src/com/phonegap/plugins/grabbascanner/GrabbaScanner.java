package com.phonegap.plugins.grabbascanner;

import java.io.IOException;

import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import android.content.res.AssetFileDescriptor;
import android.media.AudioManager;
import android.media.MediaPlayer;

import com.google.zxing.client.android.R;
import com.grabba.Grabba;
import com.grabba.GrabbaBarcode;
import com.grabba.GrabbaBarcodeListener;
import com.grabba.GrabbaDriverNotInstalledException;

/**
 * This class using the grabba device called from JavaScript.
 */
public class GrabbaScanner extends CordovaPlugin implements GrabbaBarcodeListener{
	private CallbackContext cbContext;
	
    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if (action.equals("scan")) {
            new Thread() {
            	public void run() {
            		GrabbaScanner.this.scan(callbackContext);
            	}
            }.start();
            
            return true;
        }
        return false;
    }

    private void scan(final CallbackContext callbackContext) {
    	try {
    		try {
        		Grabba.open(this.cordova.getActivity().getApplicationContext(),  "FOS");
        	} catch (GrabbaDriverNotInstalledException e) {
        		callbackContext.error(e.getMessage());
        	}
    		
    		Grabba.getInstance().acquireGrabba();
    		this.cbContext = callbackContext;
    		
    		// check connection Grabba.getInstance().isConnected()
    		GrabbaBarcode gb = GrabbaBarcode.getInstance();
    		
    		gb.addEventListener(this);
    		gb.trigger(true);
    	} catch (Exception e) {
    		callbackContext.error(e.getMessage());
    	}
    }
    
    private void playNotification()
    {
    	MediaPlayer mediaPlayer = new MediaPlayer();
        mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
        
        mediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
        	@Override
        	public void onCompletion(MediaPlayer player) {
        		player.seekTo(0);
        	}
        });

        AssetFileDescriptor file = this.cordova.getActivity().getApplicationContext().getResources().openRawResourceFd(R.raw.beep);
        try {
        	mediaPlayer.setDataSource(file.getFileDescriptor(), file.getStartOffset(), file.getLength());
        	file.close();
        	mediaPlayer.setVolume(0.10f, 0.10f);
        	mediaPlayer.prepare();
        } catch (IOException ioe) {
        	mediaPlayer = null;
        }
        
        if (mediaPlayer != null){
        	mediaPlayer.start();
        }
    }

	@Override
	public void barcodeScannedEvent(String arg0, int arg1) {
		//Log.e("tag", "code-"+arg0);
		this.playNotification();
		this.cbContext.success(arg0);
		//Grabba.getInstance().releaseGrabba();
	}

	@Override
	public void barcodeScanningStopped() {
		
	}

	@Override
	public void barcodeTimeoutEvent() {
		this.playNotification();
		this.cbContext.error("GRB-0");
	}

	@Override
	public void barcodeTriggeredEvent() {
		
	}
}