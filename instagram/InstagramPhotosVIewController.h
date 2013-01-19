//
//  InstagramAlbumsVIewController.h
//  diplom
//
//  Created by admin on 16.01.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGConnect.h"
#import "diplomAppDelegate.h"
#import "UITableViewCellCustomWithImage.h"

@interface InstagramPhotosViewController : UIViewController <IGSessionDelegate, IGRequestDelegate, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate>

@end
