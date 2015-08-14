//
//  RTSPClientConnection.m
//  Lee
//
//  Created by lichq on 5/25/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import "RTSPClientConnection.h"

#import "RTSPMessage.h"
#import "NALUnit.h"
#import "arpa/inet.h"


//rtsp://192.168.18.203:3555/live/test001

#define Video_Code  96
#define Audio_Code  97

#define Video_trackID   0
#define Audio_trackID   1

#import "EncodeUtil.h"

@interface RTSPClientConnection ()
{
    CFSocketRef _s;
    //    RTSPServer* _server;
    CFRunLoopSourceRef _rls;

//    CFDataRef _addrRTP;
//    CFSocketRef _sRTP;
//    CFDataRef _addrRTCP;
//    CFSocketRef _sRTCP;
//    NSString* _session;
    ClientState _state;//客户端状态
    long _packets;
    long _bytesSent;
    long _ssrc;
    BOOL _bFirst;
    
    //time mapping using NTP
    uint64_t _ntpBase;
    uint64_t _rtpBase;
    double _ptsBase;
    
    // RTCP stats
    long _packetsReported;
    long _bytesReported;
    NSDate* _sentRTCP;
    
    // reader reports
//    CFSocketRef _recvRTCP;
//    CFRunLoopSourceRef _rlsRTCP;
    
    
    
    //add by lichq
    NSData* _configData;
    int _bitrate;
    //add audio
    long _packets_audio;
    long _bytesSent_audio;
    long _ssrc_audio;
    BOOL _bFirst_audio;
    
    // time mapping using NTP
    uint64_t _ntpBase_audio;
    uint64_t _rtpBase_audio;
    double _ptsBase_audio;
    
    // RTCP stats
    long _packetsReported_audio;
    long _bytesReported_audio;
    NSDate* _sentRTCP_audio;
    
}

//- (RTSPClientConnection*) initWithSocket:(CFSocketNativeHandle) s Server:(RTSPServer*) server;
- (RTSPClientConnection*) init:(NSData*) configData;
- (void) onRTCP:(CFDataRef) data;


- (void)readStream ;//add by lichq

@end

static void onSocket (
                      CFSocketRef s,
                      CFSocketCallBackType callbackType,
                      CFDataRef address,
                      const void *data,
                      void *info
                      )
{
    RTSPClientConnection* conn = (__bridge RTSPClientConnection*)info;
    switch (callbackType)
    {
        case kCFSocketDataCallBack:
            NSLog(@"....DataCallBack");
            [conn performSelectorInBackground:@selector(readStream) withObject:nil];
            break;
        case kCFSocketConnectCallBack:
            NSLog(@"....ConnectCallBack");
            if (data != NULL) {
                NSLog(@"连接失败");
                return;
            }
            [conn performSelectorInBackground:@selector(readStream) withObject:nil];
            break;
        case kCFSocketReadCallBack:
            NSLog(@"Read...CallBack");
            break;
        case kCFSocketWriteCallBack:
            //            NSLog(@"Write...CallBack");
            //            [conn readStream];
            //            [conn performSelectorInBackground:@selector(readStream) withObject:nil];
            break;
        default:
            NSLog(@"unexpected socket event");
            break;
    }
    
}

static void onRTCP(CFSocketRef s,
                   CFSocketCallBackType callbackType,
                   CFDataRef address,
                   const void *data,
                   void *info
                   )
{
    RTSPClientConnection* conn = (__bridge RTSPClientConnection*)info;
    switch (callbackType)
    {
        case kCFSocketDataCallBack:
            [conn onRTCP:(CFDataRef) data];
            break;
            
        default:
            NSLog(@"unexpected socket event");
            break;
    }
}


@implementation RTSPClientConnection
@synthesize isInitSuccess;
@synthesize bitrate = _bitrate;//add by lichq

