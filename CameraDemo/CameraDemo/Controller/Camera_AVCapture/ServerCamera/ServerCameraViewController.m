//
//  ServerCameraViewController.m
//  Lee
//
//  Created by lichq on 5/25/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import "ServerCameraViewController.h"
#import "CameraServer.h"
#import "IPAddressUtil.h"

@interface ServerCameraViewController ()

@end


@implementation ServerCameraViewController
@synthesize cameraView;
@synthesize serverAddress;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[CameraServer server] startup];
    
    
    AVCaptureVideoPreviewLayer* preview = [[CameraServer server] getPreviewLayer];
    [preview removeFromSuperlayer];
    preview.frame = self.cameraView.bounds;
    [[preview connection] setVideoOrientation:UIInterfaceOrientationPortrait];
    [self.cameraView.layer addSublayer:preview];
    
    NSString* ipaddr = [IPAddressUtil getIPAddress];
    self.serverAddress.text = [NSString stringWithFormat:@"rtsp://%@/", ipaddr];
}



- (IBAction)start_stop:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [[CameraServer server] startCapture];
        [sender setTitle:@"停止Server" forState:UIControlStateNormal];
    }else{
        [[CameraServer server] pauseCapture];
        [sender setTitle:@"启动Server" forState:UIControlStateNormal];
    }
}






- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // this is not the most beautiful animation...
    AVCaptureVideoPreviewLayer* preview = [[CameraServer server] getPreviewLayer];
    preview.frame = self.cameraView.bounds;
    [[preview connection] setVideoOrientation:toInterfaceOrientation];
}



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
