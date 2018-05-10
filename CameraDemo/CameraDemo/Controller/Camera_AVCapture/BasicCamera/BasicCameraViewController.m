//
//  BasicCameraViewController.m
//  Lee
//
//  Created by lichq on 5/25/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import "BasicCameraViewController.h"

@interface BasicCameraViewController ()

@end

@implementation BasicCameraViewController


//顺序参照：http://liwpk.blog.163.com/blog/static/3632617020134325021136/
#pragma mark - ①、创建要使用的对象initialSession
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialSession];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialSession];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialSession];
    }
    return self;
}



//创建session会话对象之前，我们先创建session中会使用到的输入设备对象和输出设备对象。其中输入设备对象的创建需要定义输入对象的类型，而输出设备对象的创建则需要定义的时视频数据输出对象的类型
//附：当要对视频进行实时处理时，需要使用的输出对象是 AVCaptureVideoDataOutput, 因为我们进行实时处理时，是要直接对camera buffer中的视频流进行处理。所以我们需要定义的是一个"视频数据输出对象"(AVCaptureVideoDataOutput),而不是其他对象,并将其添加到session上。AVCaptureSession，当录制开始后，可以控制调用相关回调来取音视频的每一贞数据。
- (void)initialSession
{
    return;
    
    /*
     1、输入设备对象的创建（种类有：
     ①AVMediaTypeVideo
     ②AVMediaTypeAudio
     */
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:nil];
    //self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    NSError *error;
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    self.audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    
    /*
     2、输出设备对象的创建（种类有：
     ①AVCaptureMovieFileOutput 输出到文件：完整的视频
     ②AVCaptureVideoDataOutput 可用于处理被捕获的视频帧：表示视频里的每一帧
     ③AVCaptureAudioDataOutput 可用于处理被捕获的音频数据
     ④AVCaptureStillImageOutput 可用于捕获带有元数据（MetaData）的静止图像
     */
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc]init];
    self.videoDataOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];//虽然videoSettings是指定一个字典，但是目前只支持kCVPixelBufferPixelFormatTypeKey，我们用它指定像素的输出格式。这个参数直接影响到生成图像的成功与否
    //由于我打算先做一个实时灰度的效果，所以这里使用kCVPixelFormatType_420YpCbCr8BiPlanarFullRange的输出格式，关于这个格式的详细说明，可以看最后面的参数资料3（YUV的维基）。
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];//表示丢弃延迟的帧
    
    dispatch_queue_t queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:queue];//设置sampleBuffer的代理(AVCaptureVideoDataOutputSampleBufferDelegate):设置我们自己的controller作为视频数据输出缓冲区(sample buffer)的代理。设置delegate回调（AVCaptureVideoDataOutputSampleBufferDelegate协议）和回调时所处的GCD队列。
    
    /*
     self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
     dispatch_queue_t queue_audio = dispatch_queue_create("AudioQueue", DISPATCH_QUEUE_SERIAL);
     [self.audioDataOutput setSampleBufferDelegate:self queue:queue_audio];
     */
    //
    //    [audioOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    /*
     3、AVCaptureSession(录制会话)对象的创建及属性设置(如：音频视频录制的质量SessionPreset)，并加入输入、输出设备对象
     */
    self.session = [[AVCaptureSession alloc] init];
    [self.session beginConfiguration];
    [self.session setSessionPreset:AVCaptureSessionPresetMedium];
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.videoDataOutput]) {
        [self.session addOutput:self.videoDataOutput];
    }
    
    [self.session commitConfiguration];
    
//    self.manager264 = [[X264Manager alloc]init];
//    [self.manager264 initForX264];
//    [self.manager264 initForFilePath];//先初始化保存路径，在哪里初始化自己选择
//    
//    
//    self.managerRTMP = [[RTMPManager alloc]init];
//    [self.managerRTMP initizalRTMPByUrl:""];
}











