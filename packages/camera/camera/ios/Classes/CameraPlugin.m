// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CameraPlugin.h"
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <CoreMotion/CoreMotion.h>
#import <libkern/OSAtomic.h>
#import <uuid/uuid.h>

static FlutterError *getFlutterError(NSError *error) {
    return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)error.code]
                               message:error.localizedDescription
                               details:error.domain];
}

@interface FLTSavePhotoDelegate : NSObject <AVCapturePhotoCaptureDelegate>
@property(readonly, nonatomic) NSString *path;
@property(readonly, nonatomic) FlutterResult result;
@property(readonly, nonatomic) CMMotionManager *motionManager;
@property(readonly, nonatomic) AVCaptureDevicePosition cameraPosition;
@end

@interface FLTImageStreamHandler : NSObject <FlutterStreamHandler>
@property FlutterEventSink eventSink;
@end

@implementation FLTImageStreamHandler

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events;
    return nil;
}
@end

@implementation FLTSavePhotoDelegate {
    /// Used to keep the delegate alive until didFinishProcessingPhotoSampleBuffer.
    FLTSavePhotoDelegate *selfReference;
}

- initWithPath:(NSString *)path
        result:(FlutterResult)result
  motionManager:(CMMotionManager *)motionManager
 cameraPosition:(AVCaptureDevicePosition)cameraPosition {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    _path = path;
    _motionManager = motionManager;
    _cameraPosition = cameraPosition;
    selfReference = self;
    _result = result;
    return self;
}

- (void)captureOutput:(AVCapturePhotoOutput *)output
didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer
previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer
     resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
      bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings
                error:(NSError *)error API_AVAILABLE(ios(10)) {
    selfReference = nil;
    if (error) {
        _result(getFlutterError(error));
        return;
    }
    NSData *data = [AVCapturePhotoOutput
                    JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer
                    previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    UIImage *image = [UIImage imageWithCGImage:[UIImage imageWithData:data].CGImage
                                         scale:1.0
                                   orientation:[self getImageRotation]];
    // TODO(sigurdm): Consider writing file asynchronously.
    bool success = [UIImageJPEGRepresentation(image, 1.0) writeToFile:_path atomically:YES];
    if (!success) {
        _result([FlutterError errorWithCode:@"IOError" message:@"Unable to write file" details:nil]);
        return;
    }
    _result(_path);
}

- (UIImageOrientation)getImageRotation {
    float const threshold = 45.0;
    BOOL (^isNearValue)(float value1, float value2) = ^BOOL(float value1, float value2) {
        return fabsf(value1 - value2) < threshold;
    };
    BOOL (^isNearValueABS)(float value1, float value2) = ^BOOL(float value1, float value2) {
        return isNearValue(fabsf(value1), fabsf(value2));
    };
    float yxAtan = (atan2(_motionManager.accelerometerData.acceleration.y,
                          _motionManager.accelerometerData.acceleration.x)) *
    180 / M_PI;
    if (isNearValue(-90.0, yxAtan)) {
        return UIImageOrientationRight;
    } else if (isNearValueABS(180.0, yxAtan)) {
        return _cameraPosition == AVCaptureDevicePositionBack ? UIImageOrientationUp
        : UIImageOrientationDown;
    } else if (isNearValueABS(0.0, yxAtan)) {
        return _cameraPosition == AVCaptureDevicePositionBack ? UIImageOrientationDown /*rotate 180* */
        : UIImageOrientationUp /*do not rotate*/;
    } else if (isNearValue(90.0, yxAtan)) {
        return UIImageOrientationLeft;
    }
    // If none of the above, then the device is likely facing straight down or straight up -- just
    // pick something arbitrary
    // TODO: Maybe use the UIInterfaceOrientation if in these scenarios
    return UIImageOrientationUp;
}
@end

// Mirrors ResolutionPreset in camera.dart
typedef enum {
    veryLow,
    low,
    medium,
    high,
    veryHigh,
    ultraHigh,
    max,
} ResolutionPreset;

static ResolutionPreset getResolutionPresetForString(NSString *preset) {
    if ([preset isEqualToString:@"veryLow"]) {
        return veryLow;
    } else if ([preset isEqualToString:@"low"]) {
        return low;
    } else if ([preset isEqualToString:@"medium"]) {
        return medium;
    } else if ([preset isEqualToString:@"high"]) {
        return high;
    } else if ([preset isEqualToString:@"veryHigh"]) {
        return veryHigh;
    } else if ([preset isEqualToString:@"ultraHigh"]) {
        return ultraHigh;
    } else if ([preset isEqualToString:@"max"]) {
        return max;
    } else {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                             code:NSURLErrorUnknown
                                         userInfo:@{
                                             NSLocalizedDescriptionKey : [NSString
                                                                          stringWithFormat:@"Unknown resolution preset %@", preset]
                                         }];
        @throw error;
    }
}

