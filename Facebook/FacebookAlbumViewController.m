//
//  UIViewControllerFacebookAlbums.m
//  diplom
//
//  Created by admin on 24.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookAlbumViewController.h"


@interface FacebookAlbumViewController()

@property (nonatomic, strong) NSArray *arrayofAlbums;
@property (nonatomic, strong ) NSMutableDictionary * staticImageDictionary;
@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation FacebookAlbumViewController

#pragma mark - View lifecycle


- (void)viewDidLoad{
    [super viewDidLoad];
    [self createTable];
}
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error{
    switch (state) {
        case FBSessionStateOpen: {
            [FBRequestConnection startWithGraphPath:@"me/albums?fields=count,photos.fields(picture),description,name" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                _arrayofAlbums=[result objectForKey:@"data"];
                [_tableView reloadData];
                [_hud hide:YES];
                [_hud removeFromSuperview];
                _hud = nil;
            }];
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
         
            [FBSession.activeSession closeAndClearTokenInformation];
            
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(void) createTable{
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.tableView addSubview:_hud];
	_hud.dimBackground = YES;
    _hud.labelText = @"Загрузка";
    [_hud show:YES];
    
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection startWithGraphPath:@"me/albums?fields=count,photos.fields(picture),description,name" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            _arrayofAlbums=[result objectForKey:@"data"];
            [_tableView reloadData];
            [_hud hide:YES];
            [_hud removeFromSuperview];
            _hud = nil;
        }];
    }
    else{
         NSArray * permissions = [[NSArray alloc] initWithObjects:@"offline_access",@"publish_stream",@"user_photos", nil];
               [FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            [self sessionStateChanged:session state:status error:error];
        }];
    }
}


- (UIImage*)imageNamed:(NSString*)imageNamed cache:(BOOL)cache
{
    UIImage* retImage = [_staticImageDictionary objectForKey:imageNamed];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_arrayofAlbums count];
}



- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}



#pragma mark - UITableViewDatasource and UITableViewDelegate Methods



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { 
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"FacebookCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];}
    NSDictionary *currentDictionary=[[NSDictionary alloc]init];
    currentDictionary = [_arrayofAlbums objectAtIndex:indexPath.row];
    cell.textLabel.text = currentDictionary[@"name"];
    
    NSString *photo = [NSString stringWithFormat:@"%@",currentDictionary[@"photos"][@"data"][0][@"picture"]];
    cell.imageView.image = [self imageNamed:photo cache:YES];
    cell.detailTextLabel.text =[NSString stringWithFormat:@"%@",[currentDictionary objectForKey:@"count"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    diplomAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if (delegate.internet) {
        NSString *albumsId = [[_arrayofAlbums objectAtIndex:indexPath.row] objectForKey:@"id"];
        NSLog(@"albumsId %@",albumsId);
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                                 bundle: nil];
        FacebookPhotosViewController *controller = (FacebookPhotosViewController*)[mainStoryboard
                                                                                       instantiateViewControllerWithIdentifier: @"FacebookPhotos"];
        controller.albumsId = albumsId;
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
