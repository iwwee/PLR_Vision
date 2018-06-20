//
//  NYCharacterRecognition.hpp
//  NYPlateRecognition
//
//  Created by NathanYu on 07/02/2018.
//  Copyright © 2018 NathanYu. All rights reserved.
//

#ifndef NYCharacterRecognition_hpp
#define NYCharacterRecognition_hpp

#include <stdio.h>
#include "NYCharacterJudge.hpp"
#include "NYCharacterPartition.hpp"

class NYCharacterRecognition {
    
    
public:
    
    // 车牌字符识别
    vector<string> recognizeChars(vector<NYPlate> &plates);
    
    // 车牌字符识别
    string recognizeChars(NYPlate plate);
    
private:
    
    NYCharacterJudge charJudge();
    
};



#endif /* NYCharacterRecognition_hpp */
