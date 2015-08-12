//
//  ClientCameraViewController.h
//  Lee
//
//  Created by lichq on 5/25/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncSocket.h>
#import <CFNetwork/CFNetwork.h>

#import <MBProgressHUD.h>
#import "PopupTextFieldInput.h"

@interface ClientCameraViewController : UIViewController<MBProgressHUDDelegate, PopupTextFieldInputDelegate, UIAlertViewDelegate>{
    MBProgressHUD *HUD;
    BOOL isLive;
}
@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIButton *btnLive;
@property (weak, nonatomic) IBOutlet UIButton *btnRecord;

@end