//+ (RTSPClientConnection*) createWithSocket:(CFSocketNativeHandle) s server:(RTSPServer*) server
//{
//    RTSPClientConnection* conn = [RTSPClientConnection alloc];
//    if ([conn initWithSocket:s Server:server] != nil)
//    {
//        return conn;
//    }
//    return nil;
//}


+ (RTSPClientConnection*)setupListener:(NSData*)configData name:(NSString *)name host:(NSString *)host port:(NSString *)port
{
    RTSPClientConnection *obj = [[RTSPClientConnection alloc]init:configData name:name host:host port:port];
    return obj;
}


- (RTSPClientConnection*)init:(NSData*)configData name:(NSString *)name host:(NSString *)host port:(NSString *)port
{
    _configData = configData;
    sendCount = 0;
    rtsp_host = host; //@"192.168.18.203"
    rtsp_port = port; //@"5554"
    rtsp_path = name;   //@"test001"//@"live/test001"
    
    _state = Client_Idle;
    
    CFSocketContext info;
    memset(&info, 0, sizeof(info));
    info.info = (void*)CFBridgingRetain(self);
    //    CFSocketContext info = {0, &self, NULL, NULL, NULL};
    
    //    _s = CFSocketCreateWithNative(nil, s, kCFSocketDataCallBack, onSocket, &info);
    _s = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketWriteCallBack, onSocket, &info);
    struct sockaddr_in addr;
    
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    
    addr.sin_addr.s_addr = inet_addr([rtsp_host UTF8String]);
    
    addr.sin_family = AF_INET;
    addr.sin_port = htons([rtsp_port intValue]);
    CFDataRef dataAddr = CFDataCreate(kCFAllocatorDefault, (const uint8_t*)&addr, sizeof(addr));
    CFSocketError e = CFSocketConnectToAddress(_s, dataAddr, 2);
    CFRelease(dataAddr);
    if (e != kCFSocketSuccess){
        NSLog(@"connect error %d", (int) e);
        return nil;
    }
    NSLog(@"connect success");
    
    
    _rls = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _s, 0);
    CFRunLoopAddSource(CFRunLoopGetMain(), _rls, kCFRunLoopCommonModes);
    CFRelease(_rls);
    
    /* //TODO网络连接使用AsyncSocket，参考http://bbs.9ria.com/thread-235907-1-1.html
    asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
    BOOL isSuccess = [asyncSocket connectToHost:host onPort:[port intValue] error:nil];
    if (isSuccess){
        NSLog(@"connect error %d", (int) e);
        return nil;
    }
    NSLog(@"connect success");
    */
    
    [self send_OPTIONS];
    [self readStream];
    
    return self;
}



#pragma mark - 3、接收、发送数据
/////////////////////监听来自服务器的信息///////////////////
- (void)readStream {
    //    NSLog(@"准备接收》。。。。");
    
    char buffer[1024] = {0};
    //    char buffer[1024];
    //    memset(buffer, 0, sizeof(buffer));
    //    bzero(buffer, sizeof(buffer));
    /*
     在C语言编程中，当我们声明一个字符串数组的时候，常常需要把它初始化为空串。总结起来有以下三种方式：
     (1) char str[10]="";
     (2) char str[10]={'/0'};
     (3) char str[10]; str[0]='/0';
     第(1)(2)种方式是将str数组的所有元素都初始化为'/0'，而第(3)种方式是只将str数组的第一个元素初始化为'/0'。如果数组的size非常大，那么前两种方式将会造成很大的开销。所以，除非必要（即我们需要将str数组的所有元素都初始化为0的情况），我们都应该选用第(3)种方式来初始化字符串数组。
     */
    if (!_s) {
        NSLog(@"socket error");
    }
    
    /*
     while (recv(CFSocketGetNative(_s),  buffer, sizeof(buffer), 0)) {
     NSLog(@"接收到：%@", [NSString stringWithUTF8String:buffer]);
     }
     */
    
    
    
    
    int res = recv(CFSocketGetNative(_s),  buffer, sizeof(buffer), 0);
    NSString *bufferString = [NSString stringWithUTF8String:buffer];
//    NSLog(@"接收到 res = %d: %@, %s", res, bufferString, buffer);
    
    
    if (bufferString.length == 0) {
        NSLog(@"error: bufferString.length == 0");
        return;
    }
    
    RTSPMessage* msg = [RTSPMessage createWithString:bufferString];
    if (msg != nil)
    {
        int CSeq_res = msg.sequence;
        if (CSeq_res == CSeq_OPTIONS) {
            [self send_ANNOUNCE];
            [self readStream];
        }else if (CSeq_res == CSeq_ANNOUNCE) {
            [self send_SETUP_Video:@"null"];
            [self readStream];
        }else if (CSeq_res == CSeq_SETUP_VIDEO){
            [self initParams_Video];
            
            [self send_SETUP_Audio:msg.session];
            [self readStream];
        }else if (CSeq_res == CSeq_SETUP_AUDIO){
            [self initParams_Audido];
            
            [self send_RECORD:msg.session];
            [self readStream];
        }else if (CSeq_res == CSeq_RECORD){
            _state = Client_RecordOK;
        }
    }
}

