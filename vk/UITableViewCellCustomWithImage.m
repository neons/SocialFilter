//
//  UITableViewCellCustomWithImage.m
//  diplom
//
//  Created by admin on 01.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewCellCustomWithImage.h"

@implementation UITableViewCellCustomWithImage
@synthesize firstImage=_firstImage;
@synthesize secondImage=_secondImage;
@synthesize thirdImage=_thirdImage;
@synthesize fourthImage=_fourthImage;


+(UITableViewCellCustomWithImage*) cell
{
    NSArray *objects=[[NSBundle mainBundle] loadNibNamed:@"Cell" owner:nil options:nil];
    
    NSLog(@"create cell");
    return [objects objectAtIndex:0];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
