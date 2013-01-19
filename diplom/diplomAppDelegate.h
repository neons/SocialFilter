//
//  diplomAppDelegate.h
//  diplom
//
//  Created by admin on 08.10.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "IGConnect.h"
#import "UIViewControllerFacebookAlbums.h"

@class UIViewControllerFacebookAlbums;


@interface diplomAppDelegate : UIResponder <UIApplicationDelegate>
{
    UIViewControllerFacebookAlbums *facebookController;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain)  UIViewControllerFacebookAlbums *facebookController;
@property (nonatomic, strong) Facebook *facebook;
@property (strong, nonatomic) Instagram *instagram;


@end
