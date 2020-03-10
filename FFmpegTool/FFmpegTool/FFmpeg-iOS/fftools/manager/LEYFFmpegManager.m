//
//  LEYFFmpegManager.m
//  FFmpeg_iOS_Demo
//
//  Created by panf on 2019/8/16.
//  Copyright © 2019 无码科技. All rights reserved.
//

#import "LEYFFmpegManager.h"
#import "ffmpeg.h"
#define DocumentDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define BundlePath(res) [[NSBundle mainBundle] pathForResource:res ofType:nil]
#define DocumentPath(res) [DocumentDir stringByAppendingPathComponent:res]

@interface LEYFFmpegManager ()

@property (nonatomic, assign) BOOL isRuning;
@property (nonatomic, assign) BOOL isBegin;
@property (nonatomic, assign) long long fileDuration;
@property (nonatomic, copy) void (^processBlock)(float process);
@property (nonatomic, copy) void (^completionBlock)(NSError *error);

@property (nonatomic, assign) long long originTime;
@property (nonatomic, assign) long long converTotalTime;

@end

@implementation LEYFFmpegManager

+ (LEYFFmpegManager *)shared {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}


- (void)converWithInputPath:(NSString *)inputPath
                 outputPath:(NSString *)outpath
                 originTime:(long long)originTime
            converTotalTime:(long long)converTotalTime
               processBlock:(void (^)(float process))processBlock
            completionBlock:(void (^)(NSError *error))completionBlock {
    self.processBlock = processBlock;
    self.completionBlock = completionBlock;
    self.isBegin = NO;
    
    self.originTime = originTime;
    self.converTotalTime = converTotalTime;
    
    // ffmpeg语法，可根据需求自行更改        为分割标记符，也可以使用空格代替
    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -ss %lld -t %lld -i %@ -b:v 2000K -y %@",originTime, converTotalTime, inputPath, outpath];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(runCmd:) object:commandStr] start];
}



- (void)runCmd:(NSString *)commandStr{
    // 判断转换状态
    if (self.isRuning) {
        NSLog(@"正在转换,稍后重试");
    }
    self.isRuning = YES;
    
    // 根据   将指令分割为指令数组
    NSArray *argv_array = [commandStr componentsSeparatedByString:(@" ")];
    
    
    int argc = (int)argv_array.count;
    char** argv = (char**)malloc(sizeof(char*)*argc);
    for(int i=0; i < argc; i++) {
        argv[i] = (char*)malloc(sizeof(char)*1024);
        strcpy(argv[i],[[argv_array objectAtIndex:i] UTF8String]);
    }
    
    ffmpeg_main(argc,argv);
}





+ (void)setDuration:(long long)time {
    [LEYFFmpegManager shared].fileDuration = time;
}

+ (void)setCurrentTime:(long long)time {
    LEYFFmpegManager *mgr = [LEYFFmpegManager shared];
    mgr.isBegin = YES;
    
    if (mgr.processBlock && mgr.fileDuration) {
        float total = MIN(mgr.fileDuration - mgr.originTime, mgr.converTotalTime);
        float process = time/(total * 1.00);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            mgr.processBlock(process);
        });
    }
}

+ (void)stopRuning {
    LEYFFmpegManager *mgr = [LEYFFmpegManager shared];
    NSError *error = nil;
    if (!mgr.isBegin) {
        // 判断是否开始过，没开始过就设置失败
        error = [NSError errorWithDomain:@"转换失败,请检查源文件的编码格式!"
                                    code:0
                                userInfo:nil];
    }
    if (mgr.completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            mgr.completionBlock(error);
        });
    }
    
    mgr.isRuning = NO;
}



- (void)startVideoCoverPhotos:(NSString *)video{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *moviePath = video;
        NSString *imageName = @"image%d.jpg";
        NSString *imagesPath = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject], imageName];
        int numberOfArgs = 6;
        char** arguments = calloc(numberOfArgs, sizeof(char*));
        
        arguments[0] = "ffmpeg";
        arguments[1] = "-i";
        arguments[2] = (char *)[moviePath UTF8String];
        arguments[3] = "-r";
        arguments[4] = "20";
        arguments[5] = (char *)[imagesPath UTF8String];
        
        int result = ffmpeg_main(numberOfArgs, arguments);
        NSLog(@"----------- %d", result);
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        
    });
}

