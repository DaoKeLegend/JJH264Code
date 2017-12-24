//
//  JJEAGLLayer.h
//  JJH264Code
//
//  Created by lucy on 2017/12/24.
//  Copyright © 2017年 com.daoKeLegend. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#include <CoreVideo/CoreVideo.h>

@interface JJEAGLLayer : CAEAGLLayer

@property CVPixelBufferRef pixelBuffer;

- (id)initWithFrame:(CGRect)frame;

- (void)resetRenderBuffer;

@end
