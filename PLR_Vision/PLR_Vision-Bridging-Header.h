//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Foundation/Foundation.h>

@interface ImageConverter: NSObject

// OpenCV识别车牌号码
+(NSMutableDictionary*)getPlateLicense: (NSString*)imgPath;

// OpenCV获取视频帧
+(NSMutableDictionary *)getVideoFrame;

// OpenCV开始处理视频流
+(BOOL)startAnalyseVideo: (NSString*)videoPath;

@end
