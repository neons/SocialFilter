//
//  UIViewControllerFacebookAlbums.h
//  diplom
//
//  Created by admin on 24.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "diplomAppDelegate.h"
#import "UIViewControllerFacebookPhotos.h"

@interface UIViewControllerFacebookAlbums : UIViewController <UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate , FBRequestDelegate , FBSessionDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
