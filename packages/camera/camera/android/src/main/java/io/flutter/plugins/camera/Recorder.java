package io.flutter.plugins.camera;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaCodecList;
import android.media.MediaFormat;
import android.media.MediaMuxer;
import android.media.MediaRecorder;
import android.os.Build;
import android.util.Log;
import android.view.Surface;

import java.io.IOException;
import java.nio.ByteBuffer;

import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugins.camera.features.CameraFeatures;
import io.flutter.plugins.camera.features.resolution.ResolutionFeature;
import io.flutter.plugins.camera.features.sensororientation.SensorOrientationFeature;

public class Recorder {
    private static final String TAG = "Recorder";

    // video
    private final MediaCodec videoEncoder;
    private final Surface videoEncoderSurface;
    private final int recordingWidth;
    private final int recordingHeight;
    private int rotation = 0;
    private final VideoRenderer videoRenderer;
    static final int FRAME_RATE = 24;
    static final int I_FRAME_INTERVAL = 15;
    static final String VIDEO_MIME = "video/avc";
    private final Thread videoThread;
    private int videoTrackIndex = -1;
    private final Object videoLock = new Object();
    private boolean stoppedVideo = false;
    private long videoStartTimeUs = -1;
    private long videoEndTimeUs = -1;

    // audio
    private final MediaCodec audioEncoder;
    private boolean audioEnabled; // TODO:
    private final AudioRecord audioRecord;
    static final String AUDIO_MIME = "audio/mp4a-latm";
    static final int MAX_INPUT_SIZE = 16384;
    private final Thread audioThread;
    private final Object audioLock = new Object();
    private boolean stoppedAudio = false;

    // audio and video
    static final int BIT_RATE = 32000;
    boolean stopped = false;


    // muxer
    private final String outputFilePath;
    private final MediaMuxer muxer;
    private final Object muxerLock = new Object();

