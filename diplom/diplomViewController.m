//
//  diplomViewController.m
//  diplom
//
//  Created by admin on 08.10.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "diplomViewController.h"
@interface diplomViewController()
@property (strong, nonatomic)     MBProgressHUD *hud;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (nonatomic) NSInteger currentFilterTag; 
@property (strong, nonatomic) NSMutableArray *arrayWhithPhoto;
@property (strong, nonatomic) Vkontakte *vkontakte;
@property (strong, nonatomic) UIImage *nonFilterImage;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIScrollView *horizontalScroll;
@property (strong, nonatomic) IBOutlet UIScrollView *parametersButtonScroll;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonBrush;
@property (strong, nonatomic) IBOutlet UILabel *countLayers;




@end

@implementation diplomViewController
@synthesize hud=_hud;
@synthesize slider=_slider;
@synthesize mainImage=_mainImage;
@synthesize vkontakte=_vkontakte;
@synthesize nonFilterImage=_nonFilterImage;
@synthesize horizontalScroll=_horizontalScroll;
@synthesize parametersButtonScroll = _parametersButtonScroll;
@synthesize barButtonBrush = _barButtonBrush;
@synthesize countLayers = _countLayers;
@synthesize imageFromPicker=_imageFromPicker;
@synthesize currentFilterTag=_currentFilterTag;
@synthesize arrayWhithPhoto=_arrayWhithPhoto;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setImageForEdit:(UIImage *)ImageForEdit;
{
     _imageFromPicker=ImageForEdit;
    
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _slider.hidden = YES;
    _parametersButtonScroll.hidden = YES;
}

- (IBAction)buttonback:(id)sender 
{
    [[self navigationController] popViewControllerAnimated:YES];
}


-(void) saveMyImage
{
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:_hud];
	_hud.dimBackground = YES;
    _hud.delegate = self;
    [_hud show:YES];

    ALAssetsLibrary *photo=[[ALAssetsLibrary alloc]init];
    [photo writeImageToSavedPhotosAlbum:[[_mainImage image]CGImage] orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
        [_hud hide:YES];
        [_hud removeFromSuperview];
        _hud = nil;
        
    }];
}
- (IBAction)actionButton:(id)sender 
{
    _slider.hidden=YES;
    _parametersButtonScroll.hidden = YES;
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self 
                                                 cancelButtonTitle:@"Cancel" 
                                            destructiveButtonTitle:nil 
                                                 otherButtonTitles:@"Save Photo", @"Email",@"share in VK",nil];
    actSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    switch (buttonIndex) {
        case 0:{
            _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:_hud];
            _hud.dimBackground = YES;
            _hud.delegate = self;
            [_hud show:YES];
            
            ALAssetsLibrary *photo=[[ALAssetsLibrary alloc]init];
            [photo writeImageToSavedPhotosAlbum:[[_mainImage image]CGImage] orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
                [_hud hide:YES];
                [_hud removeFromSuperview];
                _hud = nil;
                
            }];}
            break;
        case 1:
        {
            if ([MFMailComposeViewController canSendMail] == true) 
            {
                MFMailComposeViewController * mail = [[MFMailComposeViewController alloc] init];    
                mail.mailComposeDelegate = self;    
                [mail setSubject:@"SocialFilter"];
                
                NSData *file= UIImagePNGRepresentation([_mainImage image]);
                [mail addAttachmentData:file mimeType:@"application/octet-stream" fileName:@"SocialFilter.png"];
                [self presentModalViewController:mail animated:true];    
            }
            else
            {
                NSLog(@"fail");
                UIAlertView * message = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Не настроена учётная запись для отправки почты" delegate:nil cancelButtonTitle:@"Готово" otherButtonTitles:nil];
                [message show];
            }
            
        }
            break;
        case 2:
        {
            if (![_vkontakte isAuthorized]) 
            {
                [_vkontakte authenticate];
            }
            
             _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
             [self.navigationController.view addSubview:_hud];
             _hud.dimBackground = YES;
             _hud.delegate = self;
             [_hud show:YES];
             
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                [_vkontakte postImageToWall:[_mainImage image]];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                     [_hud hide:YES];
                     [_hud removeFromSuperview];
                     _hud = nil;
                     
                    
                });
            });
        }
            break;
        
        default:
            
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"YES"])
    {
        [self saveMyImage];
    }
    else if([title isEqualToString:@"NOOOOO!!!1"])
    {
        
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _horizontalScroll.contentSize=CGSizeMake(3545, 74);
     _vkontakte = [Vkontakte sharedInstance];
    _vkontakte.delegate = self;
    _parametersButtonScroll.hidden = YES;
    _slider.hidden=YES;
   
    
    if (_imageFromPicker)
    {
        [_mainImage setImage:_imageFromPicker];
        self.nonFilterImage=_imageFromPicker;
        _arrayWhithPhoto=[[NSMutableArray alloc] initWithObjects:_imageFromPicker, nil];
    }
    else
    NSLog(@"hmm epic fail");       
}


