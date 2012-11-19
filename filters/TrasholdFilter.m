//
//  TrasholdFilter.m
//  Phostock
//
//  Created by Roman Truba on 03.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "TrasholdFilter.h"

@implementation TrasholdFilter
-(void)getFilters
{
    /*
     Luminance Threshold : 0.509025
     Sepia : 0.516245
     Saturation : 1.252708
     */
    
    GPUImageLuminanceThresholdFilter * treshold = [[GPUImageLuminanceThresholdFilter alloc] init];
    treshold.threshold = 0.509025;
    [self prepare:treshold];
    
    GPUImageSepiaFilter * sepia = [[GPUImageSepiaFilter alloc] init];
    sepia.intensity = 0.516245;
    [self prepare:sepia];
    
    GPUImageSaturationFilter * saturation = [[GPUImageSaturationFilter alloc] init];
    saturation.saturation = 1.252708;
    [self prepare:saturation];
    
    
}
@end
