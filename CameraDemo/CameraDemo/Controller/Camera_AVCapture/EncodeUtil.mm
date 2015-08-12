//
//  EncodeUtil.m
//  Lee
//
//  Created by lichq on 5/26/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import "EncodeUtil.h"

@implementation EncodeUtil


void tonet_short(uint8_t* p, unsigned short s)
{
    p[0] = (s >> 8) & 0xff;
    p[1] = s & 0xff;
}
void tonet_long(uint8_t* p, unsigned long l)
{
    p[0] = (l >> 24) & 0xff;
    p[1] = (l >> 16) & 0xff;
    p[2] = (l >> 8) & 0xff;
    p[3] = l & 0xff;
}


NSString* encodeLong(unsigned long val, int nPad)
{
    char ch[4];
    int cch = 4 - nPad;
    for (int i = 0; i < cch; i++)
    {
        int shift = 6 * (cch - (i+1));
        int bits = (val >> shift) & 0x3f;
        ch[i] = Base64Mapping[bits];
    }
    for (int i = 0; i < nPad; i++)
    {
        ch[cch + i] = '=';
    }
    NSString* s = [[NSString alloc] initWithBytes:ch length:4 encoding:NSUTF8StringEncoding];
    return s;
}

NSString* encodeToBase64(NSData* data)
{
    NSString* s = @"";
    
    const uint8_t* p = (const uint8_t*) [data bytes];
    int cBytes = (int)[data length];
    while (cBytes >= 3)
    {
        unsigned long val = (p[0] << 16) + (p[1] << 8) + p[2];
        p += 3;
        cBytes -= 3;
        
        s = [s stringByAppendingString:encodeLong(val, 0)];
    }
    if (cBytes > 0)
    {
        int nPad;
        unsigned long val;
        if (cBytes == 1)
        {
            // pad 8 bits to 2 x 6 and add 2 ==
            nPad = 2;
            val = p[0] << 4;
        }
        else
        {
            // must be two bytes -- pad 16 bits to 3 x 6 and add one =
            nPad = 1;
            val = (p[0] << 8) + p[1];
            val = val << 2;
        }
        s = [s stringByAppendingString:encodeLong(val, nPad)];
    }
    return s;
}



@end