@interface FLTCam : NSObject <FlutterTexture,
AVCaptureVideoDataOutputSampleBufferDelegate,
AVCaptureAudioDataOutputSampleBufferDelegate
>
@property(readonly, nonatomic) int64_t textureId;
@property(nonatomic, copy) void (^onFrameAvailable)(void);
@property BOOL enableAudio;
@property(nonatomic) FLTImageStreamHandler *imageStreamHandler;
@property(nonatomic) FlutterMethodChannel *methodChannel;
@property(readonly, nonatomic) AVCaptureSession *captureSession;
@property(readonly, nonatomic) AVCaptureDevice *captureDevice;
@property(readonly, nonatomic) AVCapturePhotoOutput *capturePhotoOutput API_AVAILABLE(ios(10));
@property(readonly, nonatomic) AVCaptureVideoDataOutput *captureVideoOutput;
@property(readonly, nonatomic) AVCaptureInput *captureVideoInput;
@property(readonly) CVPixelBufferRef volatile latestPixelBuffer;
@property(readonly, nonatomic) CGSize previewSize;
@property(readonly, nonatomic) CGSize captureSize;
@property(strong, nonatomic) AVAssetWriter *videoWriter;
@property(strong, nonatomic) AVAssetWriterInput *videoWriterInput;
@property(strong, nonatomic) AVAssetWriterInput *audioWriterInput;
@property(strong, nonatomic) AVAssetWriterInputPixelBufferAdaptor *assetWriterPixelBufferAdaptor;
@property(strong, nonatomic) AVCaptureVideoDataOutput *videoOutput;
@property(strong, nonatomic) AVCaptureAudioDataOutput *audioOutput;
@property(strong, nonatomic) NSString *videoRecordingPath;
@property(assign, nonatomic) BOOL isRecording;
@property(assign, nonatomic) BOOL isRecordingPaused;
@property(assign, nonatomic) BOOL videoIsDisconnected;
@property(assign, nonatomic) BOOL audioIsDisconnected;
@property(assign, nonatomic) BOOL isAudioSetup;
@property(assign, nonatomic) BOOL isStreamingImages;
@property(assign, nonatomic) ResolutionPreset resolutionPreset;
@property(assign, nonatomic) CMTime lastVideoSampleTime;
@property(assign, nonatomic) CMTime lastAudioSampleTime;
@property(assign, nonatomic) CMTime videoTimeOffset;
@property(assign, nonatomic) CMTime audioTimeOffset;
@property(nonatomic) CMMotionManager *motionManager;
@property AVAssetWriterInputPixelBufferAdaptor *videoAdaptor;
@end

@implementation FLTCam {
    dispatch_queue_t _dispatchQueue;
}
// Format used for video and image streaming.
FourCharCode const videoFormat = kCVPixelFormatType_32BGRA;

