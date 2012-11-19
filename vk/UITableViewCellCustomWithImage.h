//
//  UITableViewCellCustomWithImage.h
//  diplom
//
//  Created by admin on 01.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCellCustomWithImage : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *firstImage;
@property (weak, nonatomic) IBOutlet UIImageView *secondImage;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImage;
@property (weak, nonatomic) IBOutlet UIImageView *fourthImage;


+(UITableViewCellCustomWithImage *)cell;

@end
