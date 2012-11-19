//
//  StandardFilter1.m
//  Phostock
//
//  Created by Roman Truba on 02.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "StandardFilter1.h"

@implementation StandardFilter1
-(void)getFilters
{
    /*
     Contrast : 1.032491
     Gamma : 1.196751
     Sepia : 0.442238
     Saturation : 1.198556
     */
    GPUImageContrastFilter * contrast = [[GPUImageContrastFilter alloc] init];
    contrast.contrast = 1.032491f;
    [self prepare:contrast];
    
    GPUImageGammaFilter * gamma = [[GPUImageGammaFilter alloc] init];
    gamma.gamma = 1.196751;
    [self prepare:gamma];
    
    GPUImageSepiaFilter * sepia = [[GPUImageSepiaFilter alloc] init];
    sepia.intensity = 0.442238;
    [self prepare:sepia];
    
    GPUImageSaturationFilter * saturation = [[GPUImageSaturationFilter alloc] init];
    saturation.saturation = 1.198556;
    [self prepare:saturation];    
}

@end
