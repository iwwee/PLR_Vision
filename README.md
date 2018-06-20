## PLR Vision

PLR Vision是一个基于OpenCV和Tiny-dnn的开源中文车牌识别系统，同时也是作者的本科毕设项目，受限于作者自身水平以及时间精力，PLR Vision目前还有许多亟待解决的问题，在随后的更新中作者将主要对现阶段存在的问题进行完善和修改，努力开发出一个快速、准确、易用的中文车牌识别系统。

**PLR Vision系统目前已经初步实现的功能有**：

- Mac系统下的简洁易用的GUI界面
- 图像中的中文车牌定位及识别
- 识别车牌号的语音播报
- 视频流中的车辆检测与跟踪

**PLR Vision系统目前支持的车牌类型：**

- [x] 单行蓝牌
- [x] 单行黄牌
- [ ] 白色警用车牌
- [ ] 新能源车牌
- [ ] 教练车牌
- [ ] 武警车牌
- [ ] 双层黄牌

#### 存在的问题

1. 无法定位到低光照、低分辨率、倾斜角度过大的图像中的车牌
2. 字符分割算法无法准确分割倾斜车牌中的字符
3. 中文字符识别的准确率较低
4. 视频中车辆的识别不够准确
5. 视频流的处理速度不能满足实时性的要求



## 待做的工作

- [ ] 使用R-CNN来做车牌定位模块
- [ ] 设计新的中文字符识别CNN网络
- [ ] 收集更多的字符样本集用于训练CNN网络
- [ ] 使用faster R-CNN来检测视频中的车辆
- [ ] 使用关键帧算法来实现系统的实时检测



### PLR Vision系统测试效果

![image](https://github.com/NathanYu1124/PLR_Vision/blob/master/Gif_Demo/demo.gif)



#### 注意事项：

- Xcode项目中需要更改模型文件路径 

```c++
NYPlateJudge.cpp 文件
#define SVM_MODEL_PATH "/<PATH>/PLR_Vision/PLR_Vision/Model/svm.xml"

NYCNNOCR.cpp 文件
void NYCNNOCR::loadCNNModel()
{
    net.load("/<PATH>/PLR_Vision/PLR_Vision/Model/CNN_CHAR_MODEL.md");
    zhNet.load("/<PATH>/PLR_Vision/PLR_Vision/Model/CNN_ZH63_MODEL.md");
}
```



#### 致谢

感谢[EasyPR](https://github.com/liuruoze/EasyPR)的作者提供的高质量博客，正是在他的博客的帮助下，我才开发出了PLR Vision系统的雏形并在此基础上不断进行改进，最终达到了毕设项目的预期效果。

感谢[tiny-dnn](https://github.com/tiny-dnn/tiny-dnn)的作者提供的C++开源机器学习框架，得益于此我才能实现端到端车牌识别系统的简洁易用性，使项目配置更加方便。



#### 版权

PLR Vision的源代码与数据集遵循Apache v2.0协议开源。请确保在使用前了解以上协议的内容。