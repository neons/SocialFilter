//
//  diplomAppDelegate.h
//  diplom
//
//  Created by admin on 08.10.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "IGConnect.h"
#import "FacebookAlbumViewController.h"
#import "Reachability.h"

@class FacebookAlbumViewController;

@interface diplomAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain)  FacebookAlbumViewController *facebookController;
@property (strong, nonatomic) Instagram *instagram;
@property (nonatomic) BOOL internet;


@end
