//
//  StandardFilter1.m
//  Phostock
//
//  Created by Roman Truba on 02.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "StandardFilter2.h"

@implementation StandardFilter2
-(void)getFilters
{
    /*
     Blue : 1.133574
     Gamma : 2.074007
     Saturation : 1.382671
     Sepia : 0.577617
     Brightness : 0.184116
     */
    GPUImageRGBFilter * rgb = [[GPUImageRGBFilter alloc] init];
    rgb.blue = 1.133574;
    [self prepare:rgb];
    
    GPUImageGammaFilter * gamma = [[GPUImageGammaFilter alloc] init];
    gamma.gamma = 2.074007;
    [self prepare:gamma];
    
    GPUImageSaturationFilter * saturation = [[GPUImageSaturationFilter alloc] init];
    saturation.saturation = 1.382671;
    [self prepare:saturation];
    
    GPUImageSepiaFilter * sepia = [[GPUImageSepiaFilter alloc] init];
    sepia.intensity = 0.577617;
    [self prepare:sepia];
    
    GPUImageBrightnessFilter * brightness = [[GPUImageBrightnessFilter alloc] init];
    brightness.brightness = 0.184116;
    [self prepare:brightness];
    
}

@end
