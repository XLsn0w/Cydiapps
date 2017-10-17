//
//  ViewController.m
//  Cydia
//
//  Created by golong on 2017/10/11.
//  Copyright © 2017年 XLsn0w. All rights reserved.
//

#import "ViewController.h"
#define SCREENWIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
{
    //原来的图像
    UIImageView * _originleImagView;
    //识别出来的图像
    UIImageView * newfaceImageView;
    
}

@property (nonatomic, assign) NSInteger featureCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _featureCount = 0;
    UIImage * oldFaceImg = [UIImage imageNamed:@"faces1"];
    _originleImagView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, oldFaceImg.size.width, oldFaceImg.size.height)];
    [_originleImagView setImage:oldFaceImg];
    _originleImagView.center = CGPointMake(SCREENWIDTH/2, oldFaceImg.size
                                           .height/2+30);
    
    [self.view addSubview:_originleImagView];
    
    UIButton * featureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    featureButton.frame = CGRectMake(0, 0, 120, 50);
    featureButton.center = CGPointMake(SCREENWIDTH/2, oldFaceImg.size.height + 30 + 30);
    [featureButton setTitle:[NSString stringWithFormat:@"识别人脸%ld次",(long)_featureCount]forState:UIControlStateNormal];
    [featureButton setTitle:@"识别的图像为" forState:UIControlStateSelected];
    featureButton.backgroundColor = [UIColor grayColor];
    [featureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [featureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [featureButton addTarget:self action:@selector(faceFetureButtonAction:)forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:featureButton];
    
    newfaceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH/2, oldFaceImg.size.height + 30+ 60 , 50, 50)];
    [self.view addSubview:newfaceImageView];
    
}

-(void)faceFetureButtonAction:(UIButton *)button {
    //核心代码进行人脸识别
    CIContext * context = [CIContext contextWithOptions:nil];
    UIImage * imageInput = [_originleImagView image];
    CIImage * imageChange = [CIImage imageWithCGImage:imageInput.CGImage];
    // 设置识别的参数
    NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
  
    //声明CIDetector
    CIDetector * faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:param];
    //取得识别结果
    NSArray * detectResult = [faceDetector featuresInImage:imageChange];
    UIView * resultView = [[UIView alloc] initWithFrame:_originleImagView.frame];
    [self.view addSubview:resultView];
    for (CIFaceFeature * faceFeature in detectResult) {
        //脸部
        UIView * faceView = [[UIView alloc] initWithFrame:faceFeature.bounds];
        faceView.layer.borderWidth = 1;
        faceView.layer.borderColor = [UIColor orangeColor].CGColor;
        [resultView addSubview:faceView];
        
        //左眼
        if (faceFeature.hasLeftEyePosition) {
            UIView * leftEyeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
            [leftEyeView setCenter:faceFeature.leftEyePosition];
            leftEyeView.layer.borderWidth = 1;
            leftEyeView.layer.borderColor = [UIColor orangeColor].CGColor;
            [resultView addSubview:leftEyeView];
        }
        
        //右眼
        if (faceFeature.hasRightEyePosition) {
            UIView * rightEyeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
            [rightEyeView setCenter:faceFeature.rightEyePosition];
            rightEyeView.layer.borderColor = [UIColor orangeColor].CGColor;
            rightEyeView.layer.borderWidth = 1;
            [resultView addSubview:rightEyeView];
        }
        
        //嘴巴
        if (faceFeature.hasMouthPosition) {
            UIView * mouthView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 5)];
            [mouthView setCenter:faceFeature.rightEyePosition];
            mouthView.layer.borderColor = [UIColor orangeColor].CGColor;
            mouthView.layer.borderWidth = 1;
            [resultView addSubview:mouthView];
        }
        [resultView setTransform:CGAffineTransformMakeScale(1, -1)];
        if ([detectResult count] > 0) {
            {
                CIImage * faceImage = [imageChange imageByCroppingToRect:[[detectResult objectAtIndex:0] bounds]];
                UIImage * face = [UIImage imageWithCGImage:[context createCGImage:faceImage fromRect:faceImage.extent]];
                newfaceImageView.image = face;
                newfaceImageView.frame = CGRectMake(SCREENWIDTH/2-40, 300+ 30+ 60 ,80 , 80);
                _featureCount +=1;
                [button setTitle:[NSString stringWithFormat:@"识别次数%ld次",(long)_featureCount]forState:UIControlStateNormal];
                
            }
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
