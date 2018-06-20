//
//  NYPlateJudge.hpp
//  NYPlateRecognition
//
//  Created by NathanYu on 24/01/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#ifndef NYPlateJudge_hpp
#define NYPlateJudge_hpp

#include <stdio.h>
#include <iostream>
#include <opencv2/ml.hpp>
#include "NYPlateLocate.hpp"
#include "Utils.hpp"

using namespace std;
using namespace cv;
using namespace ml;
using namespace Utils;

class NYPlateJudge {
    
public:
    
    // 判断真正的车牌
    bool judgeTruePlate(Mat src);
    
    // SVM识别真正的车牌
    vector<NYPlate> judgePlates(vector<NYPlate> potentialVec);
    
    // 训练SVM模型
    int trainSVMModel();
    
private:
    
    // 提取HOG特征
    void getHOGFeatures(Mat src, Mat& feature);
    
    // 加载待训练的非车牌
    void getNoPlates(Mat& trainingMat, vector<int>& trainingLabels);
    
    // 加载待训练的车牌
    void getPlates(Mat& trainingMat, vector<int>& trainingLabels);
    
};

#endif /* NYPlateJudge_hpp */
