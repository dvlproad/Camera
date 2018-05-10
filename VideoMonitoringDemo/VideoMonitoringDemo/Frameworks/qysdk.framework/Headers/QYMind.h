//
//  QYMind.h
//  qysdk
//
//  Created by 吴怡顺 on 15/11/2.
//  Copyright © 2015年 yj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QYType.h"

@interface QYMind : NSObject
-(id)initWithSession:(int) session;

/*思维盒*/
/*查询容器设备下IPC列表*/
-(void) MindGetIpcList:(long long)DeviceId
              callback:(void (^)(int32_t ret,NSMutableArray* array)) callback;



-(void) MindGetIpcList_Ext:(NSString*) serNo
                  callback:(void (^)(int32_t ret,NSMutableArray* array)) callback;

/* 摄像头绑定 */
-(void) MindIpcBind:(long long)DeviceId
            IpcInfo:(QY_IPC_INFO) info
            account:(char *) Accout
           passowrd:(char *)Password
            callback:(void (^)(int32_t ret)) callback;


-(void) MindIpcBind_Ext:(NSString*)serNo
                IpcInfo:(QY_IPC_INFO) info
                account:(char *) Accout
               passowrd:(char *)Password
               callback:(void (^)(int32_t ret)) callback;



/* 摄像头解绑 （Mode = 1：一键解绑 Mode = 0 解绑指定的ipc）支持多个ipc一同解绑*/
-(void) MindIpcUBind:(long long)DeviceId
                Mode:(int) mode
                 Num:(int)ListNum
             IpcList:(QY_IPC_INFO*) ipclist
            callback:(void (^)(int32_t ret)) callback;

-(void) MindIpcUBind_Ext:(NSString*)serNo
                    Mode:(int) mode
                     Num:(int)ListNum
                 IpcList:(QY_IPC_INFO*) ipclist
                callback:(void (^)(int32_t ret)) callback;


@end