/////////////////////////发送信息给服务器////////////////////////
- (void)sendMessage:(NSString *)stringTosend{
    NSLog(@"开始发送:%@", stringTosend);
    
    NSData* dataResponse = [stringTosend dataUsingEncoding:NSUTF8StringEncoding];
    CFSocketError e = CFSocketSendData(_s, NULL, (__bridge CFDataRef)(dataResponse), 2);
    if (e)
    {
        NSLog(@"发送失败：send %ld", e);
    }else{
        NSLog(@"发送成功");
    }
    
}


- (void)sendUINT8_T:(uint8_t *)new_packet length:(size_t)length{
    //    NSLog(@"开始发送UINT8_T");
    //     const char *packet2 = (const char *)new_packet;
    //     NSString *string = [NSString stringWithCString:packet2 encoding:NSUTF8StringEncoding];
    //NSString *string2 = [NSString stringWithFormat:@"%s", new_packet];
    //     [self sendMessage:string];
    //     return;
    
    
    Byte *tempData = (Byte *)malloc(length);
    NSData *data = [NSData dataWithBytes:new_packet length:length];
    //    NSLog(@"data = %@", data);
    CFSocketError e = CFSocketSendData(_s, NULL, (__bridge CFDataRef)(data), 2);
    
    
    //    CFDataRef address =CFDataCreate(kCFAllocatorDefault, (UInt8 *)& addr4,  (addr4));//发送data的另一种过方式
    
    if (e)
    {
        NSLog(@"发送失败：send %ld", e);
    }
}



- (void)send_OPTIONS{
    NSString *request = [NSString stringWithFormat:@"OPTIONS rtsp://%@:%@/%@ RTSP/1.0\r\nCseq: %d\r\n\r\n", rtsp_host, rtsp_port, rtsp_path, CSeq_OPTIONS];
    [self sendMessage:request];
}


- (void)send_ANNOUNCE{
    NSString *request = [NSString stringWithFormat:@"ANNOUNCE rtsp://%@:%@ RTSP/1.0\r\nCseq: %d\r\n",rtsp_host, rtsp_port, CSeq_ANNOUNCE];
    //request = [request stringByAppendingString:[NSString stringWithFormat:@"Date: %@", [NSDate date]]];
    //request = [request stringByAppendingString:[NSString stringWithFormat:@"Session: %@", [NSDate date]]];
    
    NSString *Content_Type = @"Content-Type: application/sdp\r\n\r\n";
    
    
    
    NSString *sdp = [NSString stringWithFormat:@"%@\r\n", [self makeSDP_My:_configData]];
    
    NSString *Content_Length = [NSString stringWithFormat:@"Content-Length: %d\r\n", sdp.length];
    request = [request stringByAppendingString:Content_Length];
    request = [request stringByAppendingString:Content_Type];
    request = [request stringByAppendingString:sdp];
    request = [request stringByAppendingString:@"\r\n"];
    
    [self sendMessage:request];
}

