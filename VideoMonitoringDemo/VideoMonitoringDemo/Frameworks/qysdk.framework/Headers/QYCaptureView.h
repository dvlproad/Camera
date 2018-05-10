//
//  QYCaptureView.h
//  qysdk
//
//  Created by 吴怡顺 on 18/5/16.
//  Copyright © 2016年 wuyishun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "QYType.h"




@protocol QYCaptureViewDelegate <NSObject>


@optional
//  断开通知
-(void)onDisConnect:(QY_DISCONNECT_REASON) reason;

//  音量回调通知
-(void)onVolumeChange:(float) voiceValue;

//  观看人数通知
-(void)onViewerChange:(int) count type:(CaptuerType)type;

//  画布显示画面通知
-(void)onAreaNotice:(QY_Rect) rect;

// 接收消息
-(void)onViewMessageRecive:(NSString*) message;

// 云存写文件 接收消息
-(void)onCloundFileName:(NSString*) filename;


// 云存写文件错误
-(void)onCloundError:(int) ErrNo;


@end


@interface QYCaptureView : NSObject


// 是否正在采集
@property(nonatomic,assign) BOOL Capture;


-(id)initWithType:(CaptuerType) type captureviewType:(CaptuerViewType) viewType;


-(BOOL) IsRuning;

-(BOOL) IsOpen;


-(void)SessionPreset:(CaptuerViewType) type;
// 播放画面速度
-(int) NetSpeed;
//设备采集页面
-(void)SetCanvas:(UIView*) canvas;
//设备消息通知
- (void)SetEventDelegate:(id<QYCaptureViewDelegate>) dele;

-(void) FullScreen;
//连接采集
-(void) startConnect:(QY_Relay_RoomInfo) info
            callBack:(void (^)(int32_t ret)) callback;

//发送消息
-(void) sendMessage:(NSString*) message
            callBack:(void (^)(int32_t ret)) callback;



-(void) openCarmera;

-(void) closeCarmera;
//打开云存写文件 返回false说明存储空间不足
-(BOOL) CloundOpened:(BOOL) open;




// 开始采集
-(void) startCaptere;
// 结束采集
- (void) stopCapture;

-(void) Relase;

@end