#pragma mark - ②、创建图层（预览图层、处理结果图层）
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setUpCameraLayer];
}


/*
 CALayer有2个非常重要的属性：position和anchorPoint
 @property CGPoint position;     //用来设置CALayer在父层中的位置。以父层的左上角为原点(0, 0)
 @property CGPoint anchorPoint;  //称为“定位点”、“锚点”:决定着CALayer身上的哪个点会在position属性所指的位置,以自己的左上角为原点(0, 0)。且它的x、y取值范围都是0~1，默认值为（0.5, 0.5）即未设置锚点的时候，position为指定中心位置
 简单说明
 每一个UIView内部都默认关联着一个CALayer，我们可称这个Layer为Root Layer（根层）
 所有的非Root Layer，也就是手动创建的CALayer对象，都存在着隐式动画
 
 什么是隐式动画？
 当对非Root Layer的部分属性进行修改时，默认会自动产生一些动画效果
 而这些属性称为Animatable Properties(可动画属性)
 
 列举几个常见的Animatable Properties：
 bounds：用于设置CALayer的宽度和高度。修改这个属性会产生缩放动画
 backgroundColor：用于设置CALayer的背景色。修改这个属性会产生背景色的渐变动画
 position：用于设置CALayer的位置。修改这个属性会产生平移动画
 */
- (void)setUpCameraLayer
{
    //if (_cameraAvaible == NO) return;
    
    [self setPreview:self.cameraShowView];
    [self setDstview:self.destinationShowView];
}


//4、相机“取景器”视图创建，并将其加入到要显示的viewLayer上。
//AVCaptureVideoPreviewLayerr可以用来快速呈现相机(摄像头)所收集到的原始数据，我们一般可以在定义outputdevice之前，先使用preview layer来显示一下camera buffer中的内容。也就是相机的“取景器”。
- (void)setPreview:(UIView *)preview{
    if (self.previewLayer == nil) {
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
        
        CGRect bounds = [preview bounds];
        [self.previewLayer setFrame:bounds];
        [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        
        CALayer *viewLayer = [preview layer];
        [viewLayer setMasksToBounds:YES];
        [viewLayer insertSublayer:self.previewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
    }
}


//5、若要显示实时处理后的视频效果，则需要自己创建一个layer(不能用AVCaptureVideoPreviewLayer)，并将该layer添加到view.layer上。
- (void)setDstview:(UIView *)dstview{
    if (self.destinationLayer == nil) {
        self.destinationLayer = [CALayer layer];
        UIView * view = dstview;
        
        self.destinationLayer.bounds = CGRectMake(0, 0, view.frame.size.height, view.frame.size.width);
        self.destinationLayer.position = CGPointMake(view.frame.size.width/2., view.frame.size.height/2.);
        self.destinationLayer.affineTransform = CGAffineTransformMakeRotation(M_PI/2);
        //注意：bounds的宽、高和设置的旋转，这是因为AVFoundation产出的图像是旋转了90度的，所以这里预先调整过来
        
        CALayer *viewLayer = [view layer];
        //[viewLayer setMasksToBounds:YES];
        //[viewLayer insertSublayer:self.previewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
        [viewLayer addSublayer:self.destinationLayer];
    }
}


#pragma mark - ③、启动和关闭session
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startVideoCapture:nil];
}

- (IBAction)startVideoCapture:(id)sender{
    //5、开始会话
    if (self.session) {
        [self.session startRunning];
    }
}

- (IBAction)stopVideoCapture:(id)sender{
    if (self.session) {
        [self.session stopRunning];
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    [self stopVideoCapture:nil];
}





- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}



#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate(下面例子是实时灰度效果)
//当数据缓冲区的内容(data buffer)更新的时候，AVFoundation就会马上调这个回调，在该代理方法中，我们可以获取视频帧、处理视频帧、显示视频帧。所以我们可以在这里收集视频的每一帧，经过处理之后再渲染到layer上展示给用户。
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    return;
    
    /* 开始编码：
     在采集视频的回调函数里获取图片的buffer,并在使用这个buffer的时候，开始使用时要lock，结束使用时要unlock
     */
