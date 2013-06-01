//
//  UITableViewControllerForVkPhotos.h
//  diplom
//
//  Created by admin on 04.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vkontakte.h"
#import "CustomTableCellWithImage.h"
#import "MainEditViewController.h"
#import "GKImageCropViewController.h"
#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@interface VkPhotosViewController : UIViewController <VkontakteDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource,GKImageCropControllerDelegate, MBProgressHUDDelegate>

@property (strong,nonatomic ) NSString *aid;

-(void)pickImageForEdit:(id)sender;

@end
