//
//  JJH264VC.h
//  JJH264Code
//
//  Created by lucy on 2017/12/24.
//  Copyright © 2017年 com.daoKeLegend. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "JJH264Decoder.h"
#import "JJH264Encoder.h"

@interface JJH264VC : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, JJH264EncoderDelegate, JJH264DecoderDelegate>

@end
