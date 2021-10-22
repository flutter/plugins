package io.flutter.plugins.camera;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.CamcorderProfile;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaCodecList;
import android.media.MediaFormat;
import android.media.MediaMuxer;
import android.media.MediaRecorder;
import android.os.Build;
import android.util.Log;
import android.view.Surface;

import androidx.annotation.RequiresApi;

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
    private int rotation = 0;
    private VideoRenderer videoRenderer;
    static final int I_FRAME_INTERVAL = 15;
    static final String VIDEO_MIME = "video/avc";
    private final Thread videoThread;
    private int videoTrackIndex = -1;
    private final Object videoLock = new Object();
    private boolean stoppedVideo = false;
    private long lastVideoWriteTimeUs = -1;

    // audio
    private MediaCodec audioEncoder;
    private boolean audioEnabled;
    private AudioRecord audioRecord;
    static final String AUDIO_MIME = "audio/mp4a-latm";
    static final int MAX_INPUT_SIZE = 16384;
    private Thread audioThread;
    private final Object audioLock = new Object();
    private boolean stoppedAudio = false;
    private int audioTrackIndex = -1;
    private long audioEnqueueTimeNano;
    private long lastAudioWriteTimeUs = -1;

    // audio and video
    boolean stopped = false;
    private long startTimeUs = -1;
    private boolean paused = false;
    private final CamcorderProfile profile;


    // muxer
    private final String outputFilePath;
    private final MediaMuxer muxer;
    private final Object muxerLock = new Object();

    public Recorder(String outputFilePath, CameraFeatures cameraFeatures, boolean audioEnabled) throws IOException {

        // setup members
        this.audioEnabled = audioEnabled;
        this.outputFilePath = outputFilePath;
        final ResolutionFeature resolutionFeature = cameraFeatures.getResolution();

        // get initial rotation
        final PlatformChannel.DeviceOrientation lockedOrientation =
                ((SensorOrientationFeature) cameraFeatures.getSensorOrientation())
                        .getLockedCaptureOrientation();
        rotation = lockedOrientation== null
                ? cameraFeatures.getSensorOrientation().getDeviceOrientationManager().getVideoOrientation()
                : cameraFeatures.getSensorOrientation().getDeviceOrientationManager().getVideoOrientation(lockedOrientation);

        profile = resolutionFeature.getRecordingProfile();

        // setup muxer
        muxer = new MediaMuxer(outputFilePath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4);
        muxer.setOrientationHint(rotation);

        // setup video encoder
        MediaFormat videoEncoderFormat = MediaFormat.createVideoFormat(VIDEO_MIME, profile.videoFrameWidth , profile.videoFrameHeight);
        videoEncoderFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface);
        videoEncoderFormat.setInteger(MediaFormat.KEY_BIT_RATE, profile.videoBitRate);
        videoEncoderFormat.setInteger(MediaFormat.KEY_FRAME_RATE, profile.videoFrameRate);
        videoEncoderFormat.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, I_FRAME_INTERVAL);
        videoEncoderFormat.setString(MediaFormat.KEY_MIME, VIDEO_MIME);
        String encoderName = new MediaCodecList(MediaCodecList.REGULAR_CODECS).findEncoderForFormat(videoEncoderFormat);
        videoEncoder = MediaCodec.createByCodecName(encoderName);
        videoEncoder.configure(videoEncoderFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
        videoEncoderSurface = videoEncoder.createInputSurface();

        // setup audio recorder
        if(audioEnabled) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                audioRecord = new AudioRecord.Builder()
                        .setAudioSource(MediaRecorder.AudioSource.MIC)
                        .setAudioFormat(new AudioFormat.Builder()
                                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                                .setSampleRate(profile.audioSampleRate)
                                .setChannelMask(AudioFormat.CHANNEL_IN_MONO)
                                .build())
                        .build();
            } else {
                // audioRecord = new AudioRecord(); TODO:
                audioRecord = null;
            }

            // setup audio encoder
            MediaFormat audioFormat = MediaFormat.createAudioFormat(AUDIO_MIME, audioRecord.getSampleRate(), audioRecord.getChannelCount());
            audioFormat.setString(MediaFormat.KEY_MIME, AUDIO_MIME);
            audioFormat.setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC);
            audioFormat.setInteger(MediaFormat.KEY_BIT_RATE, profile.audioBitRate);
            audioFormat.setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, MAX_INPUT_SIZE);
            encoderName = new MediaCodecList(MediaCodecList.REGULAR_CODECS).findEncoderForFormat(audioFormat);
            audioEncoder = MediaCodec.createByCodecName(encoderName);
            audioEncoder.configure(audioFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
        }

        // setup video renderer
        videoRenderer = new VideoRenderer(videoEncoderSurface, profile.videoFrameWidth,profile.videoFrameHeight);
        videoRenderer.setRotation(rotation);

        videoThread = new Thread(){
            public void run(){
                videoLoop();
            }
        };

        if(audioEnabled) {
            audioThread = new Thread() {
                public void run() {
                    audioLoop();
                }
            };
        }
    }

    public void start(){
        if((audioEnabled && audioThread.isAlive()) || videoThread.isAlive()){
            return; // TODO: throw error already videoing or not complete videoing
        }


        videoEncoder.start();
        if(audioEnabled) {
            audioRecord.startRecording();
            audioEncoder.start();
        }


        videoThread.start();
        if(audioEnabled) {
            audioThread.start();
        }

    }

    public void stop(){
        videoEncoder.signalEndOfInputStream();
        if(audioEnabled) {
            audioRecord.stop();
        }
        waitStop();
    }

    public void close(){
        stop();
        if(audioRecord != null){
            audioRecord.release();
        }
        if(audioEncoder != null){
            audioEncoder.release();
        }
        if(videoEncoder != null){
            videoEncoder.release();
        }
        if(videoRenderer != null){
            videoRenderer.close();
        }
    }

    public void setPaused(boolean paused){
        synchronized (muxerLock){
            this.paused = paused;
        }
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
    private void videoLoop(){

        initializeVideoEncoder();
        try {
            waitAudioEncoderInitialized();

            muxer.start();

            while(!stopped) {
                writeVideo();
            }

        } catch (InterruptedException e) {
            Log.e(TAG, "Video loop interrupeted ", e);
        }
    }

    private void audioLoop(){

        try {

            waitVideoEncoderInitialized();
            initializeAudioEncoder();
            waitForVideoFirstFrame();

            // start audio at same timestamp video starts on
            audioEnqueueTimeNano = startTimeUs * 1000;


            while(!stopped){
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    enqueueAudio(); // TODO:
                }
                writeAudio();
            }

            // log durations
            long elapsedAudio = lastVideoWriteTimeUs - startTimeUs;
            long elapsedVideo = lastAudioWriteTimeUs - startTimeUs;
            Log.d(TAG, "timeCount elapsed Audio=Video: " + usToSeconds(elapsedAudio) + " = " + usToSeconds(elapsedVideo));


        } catch (InterruptedException e) {
            Log.e(TAG, "Audio loop interrupeted ", e);
        }
    }

    /** Wait for video's first frame, in essence waiting for known start Presentation Time*/
    private void waitForVideoFirstFrame() throws InterruptedException {
        synchronized(videoLock) {
            while (startTimeUs < 0) {
                Log.e(TAG, "skipping audio frame because video hasn't started");
                videoLock.wait(500);
            }
        }
    }

    /** Enqueues audio from recorder into encoder */
    @RequiresApi(api = Build.VERSION_CODES.M)
    private void enqueueAudio(){
        if(stopped || stoppedAudio){
            return;
        }
        // enqueue audio
        int audioEnqueueIndex = audioEncoder.dequeueInputBuffer(50);
        try {

            if(audioEnqueueIndex < 0) {
                // Log.d(TAG, "No audio buffer available to dequeue");
                return;
            }

            // get encoder buffer
            ByteBuffer audioeEnqueueBuffer = audioEncoder.getInputBuffer(audioEnqueueIndex);

            // write bytes from audioRecord to buffer
            int bytes = audioRecord.getBufferSizeInFrames() * 16 * audioRecord.getChannelCount(); // MUST BE MULTIPLE OF something TODO:
            int length = audioRecord.read(audioeEnqueueBuffer, bytes);

            // verify value is good
            switch (length) {
                case AudioRecord.ERROR_BAD_VALUE:
                    throw new RuntimeException("enqueue audio error bad value");
                case AudioRecord.ERROR_DEAD_OBJECT:
                    throw new RuntimeException("enqueue audio error dead object");
                case AudioRecord.ERROR_INVALID_OPERATION:
                    throw new RuntimeException("enqueue audio error invalid operation");
            }

            // calculate nanoSeconds sampled from audio record
            MediaFormat audioFormat = audioEncoder.getInputFormat();
            int sampleRate = audioFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE);
            int sampleSize = 16; // because ENCODING_PCM_16BIT
            int bitsPerSecond = sampleRate * sampleSize;
            int bits = length * 8;
            float secondsSampled = (float)bits / (float)bitsPerSecond;
            long nanoSecondsSampled = (long)(secondsSampled * 1000000000);

            // drain audio recorder until empty
            boolean eos = length == 0 && stoppedVideo;

            // queue buffer for encoding
            audioEncoder.queueInputBuffer(
                    audioEnqueueIndex,
                    0,
                    length,
                    audioEnqueueTimeNano / 1000,
                    eos ? MediaCodec.BUFFER_FLAG_END_OF_STREAM : 0);

            // add seconds we queued so next timestamp is correct
            audioEnqueueTimeNano += nanoSecondsSampled;

        }catch(Exception er){
            Log.e(TAG, "audio enqueue error ", er);
        }

    }

    /** Writes audio from encoder to muxer */
    private void writeAudio(){
        if(stopped || stoppedAudio){
            return;
        }

        // get buffer index ready to be written
        MediaCodec.BufferInfo audioWriteInfo = new MediaCodec.BufferInfo();
        int audioWriteIndex = audioEncoder.dequeueOutputBuffer(audioWriteInfo, 50);

        try{
            if(audioWriteIndex < 0) {
                // Log.d(TAG, " no audio ready to be written");
                return;
            }

            // get buffer ready to be written
            ByteBuffer audioWriteBuffer = audioEncoder.getOutputBuffer(audioWriteIndex);


            // if eos
            if ((audioWriteInfo.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                Log.d(TAG, "Audio EOS at " + usToSeconds(lastAudioWriteTimeUs) + " seconds");
                stoppedAudio = true;
                audioEncoder.stop();
                if(stoppedVideo){
                    stopInternal();
                }
                return;
            }

            // write if valid presentation time
            if(audioWriteInfo.presentationTimeUs > lastAudioWriteTimeUs && audioWriteInfo.presentationTimeUs > 0) {
                synchronized(muxerLock) {
                    if(!paused) {
                        muxer.writeSampleData(audioTrackIndex, audioWriteBuffer, audioWriteInfo);
                    }
                }
                lastAudioWriteTimeUs = audioWriteInfo.presentationTimeUs;
            }else{
                Log.d(TAG, "Skipping audio frame. Tried to write audio with time " + usToSeconds(audioWriteInfo.presentationTimeUs) + " when last write was " + usToSeconds(lastAudioWriteTimeUs));
            }

            // release for reuse
            audioEncoder.releaseOutputBuffer(audioWriteIndex,false);

        }catch(Exception er){
            Log.e(TAG, "Audio write error ", er);
            if(audioWriteIndex >= 0){
                audioEncoder.releaseOutputBuffer(audioWriteIndex,false);
            }
        }

    }


    /** Pulls video from encoder and writes to mutex */
    private void writeVideo(){
        if(stopped || stoppedVideo){
            return;
        }
        // write encoded video
        MediaCodec.BufferInfo videoInfo = new MediaCodec.BufferInfo();
        int videoIndex = videoEncoder.dequeueOutputBuffer(videoInfo,-1);

        // first frame - note start time
        if(videoInfo.presentationTimeUs != 0 && startTimeUs < 0){
            synchronized (videoLock) {
                startTimeUs = videoInfo.presentationTimeUs;
                Log.d(TAG, "Started recording video at " + usToSeconds(startTimeUs) + " seconds");
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
                Log.d(TAG, "Video EOS at " + usToSeconds(lastVideoWriteTimeUs) + " seconds");
                stoppedVideo = true;
                videoRenderer.close();
                videoEncoder.stop();
                if(!audioEnabled || stoppedAudio){
                    stopInternal();
                }
            }

            // write to muxer
            if(videoInfo.presentationTimeUs > 0) {
                synchronized(muxerLock) {
                    if(!paused) {
                        muxer.writeSampleData(videoTrackIndex, videoBuffer, videoInfo);
                    }
                }
                lastVideoWriteTimeUs = videoInfo.presentationTimeUs;
            }

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

    private void initializeAudioEncoder(){
        while(audioTrackIndex < 0) {
            MediaCodec.BufferInfo audioInfo = new MediaCodec.BufferInfo();
            int audioIndex = audioEncoder.dequeueOutputBuffer(audioInfo, -1);
            if (audioIndex >= 0) {
                audioEncoder.releaseOutputBuffer(audioIndex, false);
            } else {
                Log.d(TAG, "Initialize audio format");
                synchronized (audioLock){
                    audioTrackIndex = muxer.addTrack(audioEncoder.getOutputFormat());
                    audioLock.notifyAll();
                }
            }
        }
    }

    private void waitAudioEncoderInitialized() throws InterruptedException {
        if(audioEncoder == null) return;
        synchronized(audioLock){
            while(audioTrackIndex < 0){
                audioLock.wait(500);
            }
        }
    }

    private void waitVideoEncoderInitialized() throws InterruptedException {
        synchronized(videoLock){
            while(videoTrackIndex < 0){
                videoLock.wait(500);
            }
        }
    }

    private void waitStop(){
        try{
            synchronized (muxerLock) {
                while (!stopped) {
                    muxerLock.wait(500);
                }
            }
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    private void stopInternal(){
        Log.d(TAG, "Stop internal");
        stopped = true;
        synchronized (muxerLock){
            muxer.stop();
            muxerLock.notifyAll();
        }


    }

    private float usToSeconds(long us){
        return ((float) us / 10000000);
    }


}