- (instancetype)initWithCameraName:(NSString *)cameraName
                  resolutionPreset:(NSString *)resolutionPreset
                       enableAudio:(BOOL)enableAudio
                     dispatchQueue:(dispatch_queue_t)dispatchQueue
                             error:(NSError **)error {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    @try {
        _resolutionPreset = getResolutionPresetForString(resolutionPreset);
    } @catch (NSError *e) {
        *error = e;
    }
    _enableAudio = enableAudio;
    _dispatchQueue = dispatchQueue;
    _captureSession = [[AVCaptureSession alloc] init];
    
    _captureDevice = [AVCaptureDevice deviceWithUniqueID:cameraName];
    NSError *localError = nil;
    _captureVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice
                                                               error:&localError];
    if (localError) {
        *error = localError;
        return nil;
    }
    
    _captureVideoOutput = [AVCaptureVideoDataOutput new];
    _captureVideoOutput.videoSettings =
    @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(videoFormat)};
    [_captureVideoOutput setAlwaysDiscardsLateVideoFrames:YES];
    [_captureVideoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    AVCaptureConnection *connection =
    [AVCaptureConnection connectionWithInputPorts:_captureVideoInput.ports
                                           output:_captureVideoOutput];
    if ([_captureDevice position] == AVCaptureDevicePositionFront) {
        connection.videoMirrored = YES;
    }
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [_captureSession addInputWithNoConnections:_captureVideoInput];
    [_captureSession addOutputWithNoConnections:_captureVideoOutput];
    [_captureSession addConnection:connection];
    
    if (@available(iOS 10.0, *)) {
        _capturePhotoOutput = [AVCapturePhotoOutput new];
        [_capturePhotoOutput setHighResolutionCaptureEnabled:YES];
        [_captureSession addOutput:_capturePhotoOutput];
    }
    _motionManager = [[CMMotionManager alloc] init];
    [_motionManager startAccelerometerUpdates];
    
    [self setCaptureSessionPreset:_resolutionPreset];
    return self;
}

- (void)start {
    [_captureSession startRunning];
}

- (void)stop {
    [_captureSession stopRunning];
}

- (void)captureToFile:(FlutterResult)result API_AVAILABLE(ios(10)) {
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
    if (_resolutionPreset == max) {
        [settings setHighResolutionPhotoEnabled:YES];
    }
    NSError *error;
    NSString *path = [self getTemporaryFilePathWithExtension:@"jpg" subfolder:@"pictures" prefix:@"CAP_" error:error];
    if (error) {
        result(getFlutterError(error));
        return;
    }
    [_capturePhotoOutput
     capturePhotoWithSettings:settings
     delegate:[[FLTSavePhotoDelegate alloc] initWithPath:path
                                                  result:result
                                           motionManager:_motionManager
                                          cameraPosition:_captureDevice.position
                                        ]];
}

- (NSString*)getTemporaryFilePathWithExtension:(NSString*) extension subfolder:(NSString*) subfolder prefix:(NSString*) prefix error:(NSError *) error
{
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *fileDir = [[docDir stringByAppendingPathComponent:@"camera"] stringByAppendingPathComponent:subfolder];
    NSString *fileName = [prefix stringByAppendingString:[[NSUUID UUID] UUIDString]];
    NSString *file = [[fileDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:extension];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:fileDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fileDir withIntermediateDirectories:true attributes:nil error:&error];
        if (error) {
            return nil;
        }
    }
    
    return file;
}