- (void)viewDidUnload
{
    _mainImage = nil;
    [self setMainImage:nil];
    [self setHorizontalScroll:nil];
    [self setSlider:nil];
    [self setParametersButtonScroll:nil];
    [self setBarButtonBrush:nil];
    [self setCountLayers:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    [super viewWillAppear:animated];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _parametersButtonScroll.hidden = YES;
    _slider.hidden=YES;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[[self navigationController] view] setFrame:[[UIScreen mainScreen] bounds]];

	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}



- (IBAction)defaultfilterbutton:(UIButton *)sender 
{
    [_mainImage setImage:_nonFilterImage];
    
}


-(IBAction) addFilterToCurrentImage:(UIButton *)sender
{
    _slider.hidden=YES;
    _parametersButtonScroll.hidden = YES;
    UIImage *quickFilteredImage;
    switch (sender.tag)
    {
        case 6:
        {
           
            StandardFilter1 *stillImageFilter = [[StandardFilter1 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
        case 7:
        {    
            GPUImageSketchFilter *stillImageFilter = [[GPUImageSketchFilter alloc] init];
           quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        } 
            break;
        case 8:
        { 
            GPUImageBoxBlurFilter *stillImageFilter = [[GPUImageBoxBlurFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }  
            
            break;
        case 9:
        {
            GPUImageSepiaFilter *stillImageFilter = [[GPUImageSepiaFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
            
        case 10:
        {
            GPUImageMissEtikateFilter *stillImageFilter = [[GPUImageMissEtikateFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            
            
            break;
        case 11:
        {
            GPUImageSmoothToonFilter *stillImageFilter = [[GPUImageSmoothToonFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            
            break;
        case 12:
        {
            StandardFilter7 *stillImageFilter = [[StandardFilter7 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            
            break;
        case 13:
        {
            StandardFilter2 *stillImageFilter = [[StandardFilter2 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
            
        case 14:
        {
            GPUImageHazeFilter *stillImageFilter = [[GPUImageHazeFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
            
        case 15:
        {
            GPUImageAmatorkaFilter *stillImageFilter = [[GPUImageAmatorkaFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
            
        case 16:
        {
            StandardFilter4 *stillImageFilter = [[StandardFilter4 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
            
        case 17:
        {
            StandardFilter3 *stillImageFilter = [[StandardFilter3 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
            
        case 18:
        {
            GPUImageSoftEleganceFilter *stillImageFilter = [[GPUImageSoftEleganceFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
            
        case 19:
        {
            StandardFilter5 *stillImageFilter = [[StandardFilter5 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
            
        case 20:
        {
            StandardFilter6 *stillImageFilter = [[StandardFilter6 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
            
        case 21:
        {
            StandardFilter8 *stillImageFilter = [[StandardFilter8 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
            
        case 22:
        {
            [sender setTitle:@"" forState:UIControlStateNormal];
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            spinner.frame = sender.bounds;
            [spinner startAnimating];
            [sender addSubview:spinner];
            sender.enabled = NO;
            
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                GPUImageKuwaharaFilter *stillImageFilter = [[GPUImageKuwaharaFilter alloc] init];
                UIImage *quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    [spinner removeFromSuperview];
                    [sender setTitle:@"kuwahara" forState:UIControlStateNormal];
                    sender.enabled = YES;
                    [_mainImage setImage:quickFilteredImage];
                    
                });
            });
        }
            break;
            
        case 23:
        {
            FishEyeFilter *stillImageFilter = [[FishEyeFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
            
        case 24:
        {
            UfoFilter *stillImageFilter = [[UfoFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
            
        case 25:
        {
            EdgeeFilter *stillImageFilter = [[EdgeeFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
            
        case 26:
        {
            VinnyFilter *stillImageFilter = [[VinnyFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
            
        case 27:
        {
            PenSketchFilter *stillImageFilter = [[PenSketchFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            break;
            
        case 28:
        {
             MakeMeTallFilter*stillImageFilter = [[MakeMeTallFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
        }
            
            break;
       
        default:
            NSLog(@" filter fail");
            break;
    }
    if (sender.tag !=22)
    [_mainImage setImage:quickFilteredImage];

}

- (IBAction)parametersBarButton:(id)sender
{
    _parametersButtonScroll.hidden =    !(_parametersButtonScroll.hidden );
}

-(IBAction) changePhotoParameters:(UIButton *)sender
{
    [_mainImage setImage:[_arrayWhithPhoto lastObject]];
    switch (sender.tag)
    {
        case 1:
        
            _slider.minimumValue= -10;
            _slider.maximumValue= 10;
            _slider.value = 0;
            //-10.0 - 10.0, with 0.0 as the default
        
            break;
        case 2:
        
            _slider.minimumValue= -1;
            _slider.maximumValue= 1;
            _slider.value = 0;
            //-1.0 - 1.0, with 0.0 as the default
        
            break;
        case 3:
        
            _slider.minimumValue= 0;
            _slider.maximumValue= 4;
            _slider.value = 1;
            //0.0 - 4.0, with 1.0 as the default
        
            break;
        case 4:
        
            _slider.minimumValue= 0;
            _slider.maximumValue= 2;
            _slider.value = 1;
            //0.0 - 2.0, with 1.0 as the default
        
            break;
        
        case 5:
        
            _slider.minimumValue= 0;
            _slider.maximumValue= 3;
            _slider.value = 1;
            //0.0 - 3.0, with 1.0 as the default
        
            break;
            
        default:
            _slider.hidden=YES;
            break;

    
    }
    _currentFilterTag=sender.tag;
    if (sender.tag!=0)
    _slider.hidden = NO;    
}
- (IBAction)showSliderWithParameters:(id)sender
{
    
    switch (_currentFilterTag)
    {
        case 1:
        {
            GPUImageExposureFilter *stillImageFilter = [[GPUImageExposureFilter alloc] init];
            stillImageFilter.exposure=_slider.value;  
            UIImage *quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
            [_mainImage setImage:quickFilteredImage];
            //-10.0 - 10.0, with 0.0 as the default
            
        }
            break;
        case 2:
        {
            GPUImageBrightnessFilter *stillImageFilter = [[GPUImageBrightnessFilter alloc] init];
            stillImageFilter.brightness = _slider.value;
            UIImage *quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
            [_mainImage setImage:quickFilteredImage];
            //-1.0 - 1.0, with 0.0 as the default
        }
            break;
        case 3:
        {
            GPUImageContrastFilter *stillImageFilter = [[GPUImageContrastFilter alloc] init];
            stillImageFilter.contrast = _slider.value;
            UIImage *quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
            [_mainImage setImage:quickFilteredImage];
            //0.0 - 4.0, with 1.0 as the default
        }
            break;
        case 4:
        {
            GPUImageSaturationFilter *stillImageFilter = [[GPUImageSaturationFilter alloc] init];
            stillImageFilter.saturation = _slider.value;
            UIImage *quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
            [_mainImage setImage:quickFilteredImage];
            //0.0 - 2.0, with 1.0 as the default
        }
            break;
            
        case 5:
        {
            GPUImageGammaFilter *stillImageFilter = [[GPUImageGammaFilter alloc] init];
            stillImageFilter.gamma = _slider.value;
            UIImage *quickFilteredImage = [stillImageFilter imageByFilteringImage:[_arrayWhithPhoto lastObject]];
            [_mainImage setImage:quickFilteredImage];
            //0.0 - 3.0, with 1.0 as the default
        }
            break;
            
        default:
            
            break;
            
    }

}



- (IBAction)managePhotosArray:(UIBarButtonItem *)sender
{
    _slider.hidden=YES;
    _parametersButtonScroll.hidden = YES;
    switch (sender.tag) {
        case 1:
        
            if ((_mainImage.image != _nonFilterImage) & !([_mainImage.image isEqual: [_arrayWhithPhoto lastObject]]))
            {
                [_arrayWhithPhoto addObject: _mainImage.image];
            }
            _countLayers.text =[NSString stringWithFormat:@"%i", [ _arrayWhithPhoto count]];
            break;
            
        case 2:
        
            if ([_arrayWhithPhoto count] == 1)
                [_mainImage setImage:_nonFilterImage];
            else if ([[_mainImage image] isEqual:[_arrayWhithPhoto lastObject]])
            {
                [_arrayWhithPhoto removeLastObject];
                [_mainImage setImage:[_arrayWhithPhoto lastObject]];
            }
            else
            {
                [_mainImage setImage:[_arrayWhithPhoto lastObject]];

            }
            _countLayers.text =[NSString stringWithFormat:@"%i", [ _arrayWhithPhoto count]];
            break;
      
        default:
            break;
    }
     

}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error 
{   
    switch (result)    
    {        
        case MFMailComposeResultCancelled:            
            NSLog(@"Result: canceled");            
            break;        
        case MFMailComposeResultSaved:            
            NSLog(@"Result: saved");            
            break;        
        case MFMailComposeResultSent: {           
            NSLog(@"Result: sent");
            UIAlertView * message = [[UIAlertView alloc] initWithTitle:@"Уведомление" message:@"Изображение успешно отправлено по e-mail" delegate:nil cancelButtonTitle:@"Готово" otherButtonTitles:nil];
            [message show];
        }
            break;        
            
        case MFMailComposeResultFailed:            
            NSLog(@"Result: failed");            
            break;        
        default:            
            NSLog(@"Result: not sent");            
            break;    
    }    
    [self dismissModalViewControllerAnimated:true];
}

#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error
{
    NSLog(@"fail");
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
    // [sharedVkButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:_hud];
    _hud.dimBackground = YES;
    _hud.delegate = self;
    [_hud show:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [_vkontakte postImageToWall:[_mainImage image]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [_hud hide:YES];
            [_hud removeFromSuperview];
            _hud = nil;
            
            
        });
    });
    
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte
{
    
}


@end
