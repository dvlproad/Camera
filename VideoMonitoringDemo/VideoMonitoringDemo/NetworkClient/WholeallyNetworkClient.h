//
//  WholeallyNetworkClient.h
//  sdkDemo
//
//  Created by 吴怡顺 on 15/9/29.
//  Copyright © 2015年 吴怡顺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WholeallyDeviceModel.h"
#import <qysdk/QYView.h>

@interface WholeallyNetworkClient : NSObject

+ (WholeallyNetworkClient *)sharedManager;

@property(nonatomic, assign) BOOL hasLogin;

/**
 *  登录（此接口的appid和auth需要联系拾联那边的人员来获取）
 *
 *  @param appid    appid
 *  @param auth     auth
 *  @param success  登录成功的回调
 *  @param failure  登录失败的回调
 */
- (void)loginSessionByAppid:(NSString *)appid auth:(NSString *)auth success:(void (^)(void))success failure:(void (^)(void))failure;

/**
 *  获取设备列表
 *
 *  @param success    获取成功的回调
 *  @param failure    获取失败的回调
 */
- (void)getDeviceListSuccess:(void (^)(NSArray *array))success failure:(void(^)(void))failure;

/**
 *  获取指定设备上的通道列表(即获取子设备)
 *
 *  @param device_id    要获取通道的设备ID
 *  @param success      成功的回调
 *  @param failure      失败的回调
 */
- (void)getChannelListOnDeviceId:(uint64_t)device_id success:(void(^)(NSArray *ret))success failure:(void(^)(void))failure;

/**
 *  获取设备通道的缩略图
 *
 *  @param channelId    要获取缩略图的设备通道id
 *  @param imagePath    缩略图要保存的位置
 *  @param success      成功的回调函数
 *  @param failure      失败的回调函数
 */
- (void)getCaptureImageForChannelId:(uint64_t)channelId imagePath:(NSString *)imagePath success:(void (^)(void))success failure:(void (^)(void))failure;

/**
 *  获取指定通道上的设备能力
 *
 *  @param channelId    要获取缩略图的设备通道id
 *  @param success      成功的回调函数（QY_DEVICE_FUN function 包含了设备的各个能力属性）
 *  @param failure      失败的回调函数
 */
- (void)getChannelAbilityForChannelId:(uint64_t)channelId success:(void (^)(QY_DEVICE_FUN function))success failure:(void (^)(void))failure;

//查询天概要索引
//-(QY_DAYS_INDEX)getDayList:(long long) devid
//            yearData:(int) year
//           monthData:(int) month
//          cloundData:(BOOL) clound;



/**
 *  创建指定通道的视频观看视图(创建预览房间)
 *
 *  @param channelID    要观看的设备通道号
 *  @param success      成功的回调函数
 *  @param failure      失败的回调函数
 */
- (void)createChannelVideoView:(long long)channelID success:(void(^)(QYView *channelVideoView))success failure:(void(^)(void))failure;

//创建对讲房间
-(void)createTalkView:(long long) devid  callback:(void(^)(int32_t ret,QYView* view)) callback;

//创建回放房间
-(void)createReplayView:(long long) devid
                CloudStroe:(BOOL) hasColund
                  callback:(void(^)(int32_t ret,QYView* view)) callback;

@end
