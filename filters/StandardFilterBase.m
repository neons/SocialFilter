//
//  StandardFilterBase.m
//  Phostock
//
//  Created by Roman Truba on 02.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "StandardFilterBase.h"

@implementation StandardFilterBase
- (id)init
{
    if (!(self = [super init]))
    {
		return nil;
    }
    [self getFilters];
    [self prepareForImageCapture];
    return self;
}
-(void) getFilters
{
    NSAssert(false, @"This method is abstract");
}
-(void) prepare:(GPUImageFilter*) filter
{
    if (!filtersArray) filtersArray = [NSMutableArray new];
    [filtersArray addObject:filter];
    if (!firstFilter) firstFilter = filter;
    [lastFilter addTarget:filter];
    lastFilter = filter;
    [self addFilter:filter];
    [filter prepareForImageCapture];
}
-(void)prepareForImageCapture
{
    self.initialFilters = [NSArray arrayWithObject: firstFilter];
    // bl9 self.initialFilters = @[firstFilter];

    self.terminalFilter = lastFilter;
    [super prepareForImageCapture];
}
-(void)dealloc
{
    for (GPUImageOutput<GPUImageInput> * filter in filtersArray) {
        [filter removeAllTargets];
        [filter prepareForImageCapture];
    }
    [filtersArray removeAllObjects];
    NSLog(@"Filter dealloc");
}
@end
