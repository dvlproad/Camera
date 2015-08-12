//
//  EncodedFrame.m
//  Lee
//
//  Created by lichq on 5/27/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import "EncodedFrame.h"

@implementation EncodedFrame

@synthesize poc;
@synthesize frame;

- (EncodedFrame*) initWithData:(NSArray*) nalus andPOC:(int) POC
{
    self.poc = POC;
    self.frame = nalus;
    return self;
}

@end
