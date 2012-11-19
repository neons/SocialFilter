//
//  UITableViewVkAlbumsController.m
//  diplom
//
//  Created by admin on 04.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewVkAlbumsController.h"
@interface UITableViewVkAlbumsController()
@property (nonatomic, strong ) NSMutableDictionary * staticImageDictionary;
@property (strong, nonatomic)     MBProgressHUD *hud;

-(void) createTable;



@end

@implementation UITableViewVkAlbumsController
@synthesize dictionaryOfAlbums=_dictionaryOfAlbums;
@synthesize vkontakte=_vkontakte;
@synthesize tableView=_tableView;
@synthesize staticImageDictionary=_staticImageDictionary;
@synthesize hud=_hud;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createTable];

}

-(void)createTable
{
    _vkontakte = [Vkontakte sharedInstance];
    _vkontakte.delegate = self;
    if (![_vkontakte isAuthorized]) 
    {
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

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (void)vkontakteDidFinishGettinUserAlbumsCount:(NSDictionary *)info;
{
    _dictionaryOfAlbums = info;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_dictionaryOfAlbums count];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"albumsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];}
    NSDictionary *currentDictionary=[[NSDictionary alloc]init];
    currentDictionary = [_dictionaryOfAlbums objectForKey:[NSString stringWithFormat:@"Album%i",indexPath.row+1]];
    cell.textLabel.text = [currentDictionary objectForKey:@"title"];
    NSString *photoUrl = [currentDictionary objectForKey:@"thumb_src"];
    cell.imageView.image = [self imageNamed:photoUrl cache:YES];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ photos",[currentDictionary objectForKey:@"size"]];
    
    return cell;
}

#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error
{
    NSLog(@"faaail %@",error);
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)showVkontakteAuthController:(UIViewController *)controller
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentModalViewController:controller animated:YES];
}

- (void)vkontakteAuthControllerDidCancelled
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte
{
    [self dismissModalViewControllerAnimated:YES];
    [_vkontakte getUserAlbumsCount];
    [[self tableView]reloadData];
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    NSDictionary *currentDictionary=[[NSDictionary alloc]init];
    
    currentDictionary = [_dictionaryOfAlbums objectForKey:[NSString stringWithFormat:@"Album%i",indexPath.row+1]];
    NSString *aid=[currentDictionary objectForKey:@"aid"];
  
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle: nil];    
    
    
    UITableViewControllerForVkPhotos *controller = (UITableViewControllerForVkPhotos*)[mainStoryboard 
                                                               instantiateViewControllerWithIdentifier: @"vkPhotoController"];
    controller.aid = aid;
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (IBAction)backButton:(id)sender 
{
    [[self navigationController] popViewControllerAnimated:YES];

}



@end