    public Recorder(String outputFilePath, CameraFeatures cameraFeatures, boolean audioEnabled) throws IOException {

        // setup members
        this.audioEnabled = audioEnabled;
        this.outputFilePath = outputFilePath;
        final ResolutionFeature resolutionFeature = cameraFeatures.getResolution();
        recordingWidth = resolutionFeature.getCaptureSize().getWidth();
        recordingHeight = resolutionFeature.getCaptureSize().getHeight();

        // get initial rotation
        final PlatformChannel.DeviceOrientation lockedOrientation =
                ((SensorOrientationFeature) cameraFeatures.getSensorOrientation())
                        .getLockedCaptureOrientation();
        rotation = lockedOrientation== null
                ? cameraFeatures.getSensorOrientation().getDeviceOrientationManager().getVideoOrientation()
                : cameraFeatures.getSensorOrientation().getDeviceOrientationManager().getVideoOrientation(lockedOrientation);

        // setup muxer
        muxer = new MediaMuxer(outputFilePath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4);
        muxer.setOrientationHint(rotation);

        // setup video encoder
        MediaFormat videoEncoderFormat = MediaFormat.createVideoFormat(VIDEO_MIME, recordingWidth, recordingHeight);
        videoEncoderFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface);
        videoEncoderFormat.setInteger(MediaFormat.KEY_BIT_RATE, BIT_RATE);
        videoEncoderFormat.setInteger(MediaFormat.KEY_FRAME_RATE, FRAME_RATE);
        videoEncoderFormat.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, I_FRAME_INTERVAL);
        videoEncoderFormat.setString(MediaFormat.KEY_MIME, VIDEO_MIME);
        String encoderName = new MediaCodecList(MediaCodecList.REGULAR_CODECS).findEncoderForFormat(videoEncoderFormat);
        videoEncoder = MediaCodec.createByCodecName(encoderName);
        videoEncoder.configure(videoEncoderFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
        videoEncoderSurface = videoEncoder.createInputSurface();

        // setup audio recorder
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            audioRecord = new AudioRecord.Builder()
                    .setAudioSource(MediaRecorder.AudioSource.MIC)
                    .setAudioFormat(new AudioFormat.Builder()
                            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                            .setSampleRate(44100)
                            .setChannelMask(AudioFormat.CHANNEL_IN_MONO)
                            .build())
                    .build();
        }else{
            // audioRecord = new AudioRecord(); TODO:
            audioRecord = null;
        }

        // setup audio encoder
        MediaFormat audioFormat =  MediaFormat.createAudioFormat(AUDIO_MIME,audioRecord.getSampleRate(),audioRecord.getChannelCount());
        audioFormat.setString(MediaFormat.KEY_MIME, AUDIO_MIME);
        audioFormat.setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC);
        audioFormat.setInteger(MediaFormat.KEY_BIT_RATE, BIT_RATE);
        audioFormat.setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, MAX_INPUT_SIZE);
        encoderName = new MediaCodecList(MediaCodecList.REGULAR_CODECS).findEncoderForFormat(audioFormat);
        audioEncoder = MediaCodec.createByCodecName(encoderName);
        audioEncoder.configure(audioFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);

        // setup video renderer
        videoRenderer = new VideoRenderer(videoEncoderSurface, recordingWidth,recordingHeight);

        videoThread = new Thread(){
            public void run(){
                videoEncoderLoop();
            }
        };


        audioThread = new Thread(){
            public void run(){

            }
        };
    }

    public void start(){
        if(audioThread.isAlive() || videoThread.isAlive()){
            return; // TODO: throw error already videoing or not complete videoing
        }

        audioEnabled = false;
        stoppedAudio = true; // TODO: audio

       // audioRecord.startRecording();
        videoEncoder.start();
       // audioEncoder.start();


        videoThread.start();

    }

    public void stop(){
        videoEncoder.signalEndOfInputStream();
        /* TODO: don't return until audio and video complete. wait here
        audioThread.interrupt();
        videoThread.interrupt();

         */
    }


    /** The input surface for this recorder to record video from */
    public Surface getInputSurface(){
        try {
            return videoRenderer.getInputSurface();
        } catch (InterruptedException e) {
            e.printStackTrace();
            throw new RuntimeException("unable to get input surface");
        }
    }


    /** initializes encoder with muxer and continuously encodes */
    private void videoEncoderLoop(){

        initializeVideoEncoder();

        waitAudioEncoderInitialized();

        muxer.start();

        while(!stopped) {
            encodeVideo();
        }
    }

    private void encodeVideo(){
            if(stopped || stoppedVideo){
                return;
            }
            // write encoded video
            MediaCodec.BufferInfo videoInfo = new MediaCodec.BufferInfo();
            int videoIndex = videoEncoder.dequeueOutputBuffer(videoInfo,-1);

            // first frame - note start time
            if(videoInfo.presentationTimeUs != 0 && videoStartTimeUs == -1){
                synchronized (videoLock) {
                    videoStartTimeUs = videoInfo.presentationTimeUs;
                    Log.d(TAG, "Started recording video at " + usToSeconds(videoStartTimeUs) + " seconds");
                    videoLock.notifyAll();
                }
            }

            try{

                // assert valid buffer
                if(videoIndex < 0){
                    throw new RuntimeException("Video output buffer not available");
                }

                // get buffer to write
                ByteBuffer videoBuffer = videoEncoder.getOutputBuffer(videoIndex);

                // reached end of stream
                if(((videoInfo.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM)) != 0){
                    Log.d(TAG, "Stopped recording video at " + usToSeconds(videoEndTimeUs) + " seconds");
                    stoppedVideo = true;
                    videoRenderer.close();
                    videoEncoder.stop();
                    if(stoppedAudio){
                        stopInternal();
                    }
                }

                // write to muxer
                muxer.writeSampleData(videoTrackIndex, videoBuffer, videoInfo);
                videoEndTimeUs = videoInfo.presentationTimeUs;

            }catch(Exception e){
                Log.e(TAG, "Encode video error ",e);
            }

            // release buffer for reuse
            if(!stoppedVideo) {
                videoEncoder.releaseOutputBuffer(videoIndex, false);
            }
    }

    private void initializeVideoEncoder(){
        // setup video
        while(videoTrackIndex < 0) {
            MediaCodec.BufferInfo videoInfo = new MediaCodec.BufferInfo();
            int videoIndex = videoEncoder.dequeueOutputBuffer(videoInfo, -1);
            if (videoIndex >= 0) {
                videoEncoder.releaseOutputBuffer(videoIndex, false);
            }else if(videoIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED){
                synchronized(videoLock) {
                    Log.d(TAG, "Initialize video format");
                    videoTrackIndex = muxer.addTrack(videoEncoder.getOutputFormat());
                    videoLock.notifyAll();
                }
            }
        }
    }

    private void waitAudioEncoderInitialized() {
 // TODO:
    }

    private void waitVideoEncoderInitialized() throws InterruptedException {
        synchronized(videoLock){
            while(videoTrackIndex < 0){
                videoLock.wait(500);
            }
        }
    }

    private void stopInternal(){
        // TODO: log elapsed times
        stopped = true;
        muxer.stop();
    }

    private float usToSeconds(long us){
        return ((float) us / 10000000);
    }


}