- (void)setCaptureSessionPreset:(ResolutionPreset)resolutionPreset {
    switch (resolutionPreset) {
        case max:
        case ultraHigh:
            if (@available(iOS 9.0, *)) {
                if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset3840x2160]) {
                    _captureSession.sessionPreset = AVCaptureSessionPreset3840x2160;
                    _previewSize = CGSizeMake(3840, 2160);
                    break;
                }
            }
            if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
                _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
                _previewSize =
                CGSizeMake(_captureDevice.activeFormat.highResolutionStillImageDimensions.width,
                           _captureDevice.activeFormat.highResolutionStillImageDimensions.height);
                break;
            }
        case veryHigh:
            if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
                _captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
                _previewSize = CGSizeMake(1920, 1080);
                break;
            }
        case high:
            if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
                _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
                _previewSize = CGSizeMake(1280, 720);
                break;
            }
        case medium:
            if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
                _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
                _previewSize = CGSizeMake(640, 480);
                break;
            }
        case low:
            if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset352x288]) {
                _captureSession.sessionPreset = AVCaptureSessionPreset352x288;
                _previewSize = CGSizeMake(352, 288);
                break;
            }
        default:
            if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetLow]) {
                _captureSession.sessionPreset = AVCaptureSessionPresetLow;
                _previewSize = CGSizeMake(352, 288);
            } else {
                NSError *error =
                [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:NSURLErrorUnknown
                                userInfo:@{
                                    NSLocalizedDescriptionKey :
                                        @"No capture session available for current capture session."
                                }];
                @throw error;
            }
    }
}

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    if (output == _captureVideoOutput) {
        CVPixelBufferRef newBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CFRetain(newBuffer);
        CVPixelBufferRef old = _latestPixelBuffer;
        while (!OSAtomicCompareAndSwapPtrBarrier(old, newBuffer, (void **)&_latestPixelBuffer)) {
            old = _latestPixelBuffer;
        }
        if (old != nil) {
            CFRelease(old);
        }
        if (_onFrameAvailable) {
            _onFrameAvailable();
        }
    }
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        [_methodChannel invokeMethod:@"error" arguments:@"sample buffer is not ready. Skipping sample"];
        return;
    }
    if (_isStreamingImages) {
        if (_imageStreamHandler.eventSink) {
            CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
            
            size_t imageWidth = CVPixelBufferGetWidth(pixelBuffer);
            size_t imageHeight = CVPixelBufferGetHeight(pixelBuffer);
            
            NSMutableArray *planes = [NSMutableArray array];
            
            const Boolean isPlanar = CVPixelBufferIsPlanar(pixelBuffer);
            size_t planeCount;
            if (isPlanar) {
                planeCount = CVPixelBufferGetPlaneCount(pixelBuffer);
            } else {
                planeCount = 1;
            }
            
            for (int i = 0; i < planeCount; i++) {
                void *planeAddress;
                size_t bytesPerRow;
                size_t height;
                size_t width;
                
                if (isPlanar) {
                    planeAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, i);
                    bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, i);
                    height = CVPixelBufferGetHeightOfPlane(pixelBuffer, i);
                    width = CVPixelBufferGetWidthOfPlane(pixelBuffer, i);
                } else {
                    planeAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
                    bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
                    height = CVPixelBufferGetHeight(pixelBuffer);
                    width = CVPixelBufferGetWidth(pixelBuffer);
                }
                
                NSNumber *length = @(bytesPerRow * height);
                NSData *bytes = [NSData dataWithBytes:planeAddress length:length.unsignedIntegerValue];
                
                NSMutableDictionary *planeBuffer = [NSMutableDictionary dictionary];
                planeBuffer[@"bytesPerRow"] = @(bytesPerRow);
                planeBuffer[@"width"] = @(width);
                planeBuffer[@"height"] = @(height);
                planeBuffer[@"bytes"] = [FlutterStandardTypedData typedDataWithBytes:bytes];
                
                [planes addObject:planeBuffer];
            }
            
            NSMutableDictionary *imageBuffer = [NSMutableDictionary dictionary];
            imageBuffer[@"width"] = [NSNumber numberWithUnsignedLong:imageWidth];
            imageBuffer[@"height"] = [NSNumber numberWithUnsignedLong:imageHeight];
            imageBuffer[@"format"] = @(videoFormat);
            imageBuffer[@"planes"] = planes;
            
            _imageStreamHandler.eventSink(imageBuffer);
            
            CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
        }
    }
    if (_isRecording && !_isRecordingPaused) {
        if (_videoWriter.status == AVAssetWriterStatusFailed) {
            [_methodChannel invokeMethod:@"error" arguments:[NSString stringWithFormat:@"%@", _videoWriter.error]];
            return;
        }
        
        CFRetain(sampleBuffer);
        CMTime currentSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        if (_videoWriter.status != AVAssetWriterStatusWriting) {
            [_videoWriter startWriting];
            [_videoWriter startSessionAtSourceTime:currentSampleTime];
        }
        
        if (output == _captureVideoOutput) {
            if (_videoIsDisconnected) {
                _videoIsDisconnected = NO;
                
                if (_videoTimeOffset.value == 0) {
                    _videoTimeOffset = CMTimeSubtract(currentSampleTime, _lastVideoSampleTime);
                } else {
                    CMTime offset = CMTimeSubtract(currentSampleTime, _lastVideoSampleTime);
                    _videoTimeOffset = CMTimeAdd(_videoTimeOffset, offset);
                }
                
                return;
            }
            
            _lastVideoSampleTime = currentSampleTime;
            
            CVPixelBufferRef nextBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            CMTime nextSampleTime = CMTimeSubtract(_lastVideoSampleTime, _videoTimeOffset);
            [_videoAdaptor appendPixelBuffer:nextBuffer withPresentationTime:nextSampleTime];
        } else {
            CMTime dur = CMSampleBufferGetDuration(sampleBuffer);
            
            if (dur.value > 0) {
                currentSampleTime = CMTimeAdd(currentSampleTime, dur);
            }
            
            if (_audioIsDisconnected) {
                _audioIsDisconnected = NO;
                
                if (_audioTimeOffset.value == 0) {
                    _audioTimeOffset = CMTimeSubtract(currentSampleTime, _lastAudioSampleTime);
                } else {
                    CMTime offset = CMTimeSubtract(currentSampleTime, _lastAudioSampleTime);
                    _audioTimeOffset = CMTimeAdd(_audioTimeOffset, offset);
                }
                
                return;
            }
            
            _lastAudioSampleTime = currentSampleTime;
            
            if (_audioTimeOffset.value != 0) {
                CFRelease(sampleBuffer);
                sampleBuffer = [self adjustTime:sampleBuffer by:_audioTimeOffset];
            }
            
            [self newAudioSample:sampleBuffer];
        }
        
        CFRelease(sampleBuffer);
    }
}

