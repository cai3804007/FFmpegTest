//
//  ViewController.m
//  FFmpegTool
//
//  Created by SeanLink on 2020/3/10.
//  Copyright © 2020 SeanLink. All rights reserved.
//

#import "ViewController.h"
#import "LEYFFmpegManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *video = @"/Users/sean/Desktop/FFmpeg相关/testvideo/viedo.mp4";
    NSString *output = @"/Users/sean/Desktop/FFmpeg相关/testvideo/456.mp4";
    
    NSString *imageName = [[NSBundle mainBundle] pathForResource:@"logo@2x" ofType:@"jpg"];
    [[LEYFFmpegManager shared] addWaterPicWithVideo:video outPath:output imagePath:imageName];
    
}


@end
