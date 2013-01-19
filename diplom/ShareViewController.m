//
//  ShareViewController.m
//  Share
//
//  Created by admin on 08.01.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController()

@property (strong, nonatomic) IBOutlet UILabel *testlabel;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIView *viewWithImgTxt;
@property (nonatomic) CLLocationCoordinate2D currentLocation;
@property (strong, nonatomic) IBOutlet UIImageView *imagePreview;
@property (strong, nonatomic) Vkontakte *vkontakte;
@property (strong, nonatomic) IBOutlet UIButton *fbShare;
@property (strong, nonatomic) IBOutlet UIButton *vkShare;

-(void)sendImageToSocialNetworks;

@end

@implementation ShareViewController

@synthesize testlabel = _testlabel;
@synthesize locationManager=_locationManager;
@synthesize map = _map;
@synthesize textView = _textView;
@synthesize viewWithImgTxt = _viewWithImgTxt;
@synthesize imagePreview = _imagePreview;
@synthesize currentLocation=_currentLocation;
@synthesize imageForPreview=_imageForPreview;
@synthesize vkontakte=_vkontakte;
@synthesize fbShare = _fbShare;
@synthesize vkShare = _vkShare;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)backButton:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
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
    _imagePreview.image = _imageForPreview;
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 10.0;
    _currentLocation = CLLocationCoordinate2DMake(0, 0);
}
- (IBAction)sendButton:(id)sender {
    [self sendImageToSocialNetworks];
}

-(void)sendImageToSocialNetworks
{
    if (_vkShare.selected)
    {
        if ([_textView.text isEqualToString:@"Текст сообщения"])
            [_vkontakte postImageToWall:_imageForPreview text:@"" link:nil location:_currentLocation];
        else
            [_vkontakte postImageToWall:_imageForPreview text:_textView.text link:nil location:_currentLocation];
    }
    if (_fbShare.selected)
        NSLog(@"fbb");
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
- (IBAction)manageLocation:(UISwitch *)sender
{
    if (_map.showsUserLocation)
        _currentLocation = CLLocationCoordinate2DMake(0, 0);
    _map.showsUserLocation=!_map.showsUserLocation;
}

-(void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{ 
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 250, 250);
    [_map setRegion:region animated:YES];
   // _testlabel.text = [NSString stringWithFormat:@"%f : %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude];
    _currentLocation = userLocation.location.coordinate;
}
- (IBAction)vkButton:(UIButton *)sender 
{

    if (!sender.selected)  
    {
        _vkontakte = [Vkontakte sharedInstance];
        _vkontakte.delegate = self;
        if (![_vkontakte isAuthorized]) 
        {
            [_vkontakte authenticate];
        }
        else
        {
            sender.selected = !sender.selected;
        }
        
    }
    else
    {
        sender.selected = !sender.selected;
    }
            
}
- (IBAction)fbButton:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"epic" message:@"fail" delegate:nil cancelButtonTitle:@"okay" otherButtonTitles: nil];
    [view show];
}

- (void)viewDidUnload
{
    [self setViewWithImgTxt:nil];
    [self setImagePreview:nil];
    [self setFbShare:nil];
    [self setVkShare:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
