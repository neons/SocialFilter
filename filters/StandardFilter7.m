//
//  StandardFilter1.m
//  Phostock
//
//  Created by Roman Truba on 02.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "StandardFilter7.h"

@implementation StandardFilter7
-(void)getFilters
{
    /*
     Contrast : 1.285199
     White Balance : 4060
     Saturation : 1.364621
     Sepia : 0.629964
     
     */
    GPUImageContrastFilter * contrast = [[GPUImageContrastFilter alloc] init];
    contrast.contrast = 1.285199;
    [self prepare:contrast];
    
    GPUImageWhiteBalanceFilter * whiteBalance = [[GPUImageWhiteBalanceFilter alloc] init];
    whiteBalance.temperature = 4060;
    [self prepare:whiteBalance];
    
    GPUImageSaturationFilter * saturation = [[GPUImageSaturationFilter alloc] init];
    saturation.saturation = 1.364621;
    [self prepare:saturation];
    
    GPUImageSepiaFilter * sepia = [[GPUImageSepiaFilter alloc] init];
    sepia.intensity = 0.629964;
    [self prepare:sepia];
        
}

@end
