//
//  UITableViewControllerForVkPhotos.h
//  diplom
//
//  Created by admin on 04.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vkontakte.h"
#import "UITableViewCellCustomWithImage.h"
#import "diplomViewController.h"
#import "GKImageCropViewController.h"
#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]


@interface UITableViewControllerForVkPhotos : UIViewController <VkontakteDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource,GKImageCropControllerDelegate, MBProgressHUDDelegate>
@property (strong,nonatomic) NSDictionary *dictionaryWithArrayofPhoto;
@property (strong, nonatomic) Vkontakte *vkontakte;
@property (strong,nonatomic ) NSString *aid;
@property (strong, nonatomic) NSMutableDictionary * staticImageDictionary;
@property (nonatomic, assign) CGSize cropSize;



-(void)pickImageForEdit :(id) sender;
@end
