//
//  EightBitsFilter.m
//  Phostock
//
//  Created by Roman Truba on 03.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "EightBitsFilter.h"

@implementation EightBitsFilter
-(void)getFilters
{
    /*
     Pixelate : 0.019856
     Saturation : 1.101083
     Contrast : 1.234657
     Brightness : -0.108303
     */
    
    GPUImagePixellateFilter * pixelate = [[GPUImagePixellateFilter alloc] init];
    pixelate.fractionalWidthOfAPixel = 0.012;
    [self prepare:pixelate];
    
    GPUImageSaturationFilter * saturation = [[GPUImageSaturationFilter alloc] init];
    saturation.saturation = 1.101083;
    [self prepare:saturation];
    
    GPUImageContrastFilter * contrast = [[GPUImageContrastFilter alloc] init];
    contrast.contrast = 1.234657;
    [self prepare:contrast];
    
    GPUImageBrightnessFilter * brightness = [[GPUImageBrightnessFilter alloc] init];
    brightness.brightness = 0.108303;
    [self prepare:brightness];
    
    
    
}
@end
