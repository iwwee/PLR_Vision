//
//  NYAutoRecognize.hpp
//  NYPlateRecognition
//
//  Created by NathanYu on 07/02/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#ifndef NYAutoRecognize_hpp
#define NYAutoRecognize_hpp

#include <stdio.h>
#include "NYCharacterRecognition.hpp"
#include "NYPlateDetect.hpp"
#include "Utils.hpp"
#include "CacheQueue.hpp"
#include <queue>

#define CAR_PATH "/Users/NathanYu/Downloads/PlateRecognition/Cars/"
#define PLATE_OUTPUT_PATH "/Users/NathanYu/Desktop/plates/"



class NYAutoRecognize {
    
public:
        
    bool isAnalysing;   // 是否正在处理视频
    
    vector<cv::Rect> preRects;  // 上一帧中处理的矩形区域
    
    // 自动识别;图片上的车牌号
    vector<string> recognizePlateNumber(Mat src, vector<vector<map<string, float>>> &charsScore, vector<string> &colors);
    
    vector<NYPlate> recognizePlateNumber(Mat src);
    
    vector<NYPlate> recognizeVideoPlate(Mat &src);
    
    void analyseVideo(string videoPath);
    
    // 批处理所有车牌
    void handleAllCars();
    
    // 绘制车牌
    void drawLicense(Mat &img, NYPlate plate, int index);
    
    // 处理高分辨率图片
    void scaleHDImage(Mat &src);
    
    // 轮廓按面积降序排序，去除小轮廓目标
    bool descSort(vector<cv::Point> p1, vector<cv::Point> p2);
    
    // 是否为同一个区域
    bool isSameRegion(cv::Rect r1, cv::Rect r2);
    
};


#endif /* NYAutoRecognize_hpp */
