//
//  VinnyFilter.m
//  Phostock
//
//  Created by Roman Truba on 03.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "VinnyFilter.h"

@implementation VinnyFilter
-(void)getFilters
{
    /*
     Vignette start : 0.615523
     Vignette end : 0.765343
     Saturation : 0.675090
     Contrast : 1.111913
     Brightness : 0.039711
     Shadows : 0.604693
     */
    
    GPUImageVignetteFilter * vignette = [[GPUImageVignetteFilter alloc] init];
    vignette.vignetteStart = 0.415523;
    vignette.vignetteEnd = 0.765343;
    [self prepare:vignette];
    
    GPUImageSaturationFilter * saturation = [[GPUImageSaturationFilter alloc] init];
    saturation.saturation = 0.675090;
    [self prepare:saturation];
    
    GPUImageContrastFilter * contrast = [[GPUImageContrastFilter alloc] init];
    contrast.contrast = 1.111913;
    [self prepare:contrast];
    
    GPUImageBrightnessFilter * brightness = [[GPUImageBrightnessFilter alloc] init];
    brightness.brightness = 0.039711;
    [self prepare:brightness];
    
    GPUImageHighlightShadowFilter * shadow = [[GPUImageHighlightShadowFilter alloc] init];
    shadow.shadows = 0.604693;
    [self prepare:shadow];
}
@end
