#import <AVFoundation/AVFoundation.h>
#import <Flutter/Flutter.h>
#import <libkern/OSAtomic.h>
#import "FirebaseMlVisionPlugin.h"
@import FirebaseMLVision;

@interface LiveView : NSObject<FlutterTexture, AVCaptureVideoDataOutputSampleBufferDelegate,
                               AVCaptureAudioDataOutputSampleBufferDelegate, FlutterStreamHandler>
@property(readonly, nonatomic) int64_t textureId;
@property(nonatomic) bool isUsingFrontCamera;
@property(nonatomic, copy) void (^onFrameAvailable)(void);
@property(nonatomic, copy) void (^onSizeAvailable)(CGSize previewSize, CGSize captureSize);
@property(nonatomic) FlutterEventChannel *eventChannel;
@property(nonatomic) FlutterEventSink eventSink;
@property(readonly, nonatomic) AVCaptureSession *captureSession;
@property(readonly, nonatomic) AVCaptureDevice *captureDevice;
@property(readonly, nonatomic) AVCaptureVideoDataOutput *captureVideoOutput;
@property(readonly, nonatomic) AVCaptureInput *captureVideoInput;
@property(readonly) CVPixelBufferRef volatile latestPixelBuffer;
@property(readonly, nonatomic) CGSize previewSize;
@property(readonly, nonatomic) CGSize captureSize;
@property(strong, nonatomic) AVCaptureVideoDataOutput *videoOutput;
- (instancetype)initWithCameraName:(NSString *)cameraName
                  resolutionPreset:(NSString *)resolutionPreset
                             error:(NSError **)error;
- (void)start;
- (void)stop;
- (void)close;
- (void)setDetector:(NSObject<Detector> *)detector withOptions:(NSDictionary *)detectorOptions;
@end