//    [self.manager264 encoderToH264:sampleBuffer];
    
    return;
    
    //在该代理方法中，sampleBuffer是一个Core Media对象，我们可以通过CMSampleBufferGetImageBuffer方法把它转成Core Video对象。
    CVImageBufferRef imageBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer);
    
    //锁住缓冲区基地址即锁住base地址：锁住base地址是为了使缓冲区的内存地址变得可访问，否则在后面就取不到必需的数据，显示在layer上就只有黑屏，更详细的原因可以看这里：http://stackoverflow.com/questions/6468535/cvpixelbufferlockbaseaddress-why-capture-still-image-using-avfoundation
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    //然后从缓冲区中提取一些有用的图片信息：包括宽、高、每行的字节数等
    size_t width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    size_t height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    Pixel_8 *lumaBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);//视频缓冲区中是YUV格式的，要从缓冲区中提取luma部分：
    
    //然后我们将该缓冲区的数据显示(渲染)到layer上。（为此需要用Core Graphics创建一个颜色空间color space和图形上下文graphic context, 然后再通过创建的颜色空间把缓冲区的图像渲染到上下文中）
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace, kCGImageAlphaNone);
    CGImageRef dstImage = CGBitmapContextCreateImage(context);
    
    //这里dstImage就是从缓冲区中的captured buffer创建而来的一个Core Graphics图像了（CGImage），最后我们将该image在主线程中把它赋值给/渲染到layer的contents上予以显示
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.destinationLayer.contents = (__bridge id)dstImage;
    });
    
    //接下来做一些清理工作就OK了。
    CGImageRelease(dstImage);
    CGContextRelease(context);
    CGColorSpaceRelease(grayColorSpace);
    
    //这样取景器上的实时图像就显示出来了。（这里仅仅是对视频做提取与渲染，没有对视频做处理）
    //有关对imageBuffer进行处理，需要用到GPU相关知识。
}









#pragma mark - 切换前后镜头
- (IBAction)toggleCamera:(id)sender{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[_videoInput device] position];
        
        if (position == AVCaptureDevicePositionBack)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        else if (position == AVCaptureDevicePositionFront)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        else
            return;
        
        if (newVideoInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
            if ([self.session canAddInput:newVideoInput]) {
                [self.session addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            } else {
                [self.session addInput:self.videoInput];
            }
            [self.session commitConfiguration];
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}


#pragma mark 获取前后摄像头对象的方法
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    //AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}




/*
 AVCaptureMovieFileOutput其父类AVCaptureFileOutput的2个方法用于启动、停止编码输出：
 - (void)startRecordingToOutputFileURL:(NSURL *)outputFileURL recordingDelegate:(id < AVCaptureFileOutputRecordingDelegate >)delegate
 - (void)stopRecording
 不过程序开始编码输出前，我们应先启动AVCaptureSession，再用以上方法启动编码输出。
 */
/*
#pragma mark - AVCaptureFileOutputRecordingDelegate 协议
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"start record video");
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // 将临时文件夹中的视频文件复制到 照片 文件夹中，以便存取
    [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        NSLog(@"发生错误");
                                    }else{
                                        NSString *path = [assetURL path];
                                        NSLog(@"成功：path = %@, self.tempFileURL = %@", path, self.tempFileURL);
                                    }
                                }];
    [self.captureOutput stopRecording];//通过 AVCaptureFileOutput  的 stopRecording 方法停止编码。
}
 */

/*
#pragma mark - 拍照按钮的方法
- (void)shutterCamera
{
    AVCaptureConnection * videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage * image = [UIImage imageWithData:imageData];
        NSLog(@"image size = %@",NSStringFromCGSize(image.size));
    }];
}
*/




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
