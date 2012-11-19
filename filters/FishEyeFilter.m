//
//  FishEyeFilter.m
//  Phostock
//
//  Created by Roman Truba on 03.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "FishEyeFilter.h"

@implementation FishEyeFilter
-(void)getFilters
{
    
    /*
     Pinch : -0.664260
     Gamma : 0.861011
     */
    GPUImagePinchDistortionFilter * pinch = [[GPUImagePinchDistortionFilter alloc] init];
    pinch.scale = -0.664260;
    [self prepare:pinch];
    
    GPUImageGammaFilter * gamma = [[GPUImageGammaFilter alloc] init];
    gamma.gamma = 0.861011;
    [self prepare:gamma];
    
}
@end
