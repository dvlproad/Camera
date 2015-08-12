//
//  CameraClient.h
//  Lee
//
//  Created by lichq on 5/25/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AVFoundation/AVCaptureSession.h"
#import "AVFoundation/AVCaptureOutput.h"
#import "AVFoundation/AVCaptureDevice.h"
#import "AVFoundation/AVCaptureInput.h"
#import "AVFoundation/AVCaptureVideoPreviewLayer.h"
#import "AVFoundation/AVMediaFormat.h"

@interface CameraClient : NSObject

+ (CameraClient *)client;
- (BOOL)startupEncode:(NSString *)name host:(NSString *)host port:(NSString *)port;
- (void)shutdown;
- (AVCaptureVideoPreviewLayer *)getPreviewLayer;

- (void)startCapture;
- (void)pauseCapture;

@end
