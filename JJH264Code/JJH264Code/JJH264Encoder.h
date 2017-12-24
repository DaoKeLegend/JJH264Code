//
//  JJH264Encoder.h
//  JJH264Code
//
//  Created by lucy on 2017/12/24.
//  Copyright © 2017年 com.daoKeLegend. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AVFoundation;

@protocol JJH264EncoderDelegate <NSObject>

- (void)gotSpsPps:(NSData*)sps pps:(NSData*)pps;

- (void)gotEncodedData:(NSData*)data isKeyFrame:(BOOL)isKeyFrame;

@end


@interface JJH264Encoder : NSObject

- (void)initWithConfiguration;

- (void)initEncode:(int)width  height:(int)height;

- (void)encode:(CMSampleBufferRef )sampleBuffer;

@property (weak, nonatomic) id<JJH264EncoderDelegate> delegate;

@end