- (void)send_SETUP_Video:(NSString *)session{
    NSString *request = [NSString stringWithFormat:@"SETUP rtsp://%@:%@/trackID=%d RTSP/1.0\r\nCseq: %d\r\n", rtsp_host, rtsp_port, Video_trackID, CSeq_SETUP_VIDEO];//这里设置的通道下面要用到
    request = [request stringByAppendingString:[NSString stringWithFormat:@"Transport: RTP/AVP/TCP;unicast;interleaved=0-1;mode=record\r\n"]];//这里设置的0-1，下面发送rtp和rtcp的时候要用到
    request = [request stringByAppendingString:[NSString stringWithFormat:@"Content-Length: 0\r\n"]];
    request = [request stringByAppendingString:[NSString stringWithFormat:@"Session: %@\r\n", session]];
    
    request = [request stringByAppendingString:@"\r\n"];
    [self sendMessage:request];
}

- (void)send_SETUP_Audio:(NSString *)session{
    NSString *request = [NSString stringWithFormat:@"SETUP rtsp://%@:%@/trackID=%d RTSP/1.0\r\nCseq: %d\r\n", rtsp_host, rtsp_port, Audio_trackID, CSeq_SETUP_AUDIO];
    request = [request stringByAppendingString:[NSString stringWithFormat:@"Transport: RTP/AVP/TCP;unicast;interleaved=2-3;mode=record\r\n"]];//修改成2-3
    request = [request stringByAppendingString:[NSString stringWithFormat:@"Content-Length: 0\r\n"]];
    request = [request stringByAppendingString:[NSString stringWithFormat:@"Session: %@\r\n", session]];
    
    request = [request stringByAppendingString:@"\r\n"];
    [self sendMessage:request];
}



- (void)send_RECORD:(NSString *)session{
    NSString *request = [NSString stringWithFormat:@"RECORD rtsp://%@:%@ RTSP/1.0\r\nCseq: %d\r\n", rtsp_host, rtsp_port, CSeq_RECORD];
    request = [request stringByAppendingString:[NSString stringWithFormat:@"Range: npt=0.000-\r\n"]];
    request = [request stringByAppendingString:[NSString stringWithFormat:@"Content-Length: 0\r\n"]];
    request = [request stringByAppendingString:[NSString stringWithFormat:@"Session: %@\r\n", session]];
    
    request = [request stringByAppendingString:@"\r\n"];
    [self sendMessage:request];
}



