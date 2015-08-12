//
//  EncodedFrame.h
//  Lee
//
//  Created by lichq on 5/27/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import <Foundation/Foundation.h>

// store the calculated POC with a frame ready for timestamp assessment
// (recalculating POC out of order will get an incorrect result)
@interface EncodedFrame : NSObject

- (EncodedFrame*) initWithData:(NSArray*) nalus andPOC:(int) poc;

@property int poc;
@property NSArray* frame;

@end
