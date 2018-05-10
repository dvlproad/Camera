//
//  QYCapture.h
//  qysdk
//
//  Created by 吴怡顺 on 16/5/16.
//  Copyright © 2016年 wuyishun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QYType.h"


@protocol QYCaptureDelegate <NSObject>


@optional

//  断开通知
-(void)onConnectMessage:(QY_Relay_RoomInfo) roominfo;




@end




@interface QYCapture : NSObject



// 库的初始化
+ (void) InitSDK: (enum QY_LOG_LEVEL)level;


/**
 * 设备服务器
 */
- (int) SetServer: (NSString *) ip port: (int) port;

- (void)SetEventDelegate:(id<QYCaptureDelegate>) dele;

//查询设备绑定状态
-(void) ChanelStateRequest:(NSString*)uniqueId
                  callBack:(void (^)(int32_t ret,NSDictionary* dictionary)) callback;

//停止上传
-(void) CloundUploadStop;

//登陆云存平台 
-(void) LoginClound:(NSString*) userName
           Password:(NSString*) pwd
           ChanelId:(int64_t)   id1;

//获取未上传文件大小
-(long long) CloundUploadFileSize;


//获取用户信息
-(void) RequestUserInfo:(NSString* )uniqueId
               callBack:(void (^)(int32_t ret,NSDictionary* devid)) callback;
//添加设备
-(void) BindingDevice:(NSString* )uniqueId
          useName:(NSString* )name
         passWord:(NSString*) pwd
         callBack:(void (^)(int32_t ret,NSDictionary* dictionary)) callback;



//解除绑定
-(void) UnBindingDevice:(NSString* )uniqueId
                useName:(NSString* )name
               passWord:(NSString*) pwd
               callBack:(void (^)(int32_t ret,NSDictionary* dictionary)) callback;

//联接设备端添加
- (void) LoginDevice:(NSString* )uniqueId
            callBack:(void (^)(int32_t ret,long long devid)) callback;




//报告设备上下线
- (void) ChaneReport:(long long)chanelid
              statue:(int)statue
            callBack:(void (^)(int32_t ret)) callback;
//采集设备是否云存
-(void) RecordVedio:(int64_t) chanelNo
         recodeType:(CP_RecordType) type
          openState:(BOOL) open
           callBack:(void (^)(int32_t ret)) callback;



-(void) Relase;


@end
