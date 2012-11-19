//
//  EdgeeFilter.m
//  Phostock
//
//  Created by Roman Truba on 03.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "EdgeeFilter.h"

@implementation EdgeeFilter
-(void)getFilters
{
    /*
     Contrast : 1.249097
     Prewit : 1.000000
     Red : 1.068592
     Green : 1.176895
     Blue : 1.678700
     */

    GPUImagePrewittEdgeDetectionFilter * prewit = [[GPUImagePrewittEdgeDetectionFilter alloc] init];
    [self prepare:prewit];
    
    GPUImageContrastFilter * contrast = [[GPUImageContrastFilter alloc] init];
    contrast.contrast = 1.111913;
    [self prepare:contrast];   
    
    GPUImageRGBFilter * rgb = [[GPUImageRGBFilter alloc] init];
    rgb.red     = 1.068592;
    rgb.green   = 1.176895;
    rgb.blue    = 1.678700;
    [self prepare:rgb];
}
@end
