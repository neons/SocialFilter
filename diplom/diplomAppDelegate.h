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
#import "UIViewControllerFacebookAlbums.h"
#import "Reachability.h"

@class UIViewControllerFacebookAlbums;

@interface diplomAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain)  UIViewControllerFacebookAlbums *facebookController;
@property (strong, nonatomic) Instagram *instagram;
@property (nonatomic) BOOL internet;


@end
