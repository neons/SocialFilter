//
//  UITableViewVkAlbumsController.m
//  diplom
//
//  Created by admin on 04.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VkAlbumViewController.h"
@interface VkAlbumViewController()

@property (nonatomic, strong ) NSMutableDictionary *staticImageDictionary;
@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation VkAlbumViewController

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    [self createTable];
}

-(void)createTable{
    _vkontakte = [Vkontakte sharedInstance];
    _vkontakte.delegate = self;
    if (![_vkontakte isAuthorized]) {
        [_vkontakte authenticate];
    }
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.tableView addSubview:_hud];
	_hud.dimBackground = YES;
    [_hud show:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [_vkontakte getUserAlbumsCount];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            [_hud hide:YES];
            [_hud removeFromSuperview];
            _hud = nil;
        });
    });

}

- (void)vkontakteDidFinishGettinUserAlbumsCount:(NSDictionary *)info;{
    _dictionaryOfAlbums = info;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dictionaryOfAlbums count];
}
- (UIImage*)imageNamed:(NSString*)imageNamed cache:(BOOL)cache{
    UIImage* retImage = _staticImageDictionary[imageNamed];
    if (retImage == nil){
        retImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageNamed]]];
        
        if (cache){
            if (_staticImageDictionary == nil)
                _staticImageDictionary = [[NSMutableDictionary alloc] init];
            
            if (imageNamed) {
                [_staticImageDictionary setObject:retImage forKey:imageNamed];
            }
        }               
    }
    return retImage;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{ 
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"albumsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];}
    NSDictionary *currentDictionary=[NSDictionary new];
    currentDictionary = [_dictionaryOfAlbums objectForKey:[NSString stringWithFormat:@"Album%i",indexPath.row+1]];
    cell.textLabel.text = currentDictionary[@"title"];
    NSString *photoUrl = currentDictionary[@"thumb_src"];
    cell.imageView.image = [self imageNamed:photoUrl cache:YES];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ photos",currentDictionary[@"size"]];
    
    return cell;
}

#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error{
    NSLog(@"faaail %@",error);
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showVkontakteAuthController:(UIViewController *)controller{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentModalViewController:controller animated:YES];
}

- (void)vkontakteAuthControllerDidCancelled{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte{
    [self dismissModalViewControllerAnimated:YES];
    [_vkontakte getUserAlbumsCount];
    [self.tableView reloadData];
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte{
    NSLog(@"vk finish logout");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    diplomAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if (delegate.internet){
    NSDictionary *currentDictionary=[NSDictionary new];
    
    currentDictionary = [_dictionaryOfAlbums objectForKey:[NSString stringWithFormat:@"Album%i",indexPath.row+1]];
    NSString *aid=currentDictionary[@"aid"];
        if(![aid isKindOfClass:[NSString class]]){
            aid = [(NSNumber*)aid stringValue];
        }
  
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle: nil];    
    
    VkPhotosViewController *controller = (VkPhotosViewController*)[mainStoryboard
                                                               instantiateViewControllerWithIdentifier: @"vkPhotoController"];
    controller.aid = aid;
    [self.navigationController pushViewController:controller animated:YES];
    }
    else{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                            message:@"Отсутствует интернет подключение"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

@end
