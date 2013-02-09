//
//  UIViewControllerFacebookAlbums.m
//  diplom
//
//  Created by admin on 24.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIViewControllerFacebookAlbums.h"


@interface UIViewControllerFacebookAlbums()

@property (nonatomic, strong) NSArray *arrayofAlbums;
@property (nonatomic, strong ) NSMutableDictionary * staticImageDictionary;
@property (strong, nonatomic)     MBProgressHUD *hud;

-(void)createTable;

@end

@implementation UIViewControllerFacebookAlbums



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (IBAction)getAlbumsTestMethod:(UIBarButtonItem *)sender
{
    sender.enabled = NO;
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.tableView addSubview:_hud];
	_hud.dimBackground = YES;
    [_hud show:YES];
    diplomAppDelegate *delegate = (diplomAppDelegate *)[[UIApplication sharedApplication] delegate];
    
   // [[delegate facebook] requestWithGraphPath:@"me/albums?fields=count,photos.fields(picture),description,name" andDelegate:self];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self createTable];
    
}
-(void) createTable
{
    
    diplomAppDelegate *delegate = (diplomAppDelegate *)[[UIApplication sharedApplication] delegate];
  /*  if (![[delegate facebook] isSessionValid])
    {
        NSArray * permissions = [[NSArray alloc] initWithObjects:@"offline_access",@"publish_stream",@"user_photos", nil];
        [[delegate facebook] authorize:permissions];
        NSLog(@"not valid");
        
    } 
    
    else 
        
    {
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.tableView addSubview:_hud];
        _hud.dimBackground = YES;
        [_hud show:YES];

        NSLog(@"valid");
        diplomAppDelegate *delegate = (diplomAppDelegate *)[[UIApplication sharedApplication] delegate];
        [[delegate facebook] requestWithGraphPath:@"me/albums?fields=count,photos.fields(picture),description,name" andDelegate:self];  
    }*/
}

- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}
- (UIImage*)imageNamed:(NSString*)imageNamed cache:(BOOL)cache
{
    UIImage* retImage = [_staticImageDictionary objectForKey:imageNamed];
    if (retImage == nil)
    {
        retImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageNamed]]];
        
        if (cache)
        {
            if (_staticImageDictionary == nil)
                _staticImageDictionary = [[NSMutableDictionary alloc] init];
            
            if (imageNamed) 
            {
                [_staticImageDictionary setObject:retImage forKey:imageNamed];
                
            }
        }               
    }
    return retImage;
}
- (void)viewDidUnload
{
    [self setTableView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)fbDidLogin {
    diplomAppDelegate *delegate = (diplomAppDelegate *)[[UIApplication sharedApplication] delegate];

  //  [self storeAuthData:[[delegate facebook] accessToken] expiresAt:[[delegate facebook] expirationDate]];

}
-(void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"did not login");
}
-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    [self storeAuthData:accessToken expiresAt:expiresAt];
}
- (void)fbDidLogout {
    NSLog(@"did logout");
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
}
- (void)request:(FBRequest *)request didLoad:(id)result {
    _arrayofAlbums=[result objectForKey:@"data"];
    [_tableView reloadData];
    [_hud hide:YES];
    [_hud removeFromSuperview];
    _hud = nil;
}
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response");

}
- (void)fbSessionInvalidated {
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Auth Exception"
                              message:@"Your session has expired."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil,
                              nil];
    [alertView show];
    [self fbDidLogout];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrayofAlbums count];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
    NSLog(@"Err details: %@", [error description]);
}





- (void)showLoggedOut {
    
    diplomAppDelegate *delegate = (diplomAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[[delegate facebook] requestWithGraphPath:@"me/permissions" andDelegate:self];
    
}







- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}



#pragma mark - UITableViewDatasource and UITableViewDelegate Methods



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    return 55;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"FacebookCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];}
    NSDictionary *currentDictionary=[[NSDictionary alloc]init];
    currentDictionary = [_arrayofAlbums objectAtIndex:indexPath.row];
    cell.textLabel.text = [currentDictionary objectForKey:@"name"];
    
    
    NSString *photo = [NSString stringWithFormat:@"%@",[[[[currentDictionary objectForKey:@"photos"] objectForKey:@"data"] objectAtIndex:0 ]objectForKey:@"picture" ]];
    cell.imageView.image = [self imageNamed:photo cache:YES];
    cell.detailTextLabel.text =[NSString stringWithFormat:@"%@", [currentDictionary objectForKey:@"count"]];
    
    
    return cell;
}




// Customize the appearance of table view cells.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *albumsId = [[_arrayofAlbums objectAtIndex:indexPath.row] objectForKey:@"id"];
    NSLog(@"albumsId %@",albumsId);
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle: nil];    
    UIViewControllerFacebookPhotos *controller = (UIViewControllerFacebookPhotos*)[mainStoryboard 
                                                                                       instantiateViewControllerWithIdentifier: @"FacebookPhotos"];
    controller.albumsId = albumsId;
    [self.navigationController pushViewController:controller animated:YES];
    
 
}

@end