- (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset CF_RETURNS_RETAINED {
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo *pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    for (CMItemCount i = 0; i < count; i++) {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    return sout;
}

- (void)newVideoSample:(CMSampleBufferRef)sampleBuffer {
    if (_videoWriter.status != AVAssetWriterStatusWriting) {
        if (_videoWriter.status == AVAssetWriterStatusFailed) {
            [_methodChannel invokeMethod:@"error" arguments:[NSString stringWithFormat:@"%@", _videoWriter.error]];
        }
        return;
    }
    if (_videoWriterInput.readyForMoreMediaData) {
        if (![_videoWriterInput appendSampleBuffer:sampleBuffer]) {
            [_methodChannel invokeMethod:@"error" arguments:[NSString stringWithFormat:@"%@", @"Unable to write to video input"]];
        }
    }
}

- (void)newAudioSample:(CMSampleBufferRef)sampleBuffer {
    if (_videoWriter.status != AVAssetWriterStatusWriting) {
        if (_videoWriter.status == AVAssetWriterStatusFailed) {
            [_methodChannel invokeMethod:@"error" arguments:[NSString stringWithFormat:@"%@", _videoWriter.error]];
        }
        return;
    }
    if (_audioWriterInput.readyForMoreMediaData) {
        if (![_audioWriterInput appendSampleBuffer:sampleBuffer]) {
            [_methodChannel invokeMethod:@"error" arguments:[NSString stringWithFormat:@"%@", @"Unable to write to audio input"]];
        }
    }
}

- (void)close {
    [_captureSession stopRunning];
    for (AVCaptureInput *input in [_captureSession inputs]) {
        [_captureSession removeInput:input];
    }
    for (AVCaptureOutput *output in [_captureSession outputs]) {
        [_captureSession removeOutput:output];
    }
}

- (void)dealloc {
    if (_latestPixelBuffer) {
        CFRelease(_latestPixelBuffer);
    }
    [_motionManager stopAccelerometerUpdates];
}

- (CVPixelBufferRef)copyPixelBuffer {
    CVPixelBufferRef pixelBuffer = _latestPixelBuffer;
    while (!OSAtomicCompareAndSwapPtrBarrier(pixelBuffer, nil, (void **)&_latestPixelBuffer)) {
        pixelBuffer = _latestPixelBuffer;
    }
    
    return pixelBuffer;
}

- (void)startVideoRecordingWithResult:(FlutterResult)result {
    if (!_isRecording) {
        NSError *error;
        _videoRecordingPath = [self getTemporaryFilePathWithExtension:@"mp4" subfolder:@"videos" prefix:@"CAP_" error:error];
        if (error) {
            result(getFlutterError(error));
            return;
        }
        if (![self setupWriterForPath:_videoRecordingPath]) {
            result([FlutterError errorWithCode:@"IOError" message:@"Setup Writer Failed" details:nil]);
            return;
        }
        _isRecording = YES;
        _isRecordingPaused = NO;
        _videoTimeOffset = CMTimeMake(0, 1);
        _audioTimeOffset = CMTimeMake(0, 1);
        _videoIsDisconnected = NO;
        _audioIsDisconnected = NO;
        result(nil);
    } else {
        result([FlutterError errorWithCode:@"Error" message:@"Video is already recording" details:nil]);
    }
}

- (void)stopVideoRecordingWithResult:(FlutterResult)result {
    if (_isRecording) {
        _isRecording = NO;
        if (_videoWriter.status != AVAssetWriterStatusUnknown) {
            [_videoWriter finishWritingWithCompletionHandler:^{
                if (self->_videoWriter.status == AVAssetWriterStatusCompleted) {
                    result(self->_videoRecordingPath);
                    self->_videoRecordingPath = nil;
                } else {
                    result([FlutterError errorWithCode:@"IOError" message:@"AVAssetWriter could not finish writing!" details:nil]);
                }
            }];
        }
    } else {
        NSError *error =
        [NSError errorWithDomain:NSCocoaErrorDomain
                            code:NSURLErrorResourceUnavailable
                        userInfo:@{NSLocalizedDescriptionKey : @"Video is not recording!"}];
        result(getFlutterError(error));
    }
}

- (void)pauseVideoRecordingWithResult:(FlutterResult)result {
    _isRecordingPaused = YES;
    _videoIsDisconnected = YES;
    _audioIsDisconnected = YES;
    result(nil);
}

- (void)resumeVideoRecordingWithResult:(FlutterResult)result {
    _isRecordingPaused = NO;
    result(nil);
}

- (void)startImageStreamWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    if (!_isStreamingImages) {
        FlutterEventChannel *eventChannel =
        [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/camera/imageStream"
                                  binaryMessenger:messenger];
        
        _imageStreamHandler = [[FLTImageStreamHandler alloc] init];
        [eventChannel setStreamHandler:_imageStreamHandler];
        
        _isStreamingImages = YES;
    } else {
        [_methodChannel invokeMethod:@"error" arguments:@"Images from camera are already streaming!"];
    }
}

- (void)stopImageStream {
    if (_isStreamingImages) {
        _isStreamingImages = NO;
        _imageStreamHandler = nil;
    } else {
        [_methodChannel invokeMethod:@"error" arguments:@"Images from camera are not streaming!"];
    }
}

- (BOOL)setupWriterForPath:(NSString *)path {
    NSError *error = nil;
    NSURL *outputURL;
    if (path != nil) {
        outputURL = [NSURL fileURLWithPath:path];
    } else {
        return NO;
    }
    if (_enableAudio && !_isAudioSetup) {
        [self setUpCaptureSessionForAudio];
    }
    _videoWriter = [[AVAssetWriter alloc] initWithURL:outputURL
                                             fileType:AVFileTypeQuickTimeMovie
                                                error:&error];
    NSParameterAssert(_videoWriter);
    if (error) {
        [_methodChannel invokeMethod:@"error" arguments:error.description];
        return NO;
    }
    NSDictionary *videoSettings = [NSDictionary
                                   dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:_previewSize.height], AVVideoWidthKey,
                                   [NSNumber numberWithInt:_previewSize.width], AVVideoHeightKey,
                                   nil];
    _videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                           outputSettings:videoSettings];
    
    _videoAdaptor = [AVAssetWriterInputPixelBufferAdaptor
                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoWriterInput
                     sourcePixelBufferAttributes:@{
                         (NSString *)kCVPixelBufferPixelFormatTypeKey : @(videoFormat)
                     }];
    
    NSParameterAssert(_videoWriterInput);
    _videoWriterInput.expectsMediaDataInRealTime = YES;
    
    // Add the audio input
    if (_enableAudio) {
        AudioChannelLayout acl;
        bzero(&acl, sizeof(acl));
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
        NSDictionary *audioOutputSettings = nil;
        // Both type of audio inputs causes output video file to be corrupted.
        audioOutputSettings = [NSDictionary
                               dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                               [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                               [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                               [NSData dataWithBytes:&acl length:sizeof(acl)],
                               AVChannelLayoutKey, nil];
        _audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                               outputSettings:audioOutputSettings];
        _audioWriterInput.expectsMediaDataInRealTime = YES;
        
        [_videoWriter addInput:_audioWriterInput];
        [_audioOutput setSampleBufferDelegate:self queue:_dispatchQueue];
    }
    
    [_videoWriter addInput:_videoWriterInput];
    [_captureVideoOutput setSampleBufferDelegate:self queue:_dispatchQueue];
    
    return YES;
}
- (void)setUpCaptureSessionForAudio {
    NSError *error = nil;
    // Create a device input with the device and add it to the session.
    // Setup the audio input.
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice
                                                                             error:&error];
    if (error) {
        [_methodChannel invokeMethod:@"error" arguments:error.description];
    }
    // Setup the audio output.
    _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    
    if ([_captureSession canAddInput:audioInput]) {
        [_captureSession addInput:audioInput];
        
        if ([_captureSession canAddOutput:_audioOutput]) {
            [_captureSession addOutput:_audioOutput];
            _isAudioSetup = YES;
        } else {
            [_methodChannel invokeMethod:@"error" arguments:@"Unable to add Audio input/output to session capture"];
            _isAudioSetup = NO;
        }
    }
}
@end

