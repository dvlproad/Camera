//
//  CameraClient.m
//  Lee
//
//  Created by lichq on 5/25/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import "CameraClient.h"
#import "AVEncoder.h"
#import "AACEncoder.h"  //lichq  顺便不要缺少AudioToolBox framework

#import "RTSPClientConnection.h" //add by lichq


#import "AVFoundation/AVAudioSettings.h"//lichq



static CameraClient *theClient;

@interface CameraClient  () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AsyncSocketDelegate>
{
    AVCaptureSession* _session;
    AVCaptureVideoPreviewLayer* _preview;
    AVCaptureVideoDataOutput* _output;
    AVCaptureAudioDataOutput* _audioOutput;
    dispatch_queue_t _captureQueue;
    dispatch_queue_t _audioQueue;
    AVCaptureConnection* _audioConnection;
    
    AVEncoder* _encoder;
    
    //    RTSPServer* _rtsp;
    RTSPClientConnection *_rtspClient;
    
}
@property (nonatomic, strong) AACEncoder *aacEncoder; //lichq


@end




@implementation CameraClient

//+ (void)initialize
//{
//    // test recommended to avoid duplicate init via subclass
//    if (self == [CameraClient class])
//    {
//        theClient = [[CameraClient alloc] init];
//    }
//}

+ (CameraClient *)client
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        theClient = [[self alloc] init];
        [theClient startupCapture];
    });
    return theClient;
}



- (BOOL)startupCapture{
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
        NSLog(@"setting client session");
        
        
        _session = [[AVCaptureSession alloc] init];
        [self setupVideoCapture];
        [self setupAudioCapture];
        _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"lllll");
}

- (BOOL)startupEncode:(NSString *)name host:(NSString *)host port:(NSString *)port
{
    if (_session == nil){
        NSLog(@"错误：_session == nil.请查看之前是否忘记执行startupCapture");
        return NO;
    }
    
    /*
    BOOL isConnectSuccess = [RTSPClientConnection canConnectToHost:host port:port];
    if (!isConnectSuccess){
        NSLog(@"错误：connect server error, 无法连接到流媒体服务器，请检查");
        return NO;
    }

    NSLog(@"can connect to server:rtsp://%@:%@. now begin startup client encode", host, port);//开始设置编码器
    */
    
    // create an encoder
    _encoder = [AVEncoder encoderForHeight:480 andWidth:720];   //视频编码
    [_encoder encodeWithBlock:^int(NSArray* data, double pts) {
        if (_rtspClient != nil)
        {
            NSLog(@"发送中....");
            _rtspClient.bitrate = _encoder.bitspersecond;
            [_rtspClient onVideoData:data time:pts];
        }else{
            NSLog(@"error: _rtspClient == nil. 不进行发送");
        }
        return 0;
    } onParams:^int(NSData *data) {
        _rtspClient = [RTSPClientConnection setupListener:data name:name host:host port:port];
        if (_rtspClient == nil) {
            NSLog(@"clent初始化失败，无法发送error: _rtspClient == nil");
            return NO;
        }
        return 0;
    }];
    
    
    _aacEncoder = [[AACEncoder alloc] init];    //音频编码

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

- (void)setupAudioCapture{
    // create capture device with video input
    
    /*
     * Create audio connection
     */
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = nil;
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&error];
    if (error) {
        NSLog(@"Error getting audio input device: %@", error.description);
    }
    if ([_session canAddInput:audioInput]) {
        [_session addInput:audioInput];
    }
    
    _audioQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
    _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    //NSDictionary* setcapSettings_audio = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey, nil];
    [_audioOutput setSampleBufferDelegate:self queue:_audioQueue];//dispatch_get_main_queue()
    if ([_session canAddOutput:_audioOutput]) {
        [_session addOutput:_audioOutput];
    }
    _audioConnection = [_audioOutput connectionWithMediaType:AVMediaTypeAudio];
}

- (AVCaptureVideoPreviewLayer *)getPreviewLayer
{
    if (_preview == nil) {
        NSLog(@"_preview == nil, 请检查是否未初始化");
        [[[UIAlertView alloc]initWithTitle:@"发生错误" message:@"_preview == nil, 请检查是否未初始化" delegate:nil cancelButtonTitle:@"好的，我知道了" otherButtonTitles:nil] show];
    }
    return _preview;
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
    if (captureOutput == _output) {
        [_encoder encodeFrame:sampleBuffer];
    }else if (captureOutput == _audioOutput){
        CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        double dPTS = (double)(pts.value) / pts.timescale;
        [_aacEncoder encodeSampleBuffer:sampleBuffer completionBlock:^(NSData *encodedData, NSError *error) {
            if (encodedData) {
                //NSLog(@"Encoded data (%d): %@", encodedData.length, encodedData.description);
                [_rtspClient onAudioData:encodedData time:dPTS]; //lichq
                
            } else {
                NSLog(@"Error encoding AAC: %@, %@", error, encodedData);
            }
        }];
    }
}

- (void)shutdown
{
    NSLog(@"shutting down client");
    if (_session)
    {
        [_session stopRunning];
        _session = nil;
    }
    //    if (_rtsp)
    //    {
    //        [_rtsp shutdownServer];
    //    }
    if (_rtspClient)
    {
        [_rtspClient shutdown];
    }
    if (_encoder)
    {
        [ _encoder shutdown];
    }
}







@end
