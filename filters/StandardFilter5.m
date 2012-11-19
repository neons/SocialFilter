//
//  StandardFilter1.m
//  Phostock
//
//  Created by Roman Truba on 02.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "StandardFilter5.h"

@implementation StandardFilter5
-(void)getFilters
{
    
    /*
     Brightness: 0.1877
     Gamma : 2.052347
     Grayscale
     
     */
    
    GPUImageBrightnessFilter * brightness = [[GPUImageBrightnessFilter alloc] init];
    
    brightness.brightness = -0.101083;
    [self prepare:brightness];
    
    GPUImageGammaFilter * gamma = [[GPUImageGammaFilter alloc] init];
    gamma.gamma = 0.74;
    [self prepare:gamma];
    
    GPUImageGrayscaleFilter * grayscale = [[GPUImageGrayscaleFilter alloc] init];
    [self prepare:grayscale];

}

@end
