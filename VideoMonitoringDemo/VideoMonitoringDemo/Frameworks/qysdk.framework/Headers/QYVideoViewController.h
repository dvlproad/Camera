//
//  QYVideoViewController.h
//  qysdk
//
//  Created by 吴怡顺 on 18/9/16.
//  Copyright © 2016年 wuyishun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYType.h"

@protocol QYVideoViewDelegate <NSObject>


@optional
//截图文件回调
-(void)onScreenShotCallBack:(int) ret
                       path:(NSString*) filePath;



//后退事件
-(void)BackView;


@end


@interface QYVideoViewController : UIViewController


@property (nonatomic,strong) id<QYVideoViewDelegate> delegatesource;

-(id)initWithQYModel:(QYVideoModel*) model;

@property(nonatomic,strong)QYChanelModel*   currentChanelInfo;

@end
