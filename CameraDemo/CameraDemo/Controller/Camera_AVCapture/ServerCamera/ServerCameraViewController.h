//
//  ServerCameraViewController.h
//  Lee
//
//  Created by lichq on 5/25/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerCameraViewController : UIViewController{
    BOOL isLive;
}
@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) IBOutlet UILabel *serverAddress;


@end
