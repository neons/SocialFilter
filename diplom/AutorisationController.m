//
//  AutorisationController.m
//  diplom
//
//  Created by admin on 18.10.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AutorisationController.h"
#import "diplomViewController.h"

@interface AutorisationController()

@property (nonatomic, weak) UIImage *imageFrEdt;
@property (strong, nonatomic)     UIImagePickerController * picker;

@end
@implementation AutorisationController 
@synthesize imageFrEdt=_imageFrEdt;
@synthesize picker=_picker;
 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (IBAction)cameraActionButton:(id)sender
{
    _picker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    else
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    
    _picker.delegate = self;
    _picker.allowsEditing = YES;
    [self presentModalViewController:_picker animated:YES];
}

- (IBAction)cameraRollButton:(id)sender
{

    _picker = [[UIImagePickerController alloc] init];
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _picker.allowsEditing = NO;
    _picker.delegate = self;
    [self presentModalViewController:_picker animated:YES];
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (UIImagePickerControllerSourceTypePhotoLibrary==picker.sourceType) {
        
         _imageFrEdt=[info objectForKey:UIImagePickerControllerOriginalImage];
        
        GKImageCropViewController *cropController = [[GKImageCropViewController alloc] init];
        cropController.sourceImage = _imageFrEdt;
        cropController.cropSize = CGSizeMake(320, 320);
        cropController.delegate = self;
        [picker dismissModalViewControllerAnimated:NO];
        [self.navigationController pushViewController:cropController animated:YES];
 
    }
    
    else
    {
    _imageFrEdt=[info objectForKey:UIImagePickerControllerEditedImage];
        [picker dismissModalViewControllerAnimated:YES];
     [self performSegueWithIdentifier:@"PhotoEditorSegue" sender:self]; 
    }
}


- (void)imageCropController:(GKImageCropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage
{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle: nil];    
    
    
    diplomViewController *controller = (diplomViewController*)[mainStoryboard 
                                                               instantiateViewControllerWithIdentifier: @"filterController"];
    controller.imageFromPicker = croppedImage;
    [self.navigationController pushViewController:controller animated:YES]; 
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PhotoEditorSegue"]) 
    {
        [segue.destinationViewController setImageForEdit:_imageFrEdt];        
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.navigationController.navigationBarHidden=YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

- (void)viewDidUnload
{
     [super viewDidUnload];   
}








@end
