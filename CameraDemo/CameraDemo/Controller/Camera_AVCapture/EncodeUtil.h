//
//  EncodeUtil.h
//  Lee
//
//  Created by lichq on 5/26/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//


#import <UIKit/UIKit.h>

enum ClientState
{
    Client_Idle, //闲置
    Client_SetupOK,
    Client_SetupOK_Video,
    Client_SetupOK_Audio,
    Client_RecordOK,//Client_RTSPOK
};


enum ServerState
{
    ServerIdle,
    Setup,
    Playing,
};





static const char* Base64Mapping = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const int max_packet_size = 1200;


NSString* encodeToBase64(NSData* data);

#import <Foundation/Foundation.h>

@interface EncodeUtil : NSObject

void tonet_short(uint8_t* p, unsigned short s);
void tonet_long(uint8_t* p, unsigned long l);


@end
