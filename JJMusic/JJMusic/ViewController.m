//
//  ViewController.m
//  JJMusic
//
//  Created by lucy on 2017/12/24.
//  Copyright © 2017年 com.daoKeLegend. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *startPlay;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;


@end

@implementation ViewController

#pragma mark - Override Base Function

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}

#pragma mark - Action && Notification

- (IBAction)startPlayButtonDidClick:(UIButton *)sender
{
    // 1.获取要播放音频文件的URL
    NSURL *fileURL = [[NSBundle mainBundle]URLForResource:@"music" withExtension:@".mp3"];
    
    // 2.创建 AVAudioPlayer 对象
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:nil];
    
    // 3.打印歌曲信息
    NSString *msg = [NSString stringWithFormat:@"音频文件声道数:%ld\n 音频文件持续时间:%g",self.audioPlayer.numberOfChannels,self.audioPlayer.duration];
    NSLog(@"%@",msg);
    
    // 4.设置循环播放
    self.audioPlayer.numberOfLoops = -1;
    
    //这句话如果不需要在代理方法里面处理什么是不要设置代理的
    self.audioPlayer.delegate = self;
    
    // 5.开始播放
    [self.audioPlayer play];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"player = %@", player);
    NSLog(@"error = %@", error);
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"player = %@", player);
    NSLog(@"flag = %d", flag);
}

@end
