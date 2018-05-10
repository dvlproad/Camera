//
//  WholeallyNetworkClient.m
//  sdkDemo
//
//  Created by 吴怡顺 on 15/9/29.
//  Copyright © 2015年 吴怡顺. All rights reserved.
//

#import "WholeallyNetworkClient.h"
#import <qysdk/QYSession.h>
#import "WholeallyDeviceModel.h"
#import <qysdk/QYView.h>
@interface WholeallyNetworkClient()<QYSessionDelegate>
{
    QYSession* session;
    QYView* talkView;
    QYView* replayView;
}
@end



@implementation WholeallyNetworkClient

+ (WholeallyNetworkClient *)sharedManager
{
    static WholeallyNetworkClient *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
        [QYSession InitSDK: QY_LOG_INFO];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


/** 完整的描述请参见文件头部 */
- (void)loginSessionByAppid:(NSString *)appid auth:(NSString *)auth success:(void (^)(void))success failure:(void (^)(void))failure {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    session = [[QYSession alloc] init];
    
    NSLog(@"start login");
    
    /* 1、设置服务器的域名或地址、以及端口号,以此来连接服务器 */
    NSString *serverIP = @"wholeally.net";
    int serverPort = 39100;
    int serverSettingResult = [session SetServer:serverIP port:serverPort];
    NSLog(@"serverSettingResult = %d", serverSettingResult);
    if (serverSettingResult < 0) { //大于等于0时表示设置成功，小于0时表示设置失败
        NSLog(@"连接服务器设置失败，不进行登录");
        return;
    }
    
    /* 2、连接服务器成功后，进行登录 */
    [session ViewerLogin:appid auth:auth callBack:^(int32_t ret) {
        if(ret == 0) {
            _hasLogin = YES;
            [session SetEventDelegate:self]; //设置设备的上下线和报警事件通知。（通过QYSession对象调用SetEventDelegate(QYSessionDelegate delegate)方法设置事件通知回调）
            
            if (success) {
                success();
            }
            
        } else {
            NSLog(@"Login failure:%d", ret);
            if (failure) {
                failure();
            }
        }
    }];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [session Release];
}

/** 完整的描述请参见文件头部 */
- (void)getDeviceListSuccess:(void (^)(NSArray *array))success failure:(void(^)(void))failure {
    [session GetDeviceListcallBackWithArray:^(int32_t ret, NSMutableArray *array) {
        if(ret == 0) {
            if (success) {
                success(array);
            }
            
        } else {
            if (failure) {
                failure();
            }
        }
    }];
}

/** 完整的描述请参见文件头部 */
- (void)getChannelListOnDeviceId:(uint64_t)device_id success:(void(^)(NSArray *ret))success failure:(void(^)(void))failure {
    [session GetChannelList:device_id callBackWithArray:^(int32_t ret, NSMutableArray *array) {
        if(ret == 0) {
            if (success) {
                success(array);
            }
            
        } else {
            if (failure) {
                failure();
            }
        }
    }];
}


/**
 *  获取指定通道上的设备能力
 *
 *  @param channelId    要获取缩略图的设备通道id
 *  @param success      成功的回调函数（QY_DEVICE_FUN function 包含了设备的各个能力属性）
 *  @param failure      失败的回调函数
 */
- (void)getChannelAbilityForChannelId:(uint64_t)channelId success:(void (^)(QY_DEVICE_FUN function))success failure:(void (^)(void))failure {
    QYSessionEX *sessionEX = [session GetSesionEx];
    [sessionEX QYChanelAbility:channelId callBack:^(int32_t ret, QY_DEVICE_FUN function) {
        if (ret >= 0) {
            if (success) {
                success(function);
            }
        } else {
            if (failure) {
                failure();
            }
        }
    }];
}


/**
 *  获取设备通道的缩略图
 *
 *  @param channelId    要获取缩略图的设备通道id
 *  @param imagePath    缩略图要保存的位置
 *  @param success      成功的回调函数
 *  @param failure      失败的回调函数
 */
- (void)getCaptureImageForChannelId:(uint64_t)channelId imagePath:(NSString *)imagePath success:(void (^)(void))success failure:(void (^)(void))failure {
    [session GetDeviceCapture:channelId savePaht:imagePath callBack:^(int32_t ret) {
        if(ret == 0) {
            if (success) {
                success();
            }
            
        } else {
            NSLog(@"获取远程截图失败");
            if (failure) {
                failure();
            }
        }
    }];
}



////查询天概要索引
//-(QY_DAYS_INDEX)getDayList:(long long) devid
//                    yearData:(int) year
//                   monthData:(int) month
//                  cloundData:(BOOL) clound
//{ss
//    QY_DAYS_INDEX searchResult={0};
//    [session GetStoreFileListDayIndex:devid
//                                 year:year
//                                month:month
//                                cloud:clound
//                            daysIndex:&searchResult];
//    
//    return searchResult;
//
//}


/** 完整的描述请参见文件头部 */
- (void)createChannelVideoView:(long long)channelID success:(void(^)(QYView *channelVideoView))success failure:(void(^)(void))failure
{
    QYView *channelVideoView = [session CreateView:channelID];
    if (channelVideoView == nil) {
        if (failure) {
            failure();
        }
        return;
    }
    
    [channelVideoView StartConnectCallBack:^(int32_t ret) {
        if(ret == 0) { //ret>=0表示创建成功，ret<0表示创建失败
            if (success) {
                success(channelVideoView);
            }
            
        } else {
            if (failure) {
                failure();
            }
        }
    }];
}

-(void)createTalkView:(long long) devid  callback:(void(^)(int32_t ret,QYView* view)) callback
{
    
    QYView* videoView= [session CreateTalkView:devid];
    [videoView StartConnectCallBack:^(int32_t ret) {
        if(ret==0)
        {
            callback(ret,videoView);
        }
        else
        {
            callback(ret,nil);
        }
    }];

}


//创建回放房间
-(void)createReplayView:(long long) devid
             CloudStroe:(BOOL) hasColund
               callback:(void(^)(int32_t ret,QYView* view)) callback
{

    QYView* videoView= [session CreateRePlayView:devid mode:hasColund];
    [videoView StartConnectCallBack:^(int32_t ret) {
        if(ret==0)
        {
            callback(ret,videoView);
        }
        else
        {
            callback(ret,nil);
        }
    }];

}
//
//-(QYView*)createTalkView:(long long) devid
//{
//    QYView* videoView= [session CreateTalkView:devid];
//    [videoView StartConnect];
//
//    return videoView;
//}
//
//
//-(QYView*)createReplayView:(long long) devid
//                CloudStroe:(BOOL) hasColund
//{
//    QYView* videoView= [session CreateRePlayView:devid mode:hasColund];
//    [videoView StartConnect];
//
//    return videoView;
//}


#pragma mark - QYSessionDelegate
///断开通知
- (void)onDisConnect:(QY_DISCONNECT_REASON)reason {
    
}

///报警通知
- (void)onAlarm:(QY_ALARM_INFO)alarm {
    
}

///设备上下线通知
- (void)onDeviceStatus:(int64_t)devid statues:(int64_t)status {
    
    
}


@end