- (NSString*)makeSDP_My:(NSData *)config{
    avcCHeader avcC((const BYTE*)[config bytes], (int)[config length]);
    SeqParamSet seqParams;
    seqParams.Parse(avcC.sps());
    
    NSString* profile_level_id = [NSString stringWithFormat:@"%02x%02x%02x", seqParams.Profile(), seqParams.Compat(), seqParams.Level()];
    
    NSData* data = [NSData dataWithBytes:avcC.sps()->Start() length:avcC.sps()->Length()];
    NSString* sps = encodeToBase64(data);
    data = [NSData dataWithBytes:avcC.pps()->Start() length:avcC.pps()->Length()];
    NSString* pps = encodeToBase64(data);
    
    // !! o=, s=, u=, c=, b=? control for track?
    unsigned long verid = random();
    verid = 0;
    
    //本地地址
    CFDataRef dlocaladdr = CFSocketCopyAddress(_s);
    struct sockaddr_in* localaddr = (struct sockaddr_in*) CFDataGetBytePtr(dlocaladdr);
    char *sLocaladdr = inet_ntoa(localaddr->sin_addr);//一般直接写"127.0.0.1"，而不用像上面那样去获取
    //NSLog(@"........%s", sLocaladdr);
    
    //    NSString* sdp = [NSString stringWithFormat:@"v=0\r\no=- %ld %ld IN IP4 %s\r\ns=Live stream from iOS\r\nc=IN IP4 0.0.0.0\r\nt=0 0\r\na=control:*\r\n", verid, verid, inet_ntoa(localaddr->sin_addr)];
    NSString* sdp = [NSString stringWithFormat:@"v=0\r\no=- %ld %ld IN IP4 %s\r\n", verid, verid, sLocaladdr];//修改本地地址
    sdp = [sdp stringByAppendingFormat:@"s=%@\r\nc=IN IP4 %@\r\nt=0 0\r\n", rtsp_path, rtsp_host];  //修改网络地址
    sdp = [sdp stringByAppendingFormat:@"a=recvonly\r\na=control:*\r\na=range:npt=now-"];
    CFRelease(dlocaladdr);
    
    
    //video
    sdp = [sdp stringByAppendingString:@"\r\n"];
    sdp = [sdp stringByAppendingFormat:@"m=video 0 RTP/AVP %d\r\n", Video_Code];
    sdp = [sdp stringByAppendingFormat:@"a=rtpmap:%d H264/90000\r\n", Video_Code];
    sdp = [sdp stringByAppendingFormat:@"a=fmtp:%d packetization-mode=1;profile-level-id=%@;sprop-parameter-sets=%@,%@;\r\n", Video_Code, profile_level_id, sps, pps];
    sdp = [sdp stringByAppendingFormat:@"a=control:trackID=%d", Video_trackID];
    
    
    //audio
    sdp = [sdp stringByAppendingString:@"\r\n"];
    sdp = [sdp stringByAppendingFormat:@"m=audio 5004 RTP/AVP %d\r\n", Audio_Code];
    sdp = [sdp stringByAppendingFormat:@"a=rtpmap:%d mpeg4-generic/44100\r\n", Audio_Code];
    sdp = [sdp stringByAppendingFormat:@"a=fmtp:%d streamtype=5; profile-level-id=15; mode=AAC-hbr; config=1208; SizeLength=13; IndexLength=3; IndexDeltaLength=3;\r\n", Audio_Code];//1208
    sdp = [sdp stringByAppendingFormat:@"a=control:trackID=%d", Audio_trackID];
    
    
    
    return sdp;
}


- (void)initParams_Video
{
    // !! most basic possible for initial testing
    @synchronized(self)
    {
        // flag that setup is valid
        _state = Client_SetupOK_Video;
        _ssrc = random();
        _packets = 0;
        _bytesSent = 0;
        _rtpBase = 0;
        
        _sentRTCP = nil;
        _packetsReported = 0;
        _bytesReported = 0;
    }
}


- (void)initParams_Audido
{
    // !! most basic possible for initial testing
    @synchronized(self)
    {
        // flag that setup is valid
        _state = Client_SetupOK_Audio;
        _ssrc_audio = random();
        _packets_audio = 0;
        _bytesSent_audio = 0;
        _rtpBase_audio = 0;
        
        _sentRTCP_audio = nil;
        _packetsReported_audio = 0;
        _bytesReported_audio = 0;
    }
}


