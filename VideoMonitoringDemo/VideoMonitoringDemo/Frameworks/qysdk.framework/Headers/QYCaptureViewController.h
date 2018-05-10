//
//  QYCaptureViewController.h
//  VideoComponentDemo
//
//  Created by 吴怡顺 on 29/9/16.
//  Copyright © 2016年 wuyishun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYType.h"



@protocol QYCaptureVCDelegate <NSObject>


@optional
//后退事件
-(void)CaptureBackView;


@end



@interface QYCaptureViewController : UIViewController


- (id) initWithModel:(QYCaptureModel *)model ;


@property (nonatomic,strong) id<QYCaptureVCDelegate> delegatesource;

@property(nonatomic,weak)IBOutlet UIButton* backBtn;

@property(nonatomic,weak)IBOutlet UIButton* moreBtn;
@property(nonatomic,weak)IBOutlet UIButton* cifBtn;
@property(nonatomic,weak)IBOutlet UIButton* dBtn;
@property(nonatomic,weak)IBOutlet UILabel*  titleLB;
@property(nonatomic,weak)IBOutlet UILabel*  deviceLB;
@property(nonatomic,weak)IBOutlet UILabel*  userNameLB;
@property(nonatomic,weak)IBOutlet UILabel*  speedLab;
@property(nonatomic,weak)IBOutlet UIView*   moreView;
@property(nonatomic,weak)IBOutlet UIView*   headView;
@property(nonatomic,weak)IBOutlet UIView*   messageView;
@property(nonatomic,weak)IBOutlet UILabel*   messageLB;
@property(nonatomic,weak)IBOutlet UIImageView*   messagetipImg;
@property(nonatomic,weak)IBOutlet UIButton*   downMessageBtn;


@end
