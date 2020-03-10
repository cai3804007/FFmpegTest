//
//  ViewController.m
//  FFmpegTool
//
//  Created by SeanLink on 2020/3/9.
//  Copyright © 2020 SeanLink. All rights reserved.
//

#import "ViewController.h"
#import "ffmpeg.h"





@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
//转换视频
//- (void)converWithInputPath:(NSString *)inputPath
//                 outputPath:(NSString *)outpath
//               processBlock:(void (^)(float process))processBlock
//            completionBlock:(void (^)(NSError *error))completionBlock {
//    self.processBlock = processBlock;
//    self.completionBlock = completionBlock;
//    self.isBegin = NO;
//    
//    // ffmpeg语法，可根据需求自行更改      !#$ 为分割标记符，也可以使用空格代替
//    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg!#$-ss!#$00:00:00!#$-i!#$%@!#$-b:v!#$2000K!#$-y!#$%@", inputPath, outpath];
//    
//    [[[NSThread alloc] initWithTarget:self selector:@selector(runCmd:) object:commandStr] start];
//}
//
//
//// 执行指令
//- (void)runCmd:(NSString *)commandStr{
//    // 判断转换状态
//    if (self.isRuning) {
//        NSLog(@"正在转换,稍后重试");
//    }
//    self.isRuning = YES;
//    
//    // 根据 !#$ 将指令分割为指令数组
//    NSArray *argv_array = [commandStr componentsSeparatedByString:(@"!#$")];
//    // 将OC对象转换为对应的C对象
//    int argc = (int)argv_array.count;
//    char** argv = (char**)malloc(sizeof(char*)*argc);
//    for(int i=0; i < argc; i++) {
//        argv[i] = (char*)malloc(sizeof(char)*1024);
//        strcpy(argv[i],[[argv_array objectAtIndex:i] UTF8String]);
//    }
//    
//    ffmpeg_main(argc,argv);
//}

@end
