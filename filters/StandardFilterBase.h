//
//  StandardFilterBase.h
//  Phostock
//
//  Created by Roman Truba on 02.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "GPUImage.h"
@interface StandardFilterBase : GPUImageFilterGroup
{
    GPUImageFilter * firstFilter;
    GPUImageFilter * lastFilter;
    NSMutableArray * filtersArray;
}
-(void) prepare:(GPUImageFilter*) filter;
-(void) getFilters;
@end
