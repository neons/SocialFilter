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

@interface diplomViewController : UIViewController < UINavigationControllerDelegate,UIAlertViewDelegate, VkontakteViewControllerDelegate,VkontakteDelegate, MBProgressHUDDelegate, UIGestureRecognizerDelegate,UIActionSheetDelegate, MFMailComposeViewControllerDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) UIImage *imageFromPicker;

-(void)setImageForEdit:(UIImage *)ImageForEdit;
@end

