//
//  QYView.h
//  qysdk
//
//  Created by yj on 15/9/25.
//  Copyright © 2015年 yj. All rights reserved.
//
#include "QYType.h"

#import <UIKit/UIKit.h>

@protocol QYViewDelegate <NSObject>


@optional
//  断开通知
-(void)onDisConnect:(QY_DISCONNECT_REASON) reason;

//  音量回调通知
-(void)onVolumeChange:(float) voiceValue;

//  回放时间通知
-(void)onReplayTimeChange:(QY_TIME) time;

//  画布显示画面通知
-(void)onVideoSizeChange:(int) width height:(int) height;

// 录像事件
-(void)onRecordStatus:(QY_RECORD_STATUS) statues;

@end


typedef enum{
    QY_YURAN,
    QY_DUIJIANG,
    QY_HUIFANG,
    QY_CAIJI
}VIEWTYPE;




@interface QYView:NSObject


-(id)initWithType:(VIEWTYPE) type
         chanelID:(uint64_t) chanelid
      withSession:(int)sessionid;

// 图像宽
-(int) GetWidth;

// 图象高
-(int) GetHeigh;

-(void) FullScreen;

// 开始启动view
- (void) StartConnectCallBack:(void (^)(int32_t ret)) callback;

-(void) SetEventDelegate:(id<QYViewDelegate>) delegate;
// 查询24小时索引
- (void) GetStoreFileIndex: (QY_DAY *) day
       callBackWithDayTime:(void (^)(int32_t ret,QYTimeIndex* time)) callback;
// 云台控制
- (void) CtrlPtz: (int)duration
          action: (enum QY_PTZ_TYPE) action
        callBack:(void (^)(int32_t ret)) callback;

// 是否播放声音
- (void) CtrlAudio:(BOOL) open;

// 控制回放0:是停止  1：播放
- (void) CtrlReplayTime: (QY_TIME) ttm
                   ctrl:(int) ctrl callBack:(void (^)(int32_t ret)) callback;

// 控制回放0:是停止  1：播放
- (void) CtrlReplayTime_Ext: (QY_TIME) ttm
                       ctrl:(int) ctrl
                      speed:(int)spd
                   callBack:(void (^)(int32_t ret)) callback;


-(void) QY_SendWords:(NSString*) words
            callBack:(void (^)(int32_t ret)) callback;

-(void) QY_SetRegion:(QY_Rect) rect
            callBack:(void (^)(int32_t ret)) callback;

// 对讲
-(void) CtrlTalk:(BOOL) talkend;
// 播放画面速度
-(int) NetSpeed;
// 截图
-(int)Capture:(NSString*) savePath;

// 设置画面
-(void)SetCanvas:(UIView*) canvas;


-(void)playLocalFile:(NSString*) floderPath;

// 关闭页面
- (void) Release;

@end

