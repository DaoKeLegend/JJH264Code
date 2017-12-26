//
//  ViewController.m
//  JJMusic_demo1
//
//  Created by mac on 2017/12/26.
//  Copyright © 2017年 DaoKeLegend. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()

@end

@implementation ViewController

static SystemSoundID soundID = 0;

#pragma mark -  Override Base Function

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //UI界面
    [self initUI];
}

#pragma mark -  Object Private Function

void soundCompleteCallBack(SystemSoundID soundID, void * clientDate)
{
    NSLog(@"播放完成");
    AudioServicesDisposeSystemSoundID(soundID);
}

- (void)playMusic
{
    //获取资源地址
    NSString *str = [[NSBundle mainBundle] pathForResource:@"sound" ofType:@"m4a"];
    NSURL *url = [NSURL fileURLWithPath:str];
    
    // 创建音效的ID，音效的播放和销毁都靠这个ID来执行
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &soundID);
    
    //带有声音和震动的播放
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
        AudioServicesPlayAlertSoundWithCompletion(soundID, ^{
            NSLog(@"播放完成");
        });
    }
    else {
        AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallBack, NULL);
    };
}

- (void)stopMusic
{
    AudioServicesDisposeSystemSoundID(soundID);
}

- (void)initUI
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((self.view.bounds.size.width - 200.0) * 0.5, (self.view.bounds.size.height - 200.0) * 0.5, 200.0, 200.0);
    button.backgroundColor = [UIColor lightGrayColor];
    button.layer.cornerRadius = 100.0;
    button.layer.masksToBounds = YES;
    [button setTitle:@"开始播放" forState:UIControlStateNormal];
    [button setTitle:@"停止播放" forState:UIControlStateSelected];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(playButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma mark -  Action && Notification

- (void)playButtonDidClick:(UIButton *)button
{
    button.selected = !button.selected;
    
    if (button.selected) {
        [self playMusic];
    }
    else {
        [self stopMusic];
    }
}

@end
