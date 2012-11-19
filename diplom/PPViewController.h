//
//  UIViewControllerFB.h
//  diplom
//
//  Created by admin on 28.10.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>



@interface PPViewController : UIViewController

// FBSample logic
// The views and view controllers in the SDK are designed to fit into your application in 
// a similar fashion to other framework and custom view classes; this is an example of a 
// typical outlet for the FBPriflePictureView
@property (retain, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (retain, nonatomic) IBOutlet UIView *profilePictureOuterView;

- (IBAction)showJasonProfile:(id)sender;
- (IBAction)showMichaelProfile:(id)sender;
- (IBAction)showVijayeProfile:(id)sender;
- (IBAction)showRandomProfile:(id)sender;
- (IBAction)showNoProfile:(id)sender;
- (IBAction)makePictureOriginal:(id)sender;
- (IBAction)makePictureSquare:(id)sender;

- (IBAction)makeViewSmall:(id)sender;
- (IBAction)makeViewLarge:(id)sender;

@end