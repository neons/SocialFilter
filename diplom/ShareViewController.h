//
//  ShareViewController.h
//  Share
//
//  Created by admin on 08.01.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import "CoreLocation/CoreLocation.h"
#import "QuartzCore/QuartzCore.h"
#import "FBConnect.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MessageUI/MessageUI.h>
#import "Vkontakte.h"

@interface ShareViewController : UIViewController <UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITextViewDelegate, VkontakteViewControllerDelegate,VkontakteDelegate,MBProgressHUDDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UIImage *imageForPreview;


@end
