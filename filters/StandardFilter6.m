//
//  StandardFilter1.m
//  Phostock
//
//  Created by Roman Truba on 02.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "StandardFilter6.h"

@implementation StandardFilter6
-(void)getFilters
{
    /*
     Sepia: 0.4007
     Saturatio: 1.501
     Red: 1.13
     Green: 1.03
     */
    GPUImageSepiaFilter * sepia = [[GPUImageSepiaFilter alloc] init];
    sepia.intensity = 0.4007;
    [self prepare:sepia];
    
    GPUImageSaturationFilter * saturation = [[GPUImageSaturationFilter alloc] init];
    saturation.saturation = 1.501;
    [self prepare:saturation];
    
    GPUImageRGBFilter * rgb = [[GPUImageRGBFilter alloc] init];
    rgb.red =  1.13;
    rgb.green = 1.03;
    [self prepare:rgb];}

@end
