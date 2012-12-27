//
//  CircleBlur.h
//  tiltshift
//
//  Created by admin on 27.12.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleBlur;
@protocol circleBlurProtocol <NSObject>

-(void) blurIt:(CircleBlur*)sender;

@end

@interface CircleBlur : UIView

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint center;
@property (nonatomic) CGFloat radius;

@property (nonatomic,weak) IBOutlet id <circleBlurProtocol> delegate;


@end
