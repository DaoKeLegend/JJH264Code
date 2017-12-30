//
//  ViewController.m
//  JJMusic_demo4
//
//  Created by mac on 2017/12/27.
//  Copyright © 2017年 DaoKeLegend. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>  

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //这两句不可缺少
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //资源路径
    NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"music" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:pathStr];
    
    //实例化播放器控制器
    MPMoviePlayerViewController* moviePlayerController =[[MPMoviePlayerViewController alloc] initWithContentURL: url];
    moviePlayerController.view.frame = self.view.frame;
    [self.view addSubview:moviePlayerController.view];
    moviePlayerController.moviePlayer.scalingMode = MPMovieScalingModeFill;
    moviePlayerController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [moviePlayerController.moviePlayer setFullscreen:YES];
    moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeUnknown;
    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    //或者[self.navigationController pushViewController:moviePlayerController animated:YES];，我这里没有集成导航VC，所以就用present
    [moviePlayerController.moviePlayer play];
}

@end
