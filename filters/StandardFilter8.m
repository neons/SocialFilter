//
//  StandardFilter1.m
//  Phostock
//
//  Created by Roman Truba on 02.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "StandardFilter8.h"

@implementation StandardFilter8
-(void)getFilters
{
    /*
     Contrast : 1.249097
     Gamma : 1.873646
     Brightness : 0.057762
     Saturation : 0.638989
     Sepia : 0.153430
     
     */
    GPUImageContrastFilter * contrast = [[GPUImageContrastFilter alloc] init];
    contrast.contrast = 1.249097;
    [self prepare:contrast];
    
    GPUImageGammaFilter * gamma = [[GPUImageGammaFilter alloc] init];
    gamma.gamma = 1.873646;
    [self prepare:gamma];
    
    GPUImageBrightnessFilter * brightness = [[GPUImageBrightnessFilter alloc] init];
    brightness.brightness = 0.057762;
    [self prepare:brightness];
    
    GPUImageSaturationFilter * saturation = [[GPUImageSaturationFilter alloc] init];
    saturation.saturation = 0.638989;
    [self prepare:saturation];
    
    GPUImageSepiaFilter * sepia = [[GPUImageSepiaFilter alloc] init];
    sepia.intensity = 0.153430;
    [self prepare:sepia];
    
}

@end
