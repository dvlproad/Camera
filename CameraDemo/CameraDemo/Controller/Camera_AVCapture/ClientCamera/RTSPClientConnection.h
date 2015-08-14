//
//  RTSPClientConnection.h
//  Lee
//
//  Created by lichq on 5/25/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AsyncSocket.h>

enum CSeqNumber{
    CSeq_OPTIONS = 1,
    CSeq_ANNOUNCE,
    CSeq_SETUP_VIDEO,
    CSeq_SETUP_AUDIO,
    CSeq_RECORD
};

@interface RTSPClientConnection : NSObject{
    //    char buffer[1024];
    int sendCount;
    NSString *rtsp_host;
    NSString *rtsp_port;
    NSString *rtsp_path;
    
    AsyncSocket *asyncSocket;
}
@property(nonatomic, assign) BOOL isInitSuccess;
@property (readwrite, atomic) int bitrate;//add by lichq

//+ (RTSPClientConnection*) createWithSocket:(CFSocketNativeHandle) s server:(RTSPServer*) server;
+ (RTSPClientConnection*)setupListener:(NSData*)configData name:(NSString *)name host:(NSString *)host port:(NSString *)port;

- (void)onVideoData:(NSArray*)data time:(double)pts;
- (void)onAudioData:(NSData*)data time:(double)pts; //lichq
- (void)shutdown;


@end
