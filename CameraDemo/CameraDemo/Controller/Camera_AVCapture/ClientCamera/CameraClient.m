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
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    AVCaptureVideoDataOutput* _videoOutput;
    AVCaptureAudioDataOutput* _audioOutput;
    
    dispatch_queue_t _videoQueue;
    dispatch_queue_t _audioQueue;
    
    AVCaptureConnection *_videoConnection;
    AVCaptureConnection *_audioConnection;
    
    AVEncoder* _h264Encoder;
    
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
        [self setupPreviewLayer];
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
    _h264Encoder = [AVEncoder encoderForHeight:480 andWidth:720];   //视频编码
    [_h264Encoder encodeWithBlock:^int(NSArray* data, double pts) {
        if (_rtspClient != nil)
        {
            NSLog(@"发送中....");
            _rtspClient.bitrate = _h264Encoder.bitspersecond;
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

/**
 *  设置视频Video的采集输入和采集输出
 */
- (void)setupVideoCapture{
    /* 配置视频Video的采集输入源（摄像头） */
    NSError *error = nil;
    AVCaptureDevice *dev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:dev error:&error];
    if (error) {
        NSLog(@"Error: getting video input device: %@", error.description);
    }
    [_session addInput:videoInput];
    
    
    /* 配置视频Video的采集输出 */
    _videoQueue = dispatch_queue_create("uk.co.gdcl.avencoder.capture", DISPATCH_QUEUE_SERIAL);
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_videoOutput setSampleBufferDelegate:self queue:_videoQueue];
    
    //配置输出视频图像格式
    NSString *formatTypeKey = (NSString *)kCVPixelBufferPixelFormatTypeKey;
    NSNumber *formatType = @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange);
    NSDictionary *videoSettings = @{formatTypeKey: formatType};
    _videoOutput.videoSettings = videoSettings;
    
    //_output.alwaysDiscardsLateVideoFrames = YES;
    
    [_session addOutput:_videoOutput];
    
    // 保存Connection，用于在SampleBufferDelegate中判断数据来源（是Video/Audio？）
    _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
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

- (void)setupPreviewLayer {
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//设置预览时的视频缩放方式
    //设置视频的朝向
}

- (AVCaptureVideoPreviewLayer *)getPreviewLayer
{
    if (_previewLayer == nil) {
        NSLog(@"_preview == nil, 请检查是否未初始化");
        [[[UIAlertView alloc]initWithTitle:@"发生错误" message:@"_preview == nil, 请检查是否未初始化" delegate:nil cancelButtonTitle:@"好的，我知道了" otherButtonTitles:nil] show];
    }
    return _previewLayer;
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



#pragma mark - AVCaptureOutput 中的 AVCaptureVideoDataOutputSampleBufferDelegate （AVCaptureVideoDataOutput 和 AVCaptureAudioDataOutput 都是 AVCaptureOutput 的子类，委托是通过 -setSampleBufferDelegate: queue: 设置的）
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // pass frame to encoder
    if (captureOutput == _videoOutput) {
        NSLog(@"在这里获得video sampleBuffer，做进一步处理（编码H.264）");
        [_h264Encoder encodeFrame:sampleBuffer];
        
    }else if (captureOutput == _audioOutput){
        NSLog(@"这里获得audio sampleBuffer，做进一步处理（编码AAC）");
        
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
    
    if (_h264Encoder)
    {
        [ _h264Encoder shutdown];
    }
}







@end
