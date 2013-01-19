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
#import "FBConnect.h"
#import "CircleBlur.h"
#import "ShareViewController.h"

@interface diplomViewController : UIViewController < UINavigationControllerDelegate,UIAlertViewDelegate, VkontakteViewControllerDelegate,VkontakteDelegate, MBProgressHUDDelegate, UIGestureRecognizerDelegate,UIActionSheetDelegate, MFMailComposeViewControllerDelegate,UIScrollViewDelegate, circleBlurProtocol>

@property (strong, nonatomic) UIImage *imageFromPicker;

@end

