//
//  QYSession.h
//  qysdk
//
//  Created by yj on 15/9/23.
//  Copyright © 2015年 yj. All rights reserved.
//

#import "QYType.h"
#import "QYView.h"
#import "QYSessionEX.h"
#import "QYMind.h"




@protocol QYSessionDelegate <NSObject>


@optional

//  断开通知
-(void)onDisConnect:(QY_DISCONNECT_REASON) reason;

//  报警通知
-(void)onAlarm:(QY_ALARM_INFO) alarm;

//  设备上下线通知
-(void)onDeviceStatus:(int64_t) devid
              statues:(int64_t) status;

@end



@interface QYSession : NSObject

 // 库的初始化
+ (void) InitSDK: (enum QY_LOG_LEVEL)level;


// 库的释放
+ (void) UninitSDK;

// 构造，申请资源
- (id) init;


// 析构释放资源
- (void) Release;

// 获取session扩展
-(QYSessionEX*) GetSesionEx;

// 获取思维盒 扩展
-(QYMind*) GetMind;

-(void) SetEventDelegate:(id<QYSessionDelegate>) delegate;


// 设置代理服务器ip
- (void) SetProxy: (NSString *) ip port: (int) port;



// 设置服务器ip
- (int) SetServer: (NSString *) ip port: (int) port;


// 观看者登录
- (void) ViewerLogin:(NSString* )appid
                auth:(NSString*) auth
            callBack:(void (^)(int32_t ret)) callback;



// 权限管理
- (void) GetViewerAuth:(NSString* ) type
            callBack:(void (^)(int ret,QYUserAuthList *auth)) callback;


// 获取设备列表, 返回 QY_DEVICE_INFO 列表
- (void) GetDeviceListcallBackWithArray:(void (^)(int32_t ret,NSMutableArray* array)) callback
;

// 获取通道列表, 返回 QY_CAHNNEL_INFO 列表
- (void) GetChannelList:(uint64_t)devID callBackWithArray:(void (^)(int32_t ret,NSMutableArray* array)) callback;

- (void) GetChannelList_Ext:(NSString*)serNo chanel:(int)chanelid callBackWithArray:(void (^)(int32_t ret,NSMutableArray* array)) callback;

// 远程截图
- (void)GetDeviceCapture:(uint64_t)chanelId savePaht:(NSString*) path callBack:(void (^)(int32_t ret)) callback;

// 远程截图
- (void)GetDeviceCapture_Ext:(NSString*)serNo chanel:(int)chnno savePaht:(NSString*) path callBack:(void (^)(int32_t ret)) callback;


// 获取全部报警信息, 返回 QY_ALARMLIST 列表
// pageIndex 从1开始
- (void)GetAlarmList:(uint64_t)channelID device:(uint64_t)deviceid pageSize:(int)ps pageIndex:(int)pi callBackWithArray:(void (^)(int32_t ret,NSMutableArray* array)) callback;

// 查询云台状态, 返回 QY_PTZ_STATUS 列表
- (void) GetChanelPTZConfig:(uint64_t)channelID callBackWithPTZStatus:(void (^)(int32_t ret,QY_PTZ_STATUS ptzStatus)) callback;

- (void) GetChanelPTZConfig_Ext:(NSString*)serNo chanel:(int)chnno callBackWithPTZStatus:(void (^)(int32_t ret,QY_PTZ_STATUS ptzStatus)) callback;

// 查询通道报警配置
- (void) GetAlarmConfig:(uint64_t)channelID type:(QY_ALARM_TYPE)type callBackWithAlarmConfig:(void (^)(int32_t ret,QY_ALARM_CONFIG config)) callback;

// 设置通道报警配置
- (void) SetAlarmConfig:(uint64_t)channelID type:(QY_ALARM_TYPE)type config:(QY_ALARM_CONFIG *)config callBack:(void (^)(int32_t ret)) callback;
// 设置通道报警配置
- (void) SetAlarmConfig_Ext:(NSString*) serNo chanel:(int)chnno type:(QY_ALARM_TYPE)type config:(QY_ALARM_CONFIG *)config callBack:(void (^)(int32_t ret)) callback;
//// 获取通道录像配置
//- (void) GetChanelRecordConfig:(uint64_t)channelID callBackWithRecordConfig:(void (^)(int32_t ret,QY_RECORD_CONFIG config)) callback;
// 设置通道录像配置
- (void) SetChannelRecordConfig:(uint64_t)channelID
                         config:(QY_RECORD_CONFIG)config
                       callBack:(void (^)(int32_t ret)) callback;
// 查询天概要索引，cloud是否从云存取
- (void) GetStoreFileListDayIndex:(uint64_t)channelID year:(int)year month:(int)month cloud:(int)cloud callBackWithDayIndex:(void (^)(int32_t ret,QY_DAYS_INDEX config)) callback;

//// 获取天概要索引
- (void) GetStoreFileListDayIndex_Ext:(NSString*)serNo chanelNo:(uint32_t) chanel year:(int)year month:(int)month cloud:(int)cloud callBackWithDayIndex:(void (^)(int32_t ret,QY_DAYS_INDEX config)) callback;


// 获取画质
-(void) GetVideoQuality:(uint64_t) chno
               callBack:(void (^)(int32_t ret,enum QY_VIDEO_QUALITY action,NSArray* list)) callback;

-(void) GetVideoQuality_Ext:(NSString*) serNo
                       :(int) chnno
                   callBack:(void (^)(int32_t ret,enum QY_VIDEO_QUALITY action,NSArray* list)) callback;

// 设置画质
-(void) SetVideoQuality:(enum QY_VIDEO_QUALITY)action
               ChanelNO:(uint64_t) chno
               callBack:(void (^)(int32_t ret)) callback;


// 设置翻转
-(void) SetVideoOrientation:(uint64_t) channelID
                       Mode:(int) mode
                   callBack:(void (^)(int32_t ret)) callback;

// 设置翻转
-(void) SetVideoOrientation_ext:(NSString*) serNo
                         chanel:(int) chnno
                           Mode:(int) mode
                       callBack:(void (^)(int32_t ret)) callback;
// 创建视频观看类
- (QYView *) CreateView: (uint64_t)channelID;

// 创建视频回放类 mode为回放类型 0：设备端 1：云存
- (QYView *) CreateRePlayView: (uint64_t)channelID mode: (int) mode;

// 创建语音对讲类
- (QYView *) CreateTalkView: (uint64_t)channelID;

@end

