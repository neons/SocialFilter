//
//  AutorisationController.m
//  diplom
//
//  Created by admin on 18.10.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AutorisationViewController.h"
#import "MainEditViewController.h"

@interface AutorisationViewController()

@property (strong, nonatomic) UIImagePickerController *picker;

@end


@implementation AutorisationViewController

- (IBAction)cameraActionButton:(id)sender{
    _picker = [[UIImagePickerController alloc] init];
     _picker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _picker.allowsEditing = YES;
    }
    else{
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _picker.allowsEditing = NO;
    }
    [self presentModalViewController:_picker animated:YES];
}

- (IBAction)cameraRollButton:(id)sender{
    _picker = [[UIImagePickerController alloc] init];
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _picker.allowsEditing = NO;
    _picker.delegate = self;
    [self presentModalViewController:_picker animated:YES];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    if (UIImagePickerControllerSourceTypePhotoLibrary==picker.sourceType) {
        GKImageCropViewController *cropController = [[GKImageCropViewController alloc] init];
        cropController.sourceImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        cropController.cropSize = CGSizeMake(320, 320);
        cropController.delegate = self;
        [picker dismissModalViewControllerAnimated:NO];
        [self.navigationController pushViewController:cropController animated:YES];
    }
    else{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                                 bundle: nil];    
        
        MainEditViewController *controller = (MainEditViewController*)[mainStoryboard                                instantiateViewControllerWithIdentifier: @"filterController"];
        controller.imageFromPicker = [info objectForKey:UIImagePickerControllerEditedImage];
        [picker dismissModalViewControllerAnimated:NO];
        [self.navigationController pushViewController:controller animated:YES]; 
    }
}


- (void)imageCropController:(GKImageCropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle: nil];
    MainEditViewController *controller = (MainEditViewController*)[mainStoryboard 
                                                               instantiateViewControllerWithIdentifier: @"filterController"];
    controller.imageFromPicker = croppedImage;
    [self.navigationController pushViewController:controller animated:YES];
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqual:@"settingsSegue"])
        return YES;
    
    diplomAppDelegate *delegate = [UIApplication sharedApplication].delegate;
     if (delegate.internet)
        return YES;
    else{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                            message:@"Отсутствует интернет подключение"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

-(void) viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];    
    [super viewWillDisappear:animated];
}


-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:animated];
}

@end