@interface CameraPlugin ()
@property(readonly, nonatomic) NSObject<FlutterTextureRegistry> *registry;
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
@property(readonly, nonatomic) FLTCam *camera;
@end

@implementation CameraPlugin {
    dispatch_queue_t _dispatchQueue;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel =
    [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/camera"
                                binaryMessenger:[registrar messenger]];
    CameraPlugin *instance = [[CameraPlugin alloc] initWithRegistry:[registrar textures]
                                                          messenger:[registrar messenger]];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry
                       messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    _registry = registry;
    _messenger = messenger;
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (_dispatchQueue == nil) {
        _dispatchQueue = dispatch_queue_create("io.flutter.camera.dispatchqueue", NULL);
    }
    
    // Invoke the plugin on another dispatch queue to avoid blocking the UI.
    dispatch_async(_dispatchQueue, ^{
        [self handleMethodCallAsync:call result:result];
    });
}

- (void)handleMethodCallAsync:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"availableCameras" isEqualToString:call.method]) {
        if (@available(iOS 10.0, *)) {
            AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession
                                                                 discoverySessionWithDeviceTypes:@[ AVCaptureDeviceTypeBuiltInWideAngleCamera ]
                                                                 mediaType:AVMediaTypeVideo
                                                                 position:AVCaptureDevicePositionUnspecified];
            NSArray<AVCaptureDevice *> *devices = discoverySession.devices;
            NSMutableArray<NSDictionary<NSString *, NSObject *> *> *reply =
            [[NSMutableArray alloc] initWithCapacity:devices.count];
            for (AVCaptureDevice *device in devices) {
                NSString *lensFacing;
                switch ([device position]) {
                    case AVCaptureDevicePositionBack:
                        lensFacing = @"back";
                        break;
                    case AVCaptureDevicePositionFront:
                        lensFacing = @"front";
                        break;
                    case AVCaptureDevicePositionUnspecified:
                        lensFacing = @"external";
                        break;
                }
                [reply addObject:@{
                    @"name" : [device uniqueID],
                    @"lensFacing" : lensFacing,
                    @"sensorOrientation" : @90,
                }];
            }
            result(reply);
        } else {
            result(FlutterMethodNotImplemented);
        }
    } else if ([@"create" isEqualToString:call.method]) {
        NSString *cameraName = call.arguments[@"cameraName"];
        NSString *resolutionPreset = call.arguments[@"resolutionPreset"];
        NSNumber *enableAudio = call.arguments[@"enableAudio"];
        NSError *error;
        FLTCam *cam = [[FLTCam alloc] initWithCameraName:cameraName
                                        resolutionPreset:resolutionPreset
                                             enableAudio:[enableAudio boolValue]
                                           dispatchQueue:_dispatchQueue
                                                   error:&error];
        
        if (error) {
            result(getFlutterError(error));
        } else {
            if (_camera) {
                [_camera close];
            }
            int64_t textureId = [_registry registerTexture:cam];
            _camera = cam;
            
            result(@{
                @"cameraId" : @(textureId),
            });
        }
    }  else if ([@"startImageStream" isEqualToString:call.method]) {
        [_camera startImageStreamWithMessenger:_messenger];
        result(nil);
    } else if ([@"stopImageStream" isEqualToString:call.method]) {
        [_camera stopImageStream];
        result(nil);
    } else {
        NSDictionary *argsMap = call.arguments;
        NSUInteger cameraId = ((NSNumber *)argsMap[@"cameraId"]).unsignedIntegerValue;
        if ([@"initialize" isEqualToString:call.method]) {
            __weak CameraPlugin *weakSelf = self;
            _camera.onFrameAvailable = ^{
                [weakSelf.registry textureFrameAvailable:cameraId];
            };
            FlutterMethodChannel *methodChannel = [FlutterMethodChannel
                                                   methodChannelWithName:[NSString
                                                                          stringWithFormat:@"flutter.io/cameraPlugin/camera%lld",
                                                                          (long long) cameraId]
                                                   binaryMessenger:_messenger];
            _camera.methodChannel = methodChannel;
            [methodChannel invokeMethod:@"initialized" arguments:@{
                @"previewWidth" : @(_camera.previewSize.width),
                @"previewHeight" : @(_camera.previewSize.height)
            }];
            [_camera start];
            result(nil);
        } else if ([@"takePicture" isEqualToString:call.method]) {
            if (@available(iOS 10.0, *)) {
                [_camera captureToFile:result];
            } else {
                result(FlutterMethodNotImplemented);
            }
        } else if ([@"dispose" isEqualToString:call.method]) {
            [_registry unregisterTexture:cameraId];
            [_camera close];
            _dispatchQueue = nil;
            result(nil);
        } else if ([@"prepareForVideoRecording" isEqualToString:call.method]) {
            [_camera setUpCaptureSessionForAudio];
            result(nil);
        } else if ([@"startVideoRecording" isEqualToString:call.method]) {
            [_camera startVideoRecordingWithResult:result];
        } else if ([@"stopVideoRecording" isEqualToString:call.method]) {
            [_camera stopVideoRecordingWithResult:result];
        } else if ([@"pauseVideoRecording" isEqualToString:call.method]) {
            [_camera pauseVideoRecordingWithResult:result];
        } else if ([@"resumeVideoRecording" isEqualToString:call.method]) {
            [_camera resumeVideoRecordingWithResult:result];
        } else {
            result(FlutterMethodNotImplemented);
        }
    }
}

@end
