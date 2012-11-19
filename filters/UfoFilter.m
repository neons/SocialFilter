//
//  UfoFilter.m
//  Phostock
//
//  Created by Roman Truba on 03.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "UfoFilter.h"

@implementation UfoFilter
-(void)getFilters
{
    /*
     Hue: 1.894029
     Sepia: 0.326715
     Saturation: 1.202166
     */
    GPUImageHueFilter * hue = [[GPUImageHueFilter alloc] init];
    hue.hue = 110;
    [self prepare:hue];
    
    GPUImageSepiaFilter * sepia = [[GPUImageSepiaFilter alloc] init];
    sepia.intensity = 0.326715;
    [self prepare:sepia];
    
    GPUImageSaturationFilter * saturation = [[GPUImageSaturationFilter alloc] init];
    saturation.saturation = 1.202166;
    [self prepare:saturation];

}
@end
