//
//  MakeMeTallFilter.m
//  Phostock
//
//  Created by Roman Truba on 03.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "MakeMeTallFilter.h"

@implementation MakeMeTallFilter
-(void)getFilters
{
    /*
     Pinch : 0.592058
     Contrast : 1.342960
     Brightness : 0.021661
     Saturation : 0.682310
     */
    
    GPUImagePinchDistortionFilter * pinch = [[GPUImagePinchDistortionFilter alloc] init];
    pinch.scale = 0.592058;
    [self prepare:pinch];
    
    GPUImageContrastFilter * contrast = [[GPUImageContrastFilter alloc] init];
    contrast.contrast = 1.342960;
    [self prepare:contrast];
    
    GPUImageBrightnessFilter * brightness = [[GPUImageBrightnessFilter alloc] init];
    brightness.brightness = 0.021661;
    [self prepare:brightness];
    
    GPUImageSaturationFilter * saturation = [[GPUImageSaturationFilter alloc] init];
    saturation.saturation = 0.682310;
    [self prepare:saturation];
}
@end
