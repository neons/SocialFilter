//
//  UIViewControllerFacebookPhotos.h
//  diplom
//
//  Created by admin on 24.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewControllerFacebookAlbums.h"
#import "UITableViewCellCustomWithImage.h"
#import "diplomViewController.h"
#import "GKImageCropViewController.h"
#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@interface UIViewControllerFacebookPhotos : UIViewController <UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate,GKImageCropControllerDelegate,MBProgressHUDDelegate>

@property (strong, nonatomic) NSString *albumsId;

@end