- (void)onAudioData:(NSData*)data time:(double)pts
{
    
    @synchronized(self)
    {
        if (_state != Client_RecordOK)
        {
            NSLog(@"_state != Client_RecordOK");
            return;
        }
    }
    //NSLog(@"开始准备发送声音了...");
    
    const int rtp_header_size = 12;
    const int max_single_packet = max_packet_size - rtp_header_size;
    const int max_fragment_packet = max_single_packet - 4;//4
    unsigned char packet[max_packet_size]  = {0};
    //bzero(packet, sizeof(packet));
    
    
    int cBytes = (int)[data length];
    const unsigned char* pSource = (unsigned char*)[data bytes];
    BOOL bStart = NO;            //lichq
    
    if ((pSource[0] & 0xff) != 0xff && (pSource[1] & 0xf0) != 0xf0) {
        NSLog(@"error : no fff");//_bFirst_audio无用
        return;
    }
    
    
    int frameLength = 0;
    const unsigned char *header = pSource;
    frameLength = (header[3]&0x03) << 11 |
				(header[4]&0xFF) << 3 |
				(header[5]&0xE0) >> 5 ;
    
    int protection = (header[1]&0x01)>0 ? true : false;
    int num = protection ? 7 : 9;
    frameLength -= num;
    //NSLog(@"frameLength = %d, cByte = %d", frameLength, cBytes);
    
    //int profile = ( (header[2]&0xC0) >> 6 ) + 1 ;
    //NSLog(@"profile = %d", profile); 这里profile = 2;
    
    pSource += 7;
    cBytes -= 7;
    
    
    if (cBytes < max_fragment_packet)//max_single_packet
    {
        [self writeHeader_Audio:packet marker:bStart time:pts];
        
        unsigned char packet_head[4]  = {0};
        packet_head[1] = 0x10;
        packet_head[2] = (BYTE)(frameLength >> 5);
        packet_head[3] = (BYTE)(frameLength << 3);
        packet_head[3] &= 0xf8;
        packet_head[3] |= 0x00;
        memcpy(packet + rtp_header_size, packet_head, 4);
        memcpy(packet + rtp_header_size + 4, pSource, frameLength);//[data bytes], cBytes
        
        
        [self sendPacket_Audio:packet length:(cBytes + rtp_header_size + 4)];
    }
    else
    {
        NSLog(@"error: ....cBytes:%d < %d max_single_packet", cBytes, max_single_packet);
    }
}


- (void)onVideoData:(NSArray*)data time:(double)pts
{
    @synchronized(self)
    {
        if (_state != Client_RecordOK)
        {
            return;
        }
    }
    
    const int rtp_header_size = 12;
    const int max_single_packet = max_packet_size - rtp_header_size;
    const int max_fragment_packet = max_single_packet - 2;
    unsigned char packet[max_packet_size]  = {0};
    //bzero(packet, sizeof(packet));
    
    int nNALUs = (int)[data count];
    for (int i = 0; i < nNALUs; i++)
    {
        NSData* nalu = [data objectAtIndex:i];
        int cBytes = (int)[nalu length];
        BOOL bLast = (i == nNALUs-1);
        
        const unsigned char* pSource = (unsigned char*)[nalu bytes];
        
        if (_bFirst)
        {
            if ((pSource[0] & 0x1f) != 5)
            {
                continue;
            }
            _bFirst = NO;
            NSLog(@"Playback starting at first IDR");
        }
        
        if (cBytes < max_single_packet)
        {
            [self writeHeader_Video:packet marker:bLast time:pts];
            memcpy(packet + rtp_header_size, [nalu bytes], cBytes);
            [self sendPacket_Video:packet length:(cBytes + rtp_header_size)];
        }
        else
        {
            unsigned char NALU_Header = pSource[0];
            pSource += 1;
            cBytes -= 1;
            BOOL bStart = YES;
            
            while (cBytes)
            {
                int cThis = (cBytes < max_fragment_packet)? cBytes : max_fragment_packet;
                BOOL bEnd = (cThis == cBytes);
                [self writeHeader_Video:packet marker:(bLast && bEnd) time:pts];
                unsigned char* pDest = packet + rtp_header_size;
                
                pDest[0] = (NALU_Header & 0xe0) + 28;   // FU_A type
                unsigned char fu_header = (NALU_Header & 0x1f);
                if (bStart)
                {
                    fu_header |= 0x80;
                    bStart = false;
                }
                else if (bEnd)
                {
                    fu_header |= 0x40;
                }
                pDest[1] = fu_header;
                pDest += 2;
                memcpy(pDest, pSource, cThis);
                pDest += cThis;
                [self sendPacket_Video:packet length:(int)(pDest - packet)];
                
                pSource += cThis;
                cBytes -= cThis;
            }
        }
    }
    
}