- (void)addWaterPicWithVideo:(NSString *)videPath outPath:(NSString *)outPath
                   imagePath:(NSString *)imagePath{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        char *outPic = (char *)[outPath UTF8String];
        char *movie = (char *)[videPath UTF8String];
        char logo[1024];
        // 左上
        sprintf(logo, "movie=%s [logo]; [in][logo] overlay=30:10 [out]", [imagePath UTF8String]);
        // 左下
        //sprintf(logo, "movie=%s [logo]; [in][logo] overlay=30:main_h-overlay_h-10 [out]", [BundlePath(@"ff.jpg") UTF8String]);
        // 右下
        //sprintf(logo, "movie=%s [logo]; [in][logo] overlay=main_w-overlay_w-10:main_h-overlay_h-10 [out]", [BundlePath(@"ff.jpg") UTF8String]);
        // 右上
        //sprintf(logo, "movie=%s [logo]; [in][logo] overlay=main_w-overlay_w-10:10 [out]", [BundlePath(@"ff.jpg") UTF8String]);
        char* a[] = {
            "ffmpeg",
            "-i",
            movie,
            "-vf",
            logo,
            outPic
        };
        ffmpeg_main(sizeof(a)/sizeof(*a), a);
    });
    
}



//1、视频切分为图片。
- (void)sliceBtnClick
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        char *movie = (char *)[BundlePath(@"1.mp4") UTF8String];
        char *outPic = (char *)[DocumentPath(@"%05d.jpg") UTF8String];
        char* a[] = {
            "ffmpeg",
            "-i",
            movie,
            "-r",
            "10",
            outPic
        };
        ffmpeg_main(sizeof(a)/sizeof(*a), a);
    });
}
//2、图片、声音合成视频。
- (void)composeBtnClick
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        char *outPic = (char *)[DocumentPath(@"%05d.jpg") UTF8String];
        char *movie = (char *)[DocumentPath(@"1.mp4") UTF8String];
        char* a[] = {
            "ffmpeg",
            "-i",
            outPic,
            "-vcodec",
            "mpeg4",
            movie
        };
        ffmpeg_main(sizeof(a)/sizeof(*a), a);
    });
}
//3、视频编码转换。
- (void)transBtnClick
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        char *outPic = (char *)[DocumentPath(@"out.avi") UTF8String];
        char *movie = (char *)[BundlePath(@"1.mp4") UTF8String];
        char* a[] = {
            "ffmpeg",
            "-i",
            movie,
            "-vcodec",
            "mpeg4",
            outPic
        };
        ffmpeg_main(sizeof(a)/sizeof(*a), a);
    });
}
//4、视频加水印
- (void)logoBtnClick
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        char *outPic = (char *)[DocumentPath(@"logo.mp4") UTF8String];
        char *movie = (char *)[BundlePath(@"1.mp4") UTF8String];
        char logo[1024];
        // 左上
        sprintf(logo, "movie=%s [logo]; [in][logo] overlay=30:10 [out]", [BundlePath(@"ff.jpg") UTF8String]);
        // 左下
        //sprintf(logo, "movie=%s [logo]; [in][logo] overlay=30:main_h-overlay_h-10 [out]", [BundlePath(@"ff.jpg") UTF8String]);
        // 右下
        //sprintf(logo, "movie=%s [logo]; [in][logo] overlay=main_w-overlay_w-10:main_h-overlay_h-10 [out]", [BundlePath(@"ff.jpg") UTF8String]);
        // 右上
        //sprintf(logo, "movie=%s [logo]; [in][logo] overlay=main_w-overlay_w-10:10 [out]", [BundlePath(@"ff.jpg") UTF8String]);
        char* a[] = {
            "ffmpeg",
            "-i",
            movie,
            "-vf",
            logo,
            outPic
        };
        ffmpeg_main(sizeof(a)/sizeof(*a), a);
    });
}
//5、视频滤镜
- (void)filterBtnClick
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        char *outPic = (char *)[DocumentPath(@"filter.mp4") UTF8String];
        char *movie = (char *)[BundlePath(@"1.mp4") UTF8String];
        // 画格子
        //char *filter = "drawgrid=w=iw/3:h=ih/3:t=2:aliyunzixun@xxx.com";
        // 画矩形
        char *filter = "drawbox=x=10:y=20:w=200:h=60:aliyunzixun@xxx.com";
        // 裁剪
        //char *filter = "crop=in_w/2:in_h/2:(in_w-out_w)/2+((in_w-out_w)/2)*sin(n/10):(in_h-out_h)/2 +((in_h-out_h)/2)*sin(n/7)";
        char* a[] = {
            "ffmpeg",
            "-i",
            movie,
            "-vf",
            filter,
            outPic
        };
        ffmpeg_main(sizeof(a)/sizeof(*a), a);
    });
}


@end
