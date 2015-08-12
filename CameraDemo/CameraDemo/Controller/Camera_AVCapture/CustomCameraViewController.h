//
//  CustomCameraViewController.h
//  Lee
//
//  Created by lichq on 5/25/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicCameraViewController.h"
#import "ServerCameraViewController.h"
#import "ClientCameraViewController.h"

@interface CustomCameraViewController : UIViewController<UITabBarDelegate>{
    
}
@property (nonatomic, strong) IBOutlet UIView *showView;
@property (nonatomic, strong) IBOutlet UITabBar *tabBar;

@end
