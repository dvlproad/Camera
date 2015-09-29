//
//  CameraServer.h
//  Lee
//
//  Created by lichq on 5/26/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

//来源：Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AVFoundation/AVCaptureSession.h"
#import "AVFoundation/AVCaptureOutput.h"
#import "AVFoundation/AVCaptureDevice.h"
#import "AVFoundation/AVCaptureInput.h"
#import "AVFoundation/AVCaptureVideoPreviewLayer.h"
#import "AVFoundation/AVMediaFormat.h"

@interface CameraServer : NSObject

+ (CameraServer*) server;
- (BOOL)startupEncode;
- (void)shutdown;
- (AVCaptureVideoPreviewLayer*) getPreviewLayer;

- (void)startCapture;
- (void)pauseCapture;

@end
