//
//  diplomViewController.h
//  diplom
//
//  Created by admin on 08.10.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "Vkontakte.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MessageUI/MessageUI.h>
#import "StandardFilters.h"
#import "diplomAppDelegate.h"
#import "CircleBlur.h"
#import "ShareViewController.h"
#import "UIViewController+JTRevealSidebarV2.h"
#import "UINavigationItem+JTRevealSidebarV2.h"
#import "JTRevealSidebarV2Delegate.h"

@interface MainEditViewController : UIViewController < UINavigationControllerDelegate,UIAlertViewDelegate, VkontakteViewControllerDelegate,VkontakteDelegate, MBProgressHUDDelegate, UIGestureRecognizerDelegate,UIActionSheetDelegate, MFMailComposeViewControllerDelegate,UIScrollViewDelegate, circleBlurProtocol, JTRevealSidebarV2Delegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIImage *imageFromPicker;

@end

