//
//  BasicCameraViewController.h
//  Lee
//
//  Created by lichq on 5/25/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Accelerate/Accelerate.h>           //为了使用Pixel_8

//#import "X264Manager.h"     //h264
//#import "RTMPManager.h"     //rtmp


//封装请参照：http://www.cocoachina.com/bbs/read.php?tid=66400



@interface BasicCameraViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>{
    
}
/*
 首先明确我们需要的有：
 ①session会话对象 AVCaptureSession：执行输入设备和输出设备之间的数据传递
 ②session会话对象会使用到的输入对象 AVCaptureDeviceInput：输入流对象
 session会话对象会使用到的输出对象 AVCaptureVideoDataOutput(或其他类型)
 ③用于显示输入对象的预览图层previewLayer(AVCaptureVideoPreviewLayer)
 用于显示输出对象的目标图层desLayer (CALayer)
 ④用于放置预览图层的 cameraShowView(UIView)
 用于放置预览图层的 dstShowView(UIView)
 */
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) IBOutlet UIView *cameraShowView;

@property (nonatomic, strong) CALayer *destinationLayer;//dstLayer
@property (nonatomic, strong) IBOutlet UIView *destinationShowView;

//@property (nonatomic, strong) X264Manager *manager264;
//@property (nonatomic, strong) RTMPManager *managerRTMP;

@end
