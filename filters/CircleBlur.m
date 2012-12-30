//
//  CircleBlur.m
//  tiltshift
//
//  Created by admin on 27.12.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleBlur.h"
@interface CircleBlur()
@property (nonatomic) BOOL color;
@end

@implementation CircleBlur

@synthesize scale=_scale;
@synthesize center=_center;
@synthesize radius=_radius;
@synthesize delegate=_delegate;
@synthesize color = _color;

-(void) setup
{
    self.contentMode = UIViewContentModeRedraw;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self setup];
    }
    return self;
}

-(void)setScale:(CGFloat)scale
{
    if (scale !=_scale)
    {
        self.radius *= self.scale;
        _scale=scale;
        [self setNeedsDisplay];
    }
}
-(void)setCenter:(CGPoint)center
{
    if ((center.x != _center.x)||(center.y!=_center.y))
    {
        _center=center;
        [self setNeedsDisplay];
    }
}
-(void) awakeFromNib
{
    [self setup];
}
-(CGFloat)scale
{
    if (!_scale)
        return 1;
    else
        return _scale;
}
-(CGFloat) radius
{
    if (!_radius)
        return _radius = self.bounds.size.width/4;
    else
        return _radius;
}
-(void) drawCircleAtPoint:(CGPoint)p withRadius:(CGFloat)radius inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    
    if(_color)
        [[UIColor whiteColor]setStroke];
    else
        [[UIColor clearColor]setStroke];
    
    CGContextAddArc(context, p.x, p.y, radius, 0, 2*M_PI, YES); 
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}
-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.radius>170)
         _radius=170;
    else if (self.radius<10)
        _radius=10;
    CGContextSetLineWidth(context, 1.0);
    [self drawCircleAtPoint:self.center withRadius:self.radius inContext:context];
    CGContextStrokePath(context);
}

-(void)pinch:(UIPinchGestureRecognizer*)gesture
{
    if (gesture.state==UIGestureRecognizerStateChanged)
    {
        self.scale = gesture.scale;
        gesture.scale=1;
        _color=YES;
    }
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        _color=NO;
        [self setNeedsDisplay];
        [self.delegate blurIt:self];
    }
}


-(void)pan:(UIPanGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint newCenter = self.center;
        CGPoint translation = [gesture translationInView:self];
        newCenter.x+=translation.x;
        newCenter.y+=translation.y;
        if (newCenter.x > 320)
            newCenter.x = 320;
        else if (newCenter.x <0)
            newCenter.x = 0;
        if (newCenter.y > 320)
            newCenter.y = 320;
        else if (newCenter.y <0)
            newCenter.y = 0;
        _color=YES;
        self.center = newCenter;
        [gesture setTranslation:CGPointZero inView:self];
    }
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        self.color = NO;
        [self setNeedsDisplay];
        [self.delegate blurIt:self];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
