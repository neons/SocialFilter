//
//  UIViewControllerFacebookAlbums.h
//  diplom
//
//  Created by admin on 24.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "diplomAppDelegate.h"
#import "FacebookPhotosViewController.h"

@interface FacebookAlbumViewController : UIViewController <UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