- (void)writeHeader_Video:(uint8_t*)packet marker:(BOOL)bMarker time:(double)pts
{
    packet[0] = 0x80;   // v= 2
    if (bMarker)
    {
        packet[1] = Video_Code | 0x80;
    }
    else
    {
        packet[1] = Video_Code;
    }
    unsigned short seq = _packets & 0xffff;
    tonet_short(packet+2, seq);
    
    // map time
    while (_rtpBase == 0)
    {
        _rtpBase = random();
        _ptsBase = pts;
        NSDate* now = [NSDate date];
        // ntp is based on 1900. There's a known fixed offset from 1900 to 1970.
        NSDate* ref = [NSDate dateWithTimeIntervalSince1970:-2208988800L];
        double interval = [now timeIntervalSinceDate:ref];
        _ntpBase = (uint64_t)(interval * (1LL << 32));
    }
    pts -= _ptsBase;
    uint64_t rtp = (uint64_t)(pts * 90000);
    rtp += _rtpBase;
    tonet_long(packet + 4, rtp);
    tonet_long(packet + 8, _ssrc);
}


- (void)writeHeader_Audio:(uint8_t*)packet marker:(BOOL)bMarker time:(double)pts
{
    packet[0] = 0x80;   // v= 2
    if (bMarker)
    {
        packet[1] = Audio_Code | 0x80;
    }
    else
    {
        packet[1] = Audio_Code;
    }
    unsigned short seq = _packets_audio & 0xffff;
    tonet_short(packet+2, seq);
    
    // map time
    while (_rtpBase_audio == 0)
    {
        _rtpBase_audio = random();
        _ptsBase_audio = pts;
        NSDate* now = [NSDate date];
        // ntp is based on 1900. There's a known fixed offset from 1900 to 1970.
        NSDate* ref = [NSDate dateWithTimeIntervalSince1970:-2208988800L];
        double interval = [now timeIntervalSinceDate:ref];
        _ntpBase_audio = (uint64_t)(interval * (1LL << 32));
    }
    pts -= _ptsBase_audio;
    uint64_t rtp = (uint64_t)(pts * 44100);
    rtp += _rtpBase_audio;
    tonet_long(packet + 4, rtp);
    tonet_long(packet + 8, _ssrc_audio);
}

- (void)sendPacket_Audio:(uint8_t*)packet length:(int)cBytes
{
    
    @synchronized(self)
    {
        ///////////////////////////////////////add by lichq///////////////////////////////////////
        if (_s) {
            uint8_t new_packet[cBytes+4];
            new_packet[0] = 0x24;
            new_packet[1] = 0x02;
            tonet_short(new_packet+2, cBytes);
            memcpy(new_packet+4, packet, cBytes);
            //            NSLog(@"cByte = %d, sendCount = %d", cBytes, sendCount);
            
            //            [self sendUINT8_T:new_packet length:(cBytes+4)];
            [self sendUINT8_T:new_packet length:sizeof(new_packet)];//sizeof(new_packet)实际上等于(cBytes+4)
        }
        
        
        _packets_audio++;
        _bytesSent_audio += (cBytes+4);
        
        // RTCP packets
        NSDate* now = [NSDate date];
        if ((_sentRTCP_audio == nil) || ([now timeIntervalSinceDate:_sentRTCP_audio] >= 1))
        {
            uint8_t buf[7 * sizeof(uint32_t)];
            buf[0] = 0x80;
            buf[1] = 200;   // type == SR
            tonet_short(buf+2, 6);  // length (count of uint32_t minus 1)
            tonet_long(buf+4, _ssrc_audio);
            tonet_long(buf+8, (_ntpBase_audio >> 32));
            tonet_long(buf+12, _ntpBase_audio);
            tonet_long(buf+16, _rtpBase_audio);
            tonet_long(buf+20, (_packets_audio - _packetsReported_audio));
            tonet_long(buf+24, (_bytesSent_audio - _bytesReported_audio));
            int lenRTCP = 28;
            
            
            /////////////////////////////////////////add////////////////////////////////////////
            uint8_t new_buf[7 * sizeof(uint32_t)+4];
            new_buf[0] = 0x24;
            new_buf[1] = 0x03;
            tonet_short(new_buf+2, 28);
            memcpy(new_buf+4, buf, 28);
            lenRTCP = 28+4;
            ////////////////////////////////////////////////////////////////////////////////////
            
            if (_s) //修改
            {
                [self sendUINT8_T:new_buf length:sizeof(new_buf)];
            }
            
            _sentRTCP_audio = now;
            _packetsReported_audio = _packets_audio;
            _bytesReported_audio = _bytesSent_audio;
        }
        
        sendCount ++;
        
        ////////////////////////////////////////////////////////////////////////////////////
    }
}




