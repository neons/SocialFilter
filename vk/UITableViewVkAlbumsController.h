//
//  UITableViewVkAlbumsController.h
//  diplom
//
//  Created by admin on 04.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vkontakte.h"
#import "UITableViewControllerForVkPhotos.h"
#import "diplomViewController.h"


@interface UITableViewVkAlbumsController : UIViewController<VkontakteDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong,nonatomic) NSDictionary *dictionaryOfAlbums;
@property (strong, nonatomic) Vkontakte *vkontakte; 
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
