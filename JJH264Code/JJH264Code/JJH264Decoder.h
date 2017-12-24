//
//  JJH264Decoder.h
//  JJH264Code
//
//  Created by lucy on 2017/12/24.
//  Copyright © 2017年 com.daoKeLegend. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <AVFoundation/AVSampleBufferDisplayLayer.h>

@protocol JJH264DecoderDelegate <NSObject>

- (void)displayDecodedFrame:(CVImageBufferRef )imageBuffer;

@end

@interface JJH264Decoder : NSObject

@property (weak, nonatomic) id<JJH264DecoderDelegate>delegate;

- (BOOL)initH264Decoder;

- (void)decodeNalu:(uint8_t *)frame withSize:(uint32_t)frameSize;

@end