- (void)sendPacket_Video:(uint8_t*)packet length:(int)cBytes
{
    
    @synchronized(self)
    {
        ///////////////////////////////////add by lichq///////////////////////////////////
        if (_s) {
            uint8_t new_packet[cBytes+4];
            new_packet[0] = 0x24;
            new_packet[1] = 0x00;
            tonet_short(new_packet+2, cBytes);
            memcpy(new_packet+4, packet, cBytes);
            //            NSLog(@"cByte = %d, sendCount = %d", cBytes, sendCount);
            
            //            [self sendUINT8_T:new_packet length:(cBytes+4)];
            [self sendUINT8_T:new_packet length:sizeof(new_packet)];//sizeof(new_packet)实际上等于(cBytes+4)
        }
        
        
        _packets++;
        _bytesSent += (cBytes+4);
        
        // RTCP packets
        NSDate* now = [NSDate date];
        if ((_sentRTCP == nil) || ([now timeIntervalSinceDate:_sentRTCP] >= 1))
        {
            uint8_t buf[7 * sizeof(uint32_t)];
            buf[0] = 0x80;
            buf[1] = 200;   // type == SR
            tonet_short(buf+2, 6);  // length (count of uint32_t minus 1)
            tonet_long(buf+4, _ssrc);
            tonet_long(buf+8, (_ntpBase >> 32));
            tonet_long(buf+12, _ntpBase);
            tonet_long(buf+16, _rtpBase);
            tonet_long(buf+20, (_packets - _packetsReported));
            tonet_long(buf+24, (_bytesSent - _bytesReported));
            int lenRTCP = 28;
            
            
            /////////////////////////////////////////add////////////////////////////////////////
            uint8_t new_buf[7 * sizeof(uint32_t)+4];
            new_buf[0] = 0x24;
            new_buf[1] = 0x01;
            tonet_short(new_buf+2, 28);
            memcpy(new_buf+4, buf, 28);
            lenRTCP = 28+4;
            ////////////////////////////////////////////////////////////////////////////////////
            
            if (_s) //修改
            {
                [self sendUINT8_T:new_buf length:sizeof(new_buf)];
            }
            
            _sentRTCP = now;
            _packetsReported = _packets;
            _bytesReported = _bytesSent;
        }
        
        sendCount ++;
        
        ////////////////////////////////////////////////////////////////////////////////////////////
    }
}

- (void) onRTCP:(CFDataRef) data
{
    // NSLog(@"RTCP recv");
}

- (void) tearDown
{
    @synchronized(self)
    {
//        if (_sRTP)
//        {
//            CFSocketInvalidate(_sRTP);
//            _sRTP = nil;
//        }
//        if (_sRTCP)
//        {
//            CFSocketInvalidate(_sRTCP);
//            _sRTCP = nil;
//        }
//        if (_recvRTCP)
//        {
//            CFSocketInvalidate(_recvRTCP);
//            _recvRTCP = nil;
//        }
    }
}

- (void) shutdown
{
    [self tearDown];
    @synchronized(self)
    {
        CFSocketInvalidate(_s);
        _s = nil;
    }
}

@end
