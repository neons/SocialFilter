//
//  UIViewControllerFB.m
//  diplom
//
//  Created by admin on 28.10.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PPViewController.h"

// FBSample logic
// You may set the profile for an FBProfilePictureView to either an fbid
// or to a vanity name for the profile; the following list provides
// examples of each approach, used by the random feature of the sample
const char *interestingIDs[] = {
    "zuck",
    // Recent Presidents and nominees
    "barackobama",
    "mittromney",
    "johnmccain",
    "johnkerry",
    "georgewbush",
    "algore",
    // Places too!
    "Disneyland",
    "SpaceNeedle",
    "TourEiffel",
    "sydneyoperahouse",
    // A selection of 1986 Mets
    "166020963458360",
    "108084865880237",
    "140447466087679",
    "111825495501392",
    // The cast of Saved by the Bell
    "108168249210849",
    "TiffaniThiessen",
    "108126672542534",
    "112886105391693",
    "MarioLopezExtra",
    "108504145837165",
    "dennishaskins",
    // Eighties bands that have been to Moscow 
    "7220821999",
    "31938132882",
    "108023262558391",
    "209263392372",
    "104132506290482",
    "9721897972",
    "5461947317",
    "57084011597",
    // Three people that have never been in my kitchen
    "24408579964",
    "111980872152571",
    "112427772106500",
    // Trusted anchormen
    "113415525338717",
    "105628452803615",
    "105533779480538",
};
const int kNumInterestingIDs = sizeof(interestingIDs) / sizeof(interestingIDs[0]);

@interface PPViewController ()

@end

@implementation PPViewController
@synthesize profilePictureView;
@synthesize profilePictureOuterView;

- (IBAction)showJasonProfile:(id)sender {
    // FBSample logic
    // The following example uses an fbid to indicate which profile
    // picture to display, however a vanity name would work as well
    profilePictureView.profileID = @"100002768941660";
}


- (IBAction)backButton:(id)sender {
    // FBSample logic
    // The following example uses an fbid to indicate which profile
    // picture to display, however a vanity name would work as well
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)showMichaelProfile:(id)sender {
    // FBSample logic
    // This example and the one after it, in contrast to the prvious one, 
    // uses a vanity name to indicate which profile picture to display
    profilePictureView.profileID = @"michael.marucheck";
}


- (IBAction)showVijayeProfile:(UIButton *)sender {
    profilePictureView.profileID = @"45963418107";
}


- (IBAction)showRandomProfile:(id)sender {
    int index = arc4random() % kNumInterestingIDs;
    profilePictureView.profileID = [NSString stringWithCString:interestingIDs[index]
                                                      encoding:NSASCIIStringEncoding];
}

- (IBAction)showNoProfile:(id)sender {
    profilePictureView.profileID =  @"ne0nes";//45963418107
}

// Cropping selections

// FBSample logic
// Set the cropping for the profile picture view
- (IBAction)makePictureOriginal:(id)sender {
    profilePictureView.pictureCropping = FBProfilePictureCroppingOriginal;
}

- (IBAction)makePictureSquare:(id)sender {
    profilePictureView.pictureCropping = FBProfilePictureCroppingSquare;
}


// View size mods

- (IBAction)makeViewSmall:(id)sender {
    profilePictureOuterView.bounds = CGRectMake(0, 0, 100, 100);
}

- (IBAction)makeViewLarge:(id)sender {
    profilePictureOuterView.bounds = CGRectMake(0, 0, 220, 220);
}

#pragma mark -
#pragma mark Template generated code

- (void)viewDidLoad {
    [super viewDidLoad];
    [FBProfilePictureView class];
    [self makeViewLarge:nil];
   //[profilePictureView initWithProfileID:@"45963418107" pictureCropping:NO];
    profilePictureView.profileID = @"45963418107"; // Hello world
   
}

- (void)viewDidUnload {
    self.profilePictureView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
        return NO; 
} 

@end
