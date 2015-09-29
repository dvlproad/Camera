//
//  CameraServer.m
//  Lee
//
//  Created by lichq on 5/26/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import "CameraServer.h"
#import "AVEncoder.h"
#import "RTSPServer.h"

static CameraServer* theServer;

@interface CameraServer  () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession* _session;
    AVCaptureVideoPreviewLayer* _preview;
    AVCaptureVideoDataOutput* _output;
    dispatch_queue_t _captureQueue;
    
    AVEncoder* _encoder;
    
    RTSPServer* _rtsp;
}
@end


@implementation CameraServer

//+ (void) initialize
//{
//    // test recommended to avoid duplicate init via subclass
//    if (self == [CameraServer class])
//    {
//        theServer = [[CameraServer alloc] init];
//    }
//}

+ (CameraServer*) server
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        theServer = [[self alloc] init];
        [theServer startup];
    });
    return theServer;
}

- (BOOL)startup
{
#if TARGET_IPHONE_SIMULATOR
    return NO;
#endif
    
    BOOL isSupportCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (isSupportCamera == NO) {
        [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"友情提示", nil)
                                   message:NSLocalizedString(@"对不起，您的手机不支持拍照功能", nil)
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"好的，我知道了", nil)
                         otherButtonTitles:nil] show];
        return NO;
    }
    
    if (_session == nil)
    {
        NSLog(@"setting server session");
        
        
        // create capture device with video input
        _session = [[AVCaptureSession alloc] init];
        [self setupVideoCapture];
        _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return YES;
}

- (void)setupVideoCapture{
    // create capture device with video input
    AVCaptureDevice* dev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:dev error:nil];
    [_session addInput:input];
    
    
    // create an output for YUV output with self as delegate
    _captureQueue = dispatch_queue_create("uk.co.gdcl.avencoder.capture", DISPATCH_QUEUE_SERIAL);
    _output = [[AVCaptureVideoDataOutput alloc] init];
    [_output setSampleBufferDelegate:self queue:_captureQueue];
    NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                    nil];
    //[_output setAlwaysDiscardsLateVideoFrames:YES];//lichq
    
    _output.videoSettings = setcapSettings;
    [_session addOutput:_output];
}

- (BOOL)startupEncode{
    if (_session == nil){
        NSLog(@"错误：_session == nil.请查看之前是否忘记执行startup");
        return NO;
    }
    
    // create an encoder
    _encoder = [AVEncoder encoderForHeight:480 andWidth:720];
    [_encoder encodeWithBlock:^int(NSArray* data, double pts) {
        if (_rtsp != nil)
        {
            _rtsp.bitrate = _encoder.bitspersecond;
            [_rtsp onVideoData:data time:pts];
        }
        return 0;
    } onParams:^int(NSData *data) {
        _rtsp = [RTSPServer setupListener:data];
        return 0;
    }];
    
    return YES;
}

- (void)startCapture{
    if (_session) {
        [_session startRunning];
    }
}

- (void)pauseCapture{
    if (_session) {
        [_session stopRunning];
    }
}


- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // pass frame to encoder
    [_encoder encodeFrame:sampleBuffer];
}

- (void) shutdown
{
    NSLog(@"shutting down server");
    if (_session)
    {
        [_session stopRunning];
        _session = nil;
    }
    if (_rtsp)
    {
        [_rtsp shutdownServer];
    }
    if (_encoder)
    {
        [ _encoder shutdown];
    }
}


- (AVCaptureVideoPreviewLayer*) getPreviewLayer
{
    if (_preview == nil) {
        NSLog(@"_preview == nil, 请检查是否未初始化");
        [[[UIAlertView alloc]initWithTitle:@"发生错误" message:@"_preview == nil, 请检查是否未初始化" delegate:nil cancelButtonTitle:@"好的，我知道了" otherButtonTitles:nil] show];
    }
    return _preview;
}

@end
