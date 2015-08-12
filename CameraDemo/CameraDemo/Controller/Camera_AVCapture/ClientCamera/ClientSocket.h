//
//  ClientSocket.h
//  Lee
//
//  Created by lichq on 5/27/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

//摘自：	iOS学习之Socket使用简明教程－ AsyncSocket http://my.oschina.net/joanfen/blog/287238

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t onceToken = 0; \
__strong static id sharedInstance = nil; \
dispatch_once(&onceToken, ^{ \
sharedInstance = block(); \
}); \
return sharedInstance; \


enum{
    SocketOfflineByServer,// 服务器掉线，默认为0
    SocketOfflineByUser,  // 用户主动cut
};


@interface ClientSocket : NSObject<AsyncSocketDelegate>{
    
}
@property (nonatomic, strong) AsyncSocket    *socket;       // socket
@property (nonatomic, copy  ) NSString       *socketHost;   // socket的Host
@property (nonatomic, assign) UInt16         socketPort;    // socket的prot

@property (nonatomic, retain) NSTimer        *connectTimer; // 计时器


+ (ClientSocket *)sharedInstance;
- (void)socketConnectHost;// socket连接
- (void)cutOffSocket; // 断开socket连接

@end
