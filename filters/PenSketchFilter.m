//
//  PenSketchFilter.m
//  Phostock
//
//  Created by Roman Truba on 03.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "PenSketchFilter.h"

@implementation PenSketchFilter
-(void)getFilters
{

    /*
     Sketch : 1.000000
     Sepia : 0.357401
     Gamma : 1.689531
     White Balance : 3610.000000
     */
    GPUImageSketchFilter * sketch = [[GPUImageSketchFilter alloc] init];
    [self prepare:sketch];
    
    GPUImageSepiaFilter * sepia = [[GPUImageSepiaFilter alloc] init];
    sepia.intensity = 0.357401;
    [self prepare:sepia];
    
    GPUImageGammaFilter * gamma = [[GPUImageGammaFilter alloc] init];
    gamma.gamma = 1.689531;
    [self prepare:gamma];
    
    GPUImageWhiteBalanceFilter * whiteBalance = [[GPUImageWhiteBalanceFilter alloc] init];
    whiteBalance.temperature = 3610;
    [self prepare:whiteBalance];
}
@end
