//
//  StandardFilter1.m
//  Phostock
//
//  Created by Roman Truba on 02.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "StandardFilter3.h"

@implementation StandardFilter3
-(void)getFilters
{
    
    /*
     Brightness : -0.101083
     Grayscale : 1.000000
     Blue : 1.176895
     Contrast : 1.667870
     Gamma : 0.703971
     Sepia : 0.519856
     */
    
    GPUImageBrightnessFilter * brightness = [[GPUImageBrightnessFilter alloc] init];
    brightness.brightness = -0.101083;
    [self prepare:brightness];
    
    GPUImageGrayscaleFilter * grayscale = [[GPUImageGrayscaleFilter alloc] init];
    [self prepare:grayscale];
    
    GPUImageRGBFilter * rgb = [[GPUImageRGBFilter alloc] init];
    rgb.blue =  1.176895;
    [self prepare:rgb];
    
    GPUImageContrastFilter * contrast = [[GPUImageContrastFilter alloc] init];
    contrast.contrast = 1.667870;
    [self prepare:contrast];
    
    GPUImageGammaFilter * gamma = [[GPUImageGammaFilter alloc] init];
    gamma.gamma = 0.703971;
    [self prepare:gamma];
    
    GPUImageSepiaFilter * sepia = [[GPUImageSepiaFilter alloc] init];
    sepia.intensity = 0.519856;
    [self prepare:sepia]; 
    
}

@end
