//
//  ClientCameraViewController.m
//  Lee
//
//  Created by lichq on 5/25/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import "ClientCameraViewController.h"
#import "CameraClient.h"

@interface ClientCameraViewController ()

@end

@implementation ClientCameraViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.cameraView setAlpha:0];
    [self.btnLive setAlpha:0];
    [self.btnRecord setAlpha:0];
    
    BOOL isSupportCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (isSupportCamera == NO) {
        [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"友情提示", nil)
                                   message:NSLocalizedString(@"对不起，您的手机不支持拍照功能", nil)
                                  delegate:self
                         cancelButtonTitle:NSLocalizedString(@"好的，我知道了", nil)
                         otherButtonTitles:nil] show];
        return;
    }
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.dimBackground= YES;
    HUD.delegate = self;
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"PopupTextFieldInput" owner:self options:nil];
    PopupTextFieldInput *customView = [bundle lastObject];
    customView.tfName.text = @"test001";
    customView.delegate = self;
    HUD.customView = customView;
    
    [HUD show:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    hud = nil;
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    if (isLive) {
        [[CameraClient client] shutdown];
    }
    [self stopLive];
}

- (void)stopLive{
    
}

- (void)goOK:(PopupTextFieldInput *)popupTextFieldInput{
    if ([popupTextFieldInput.tfName.text length] == 0) {
        isLive = NO;
        [[[UIAlertView alloc]initWithTitle:@"名字不能为空" message:nil delegate:nil cancelButtonTitle:@"好的，我知道了" otherButtonTitles:nil] show];
        return;
    }
    [HUD hide:YES afterDelay:0];
    
    NSString *name = popupTextFieldInput.tfName.text;
    //Url = rtsp://117.27.157.178:3554/house/000-001_898167_house_system.641879d21650a728f54d7eb180d043ea
    NSString *rtspUrl =[NSString stringWithFormat:@"rtsp://%@:%@/%@", RTSP_HOST, RTSP_PORT, name];
    [self doLivePUT:rtspUrl];
}

- (void)doLivePUT:(NSString *)rtspUrl{
    rtspUrl = [rtspUrl substringFromIndex:[@"rtsp://" length]];
    NSArray *array = [rtspUrl componentsSeparatedByString:@"/"];
    NSArray *array2 = [array[0] componentsSeparatedByString:@":"];
    NSString *rtsp_host = array2[0];
    NSString *rtsp_port = array2[1];
    NSString *rtsp_path = @"";
    for (int i = 1; i < array.count; i++) { //从第一位开始
        rtsp_path = [rtsp_path stringByAppendingFormat:@"%@", array[i]];
    }
    [self doLivePUT_host:rtsp_host port:rtsp_port name:rtsp_path];
}

- (void)doLivePUT_host:(NSString *)host port:(NSString *)port name:(NSString *)name{
    NSLog(@"直播信息：\nhost = %@, \nport = %@, \nname = %@", host, port, name);
    BOOL isSuccess = [[CameraClient client] startupEncode:name host:RTSP_HOST port:RTSP_PORT];
    if (isSuccess == NO) {
        NSLog(@"服务器连接失败，暂时无法发布视频");
        isLive = NO;
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"服务器连接失败，暂时无法发布视频" delegate:self cancelButtonTitle:@"好的，我知道了" otherButtonTitles:nil] show];
        return;
    }
    isLive = YES;
    
    [self.cameraView setAlpha:1];
    [self.btnLive setAlpha:1];
    [self.btnRecord setAlpha:1];
    
    
    [[CameraClient client] startCapture]; //开始直播
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    AVCaptureVideoPreviewLayer* preview = [[CameraClient client] getPreviewLayer];
    [preview removeFromSuperlayer];
    preview.frame = self.cameraView.bounds;
    [[preview connection] setVideoOrientation:UIInterfaceOrientationPortrait];
    [self.cameraView.layer addSublayer:preview];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // this is not the most beautiful animation...
    AVCaptureVideoPreviewLayer* preview = [[CameraClient client] getPreviewLayer];
    preview.frame = self.cameraView.bounds;
    [[preview connection] setVideoOrientation:toInterfaceOrientation];
}


- (IBAction)start_stop_live:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [[CameraClient client] startCapture];
    }else{
        [[CameraClient client] pauseCapture];
    }
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
