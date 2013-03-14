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
@property (strong, nonatomic) IBOutlet UILabel *countLayers;
@property (strong, nonatomic) IBOutlet CircleBlur *circleBlurView;
@property (strong, nonatomic) UIImage * mainImageWithoutBlur;
@property (strong, nonatomic) NSArray *arrayWithTitleForTable;
@property (nonatomic, strong) UITableView *rightSidebarView;

@end

@implementation diplomViewController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)blurIt:(CircleBlur *)sender
{
 
    GPUImageGaussianSelectiveBlurFilter *stillImageFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
    stillImageFilter.excludeCircleRadius = sender.radius/320;
    stillImageFilter.excludeBlurSize = 0.05;
    CGPoint center = sender.center;
    center.x=(center.x/3.2)/100;
    center.y=(center.y/3.2)/100;
   stillImageFilter.excludeCirclePoint = center;
    
    _mainImage.image = [stillImageFilter imageByFilteringImage:_mainImageWithoutBlur];
}
- (IBAction)blurButton:(id)sender
{

    
    if (_circleBlurView.hidden){ //blur on
        if ( _slider.hidden)
        {
        _mainImageWithoutBlur = _mainImage.image;
        }
        else
        {
            _mainImageWithoutBlur = [_arrayWhithPhoto lastObject];
        }

        [self blurIt:_circleBlurView];
    }
    else { //blur off
        _mainImage.image = _mainImageWithoutBlur;
    }
    _circleBlurView.hidden = !_circleBlurView.hidden;
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _slider.hidden = YES;
   // _parametersButtonScroll.hidden = YES;
}

- (IBAction)buttonback:(id)sender 
{
    [[self navigationController] popViewControllerAnimated:YES];
}


- (IBAction)actionButton:(id)sender 
{
    _slider.hidden=YES;
   // _parametersButtonScroll.hidden = YES;
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self 
                                                 cancelButtonTitle:@"Cancel" 
                                            destructiveButtonTitle:nil 
                                                 otherButtonTitles:@"Save Photo", @"Email",@"share in VK",@"share in FB",@"Мега пост",nil];
    actSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actSheet showInView:self.view];
}

-(void) showHud: (BOOL)boolean withTitle:(NSString *)title erorr:(NSError *)erorr
{
    if (boolean)
    {
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:_hud];
        _hud.dimBackground = YES;
        _hud.delegate = self;
        _hud.labelText = title;
        [_hud show:YES];
    }
    
    else
        
    {
        _hud.mode = MBProgressHUDModeAnnularDeterminate;
        if (erorr)
            _hud.labelText = erorr.localizedDescription;
        else
            _hud.labelText = @"Успешно";
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_hud hide:YES];
            [_hud removeFromSuperview];
            _hud = nil;
        });
        
    }
}
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            [self showHud:YES withTitle:@"Отправка" erorr:nil];
           [ FBRequestConnection startForUploadPhoto:_mainImage.image completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                [self showHud:NO withTitle:nil erorr:error];
                
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

-(void) checkInternet:(NSInteger) socialNumber
{
    diplomAppDelegate *delegate = [UIApplication sharedApplication].delegate;

    if (delegate.internet) {
        if (socialNumber==2) {
            if (![_vkontakte isAuthorized])
            {
                [_vkontakte authenticate];
            }
            
            [self showHud:YES withTitle:@"Отправка" erorr:nil];
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                [_vkontakte postImageToWall:[_mainImage image]];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self showHud:NO withTitle:nil erorr:nil];
                });
            });
        }
        else
        {
            if (FBSession.activeSession.isOpen) {
                [self showHud:YES withTitle:@"Отправка" erorr:nil];
                
                [FBRequestConnection startForUploadPhoto:_mainImage.image completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    [self showHud:NO withTitle:nil erorr:error];
                    
                }];
                
            }
            else
            {
                NSArray * permissions = [[NSArray alloc] initWithObjects:@"offline_access",@"publish_stream",@"user_photos", nil];
                [FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                    [self sessionStateChanged:session state:status error:error];
                }];
            }

        }
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                            message:@"Отсутствует интернет подключение"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];

    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    switch (buttonIndex) {
        case 0:{
            [self showHud:YES withTitle:@"Сохранение" erorr:nil];

            
            ALAssetsLibrary *photo=[[ALAssetsLibrary alloc]init];
            [photo writeImageToSavedPhotosAlbum:[[_mainImage image]CGImage] orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
                [self showHud:NO withTitle:nil erorr:error];
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
            
            [self checkInternet:2];
            
           
        }
            break;
        case 3:
            
            [self checkInternet:3];

            
                                                                
            break;
 
        case 4:
            
            [self performSegueWithIdentifier:@"ShareSegue" sender:self];
            
            break;
            
        default:
            
            break;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(diplomViewController *)sender
{
    if ([[segue identifier] isEqualToString:@"ShareSegue"])
    {
        ShareViewController *destViewController = segue.destinationViewController;
        destViewController.imageForPreview = _mainImage.image;      
    }
}




#pragma mark - View lifecycle
- (void)tapOnImage {
    self.slider.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.revealSidebarDelegate = self;
    _arrayWithTitleForTable = @[@"Экспозиция",@"Яркость",@"Контраст",@"Насыщенность",@"Гамма"];
    _horizontalScroll.contentSize=CGSizeMake(3545, 74);
     _vkontakte = [Vkontakte sharedInstance];
    _vkontakte.delegate = self;
    _slider.hidden=YES;
    _circleBlurView.delegate = self;
    [self.circleBlurView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.circleBlurView action:@selector(pinch:)]];
    
    [self.mainImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnImage)]];
    [self.circleBlurView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.circleBlurView action:@selector(pan:)]];
    [[self.circleBlurView.gestureRecognizers lastObject]setMaximumNumberOfTouches:2];
    _circleBlurView.center = CGPointMake(160, 160);
    if (_imageFromPicker)
    {
        [_mainImage setImage:_imageFromPicker];
        self.nonFilterImage=_imageFromPicker;
        _arrayWhithPhoto=[[NSMutableArray alloc] initWithObjects:_imageFromPicker, nil];
    }
    else
    NSLog(@"fail");       
}
- (IBAction)sideBarButton:(UIBarButtonItem *)sender {
    [self.navigationController toggleRevealState:JTRevealedStateRight];
}


- (UIView *)viewForRightSidebar {
   
    CGRect viewFrame = self.navigationController.applicationViewFrame;
    UITableView *view = self.rightSidebarView;
    if ( ! view) {
        view = self.rightSidebarView = [[UITableView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor blackColor];
        view.separatorColor = [UIColor blackColor];
        view.dataSource = self;
        view.delegate   = self;
    }
    view.frame = CGRectMake(self.navigationController.view.frame.size.width - 270, viewFrame.origin.y, 270, viewFrame.size.height);
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    return view;
}
#pragma mark UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_arrayWithTitleForTable count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ( ! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [_arrayWithTitleForTable objectAtIndex:indexPath.row];
    cell.textLabel.textColor=[UIColor whiteColor];
    

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.rightSidebarView) {
        return @"Дополнительно";
    }
    return nil;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController setRevealedState:JTRevealedStateNo];
    if (tableView == self.rightSidebarView) {
        [self changePhotoParameters:indexPath.row+1];
    }
}


- (void)viewDidUnload
{
    _mainImage = nil;
    [self setMainImage:nil];
    [self setHorizontalScroll:nil];
    [self setSlider:nil];
   // [self setParametersButtonScroll:nil];
    [self setCountLayers:nil];
    [self setCircleBlurView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
 //   [[[self navigationController] view] setFrame:[[UIScreen mainScreen] bounds]];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[super viewWillDisappear:animated];
}


- (IBAction)defaultfilterbutton:(UIButton *)sender 
{
    [_mainImage setImage:_nonFilterImage];
}


-(IBAction) addFilterToCurrentImage:(UIButton *)sender
{
    _slider.hidden=YES;
  //  _parametersButtonScroll.hidden = YES;
    UIImage *quickFilteredImage;
    UIImage *imageForFiltering = [_arrayWhithPhoto lastObject];

    switch (sender.tag)
    {
        case 6:
        {
            StandardFilter1 *stillImageFilter = [[StandardFilter1 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            break;
        case 7:
        {    
            GPUImageSketchFilter *stillImageFilter = [[GPUImageSketchFilter alloc] init];
           quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        } 
            break;
        case 8:
        { 
            GPUImageBoxBlurFilter *stillImageFilter = [[GPUImageBoxBlurFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }  
            
            break;
        case 9:
        {
            GPUImageSepiaFilter *stillImageFilter = [[GPUImageSepiaFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            break;
            
        case 10:
        {
            GPUImageMissEtikateFilter *stillImageFilter = [[GPUImageMissEtikateFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            
            
            break;
        case 11:
        {
            GPUImageSmoothToonFilter *stillImageFilter = [[GPUImageSmoothToonFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            
            break;
        case 12:
        {
            StandardFilter7 *stillImageFilter = [[StandardFilter7 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            
            break;
        case 13:
        {
            StandardFilter2 *stillImageFilter = [[StandardFilter2 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            break;
            
        case 14:
        {
            GPUImageHazeFilter *stillImageFilter = [[GPUImageHazeFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            break;
            
        case 15:
        {
            GPUImageAmatorkaFilter *stillImageFilter = [[GPUImageAmatorkaFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            break;
            
        case 16:
        {
            StandardFilter4 *stillImageFilter = [[StandardFilter4 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            break;
            
        case 17:
        {
            StandardFilter3 *stillImageFilter = [[StandardFilter3 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            break;
            
        case 18:
        {
            GPUImageSoftEleganceFilter *stillImageFilter = [[GPUImageSoftEleganceFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            break;
            
        case 19:
        {
            StandardFilter5 *stillImageFilter = [[StandardFilter5 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            break;
            
        case 20:
        {
            StandardFilter6 *stillImageFilter = [[StandardFilter6 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            break;
            
        case 21:
        {
            StandardFilter8 *stillImageFilter = [[StandardFilter8 alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
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
                
                GPUImageKuwaharaFilter *stillImageFilter = [[GPUImageKuwaharaFilter alloc] init];
                quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
                    
            [spinner removeFromSuperview];
            [sender setTitle:@"kuwahara" forState:UIControlStateNormal];
            sender.enabled = YES;
        }
            break;
            
        case 23:
        {
            FishEyeFilter *stillImageFilter = [[FishEyeFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            break;
            
        case 24:
        {
            UfoFilter *stillImageFilter = [[UfoFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            break;
            
        case 25:
        {
            EdgeeFilter *stillImageFilter = [[EdgeeFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            break;
            
        case 26:
        {
            VinnyFilter *stillImageFilter = [[VinnyFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            break;
            
        case 27:
        {
            PenSketchFilter *stillImageFilter = [[PenSketchFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            break;
            
        case 28:
        {
             MakeMeTallFilter*stillImageFilter = [[MakeMeTallFilter alloc] init];
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
        }
            
            break;
       
        default:
            NSLog(@" filter fail");
            break;
    }
    
    
    if (_circleBlurView.hidden){
            [_mainImage setImage:quickFilteredImage];
    }
    else{
        
        _mainImageWithoutBlur = quickFilteredImage;
        [self blurIt:self.circleBlurView];
    }

}
/*
- (IBAction)parametersBarButton:(id)sender
{
    _parametersButtonScroll.hidden = !_parametersButtonScroll.hidden;
    self.slider.hidden =!self.slider.hidden;
    
}
*/
-(IBAction) changePhotoParameters:(NSInteger)sender
{
   
    
    if (_circleBlurView.hidden)
        [_mainImage setImage:[_arrayWhithPhoto lastObject]];
    else
    {
        _mainImageWithoutBlur = [_arrayWhithPhoto lastObject];
        [self blurIt:self.circleBlurView];
    }
    
    switch (sender)
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
    _currentFilterTag=sender;
    _slider.hidden = NO;    
}
- (IBAction)showSliderWithParameters:(id)sender
{
    UIImage *quickFilteredImage;
    UIImage *imageForFiltering = [_arrayWhithPhoto lastObject];

    switch (_currentFilterTag)
    {
        case 1:
        {
            GPUImageExposureFilter *stillImageFilter = [[GPUImageExposureFilter alloc] init];
            stillImageFilter.exposure=_slider.value;  
           quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
            //-10.0 - 10.0, with 0.0 as the default
            
        }
            break;
        case 2:
        {
            GPUImageBrightnessFilter *stillImageFilter = [[GPUImageBrightnessFilter alloc] init];
            stillImageFilter.brightness = _slider.value;
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
            //-1.0 - 1.0, with 0.0 as the default
        }
            break;
        case 3:
        {
            GPUImageContrastFilter *stillImageFilter = [[GPUImageContrastFilter alloc] init];
            stillImageFilter.contrast = _slider.value;
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
            //0.0 - 4.0, with 1.0 as the default
        }
            break;
        case 4:
        {
            GPUImageSaturationFilter *stillImageFilter = [[GPUImageSaturationFilter alloc] init];
            stillImageFilter.saturation = _slider.value;
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
            //0.0 - 2.0, with 1.0 as the default
        }
            break;
            
        case 5:
        {
            GPUImageGammaFilter *stillImageFilter = [[GPUImageGammaFilter alloc] init];
            stillImageFilter.gamma = _slider.value;
            quickFilteredImage = [stillImageFilter imageByFilteringImage:imageForFiltering];
            //0.0 - 3.0, with 1.0 as the default
        }
            break;
            
        default:
            
            break;
            
    }
    if (quickFilteredImage){
        if (_circleBlurView.hidden)
            _mainImage.image= quickFilteredImage;
        else{
        _mainImageWithoutBlur = quickFilteredImage;
        [self blurIt:self.circleBlurView];
        }
    }
}



- (IBAction)managePhotosArray:(UIBarButtonItem *)sender
{
    //_slider.hidden=YES;
    //_parametersButtonScroll.hidden = YES;
    switch (sender.tag) {
        case 1:
        
            if ((_mainImage.image != _nonFilterImage) & !([_mainImage.image isEqual: [_arrayWhithPhoto lastObject]]))
            {
                _circleBlurView.hidden = YES;
                [_arrayWhithPhoto addObject: _mainImage.image];
                UIImageView *imageForAnimation = [[UIImageView alloc] initWithFrame:_mainImage.frame];
                [self.view addSubview:imageForAnimation];
                imageForAnimation.image = _mainImage.image;
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationCurve:UIViewAnimationCurveLinear];
                [UIView setAnimationBeginsFromCurrentState:YES];
                imageForAnimation.frame = CGRectMake(30, self.view.frame.size.height*0.9, 20, 20);
                imageForAnimation.alpha = 0.0f;
                [UIView commitAnimations];
                imageForAnimation=nil;
                _countLayers.text =[NSString stringWithFormat:@"%i", [ _arrayWhithPhoto count]];
            }
            
            break;
         
        case 2:
        {
            
            _circleBlurView.hidden = YES;


            if ([_arrayWhithPhoto count] == 1)
                [_mainImage setImage:_nonFilterImage];
            
            else 
            {
                UIImageView *imageForAnimation = [[UIImageView alloc] initWithFrame:_mainImage.frame];
                [self.view addSubview:imageForAnimation];
                imageForAnimation.image = _mainImage.image;
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.2];
                [UIView setAnimationCurve:UIViewAnimationCurveLinear];
                [UIView setAnimationBeginsFromCurrentState:YES];
                imageForAnimation.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 20, 20);
                imageForAnimation.alpha = 0.0f;
                [UIView commitAnimations];

                if ([[_mainImage image] isEqual:[_arrayWhithPhoto lastObject]])
                {
                    [_arrayWhithPhoto removeLastObject];
                    [_mainImage setImage:[_arrayWhithPhoto lastObject]];
                }
                else
                {
                    [_mainImage setImage:[_arrayWhithPhoto lastObject]];
                }
                imageForAnimation=nil;
            }
            _countLayers.text =[NSString stringWithFormat:@"%i", [_arrayWhithPhoto count]];
        }
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
    [self showHud:YES withTitle:@"Отправка" erorr:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [_vkontakte postImageToWall:[_mainImage image]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self showHud:NO withTitle:nil erorr:nil];
            
        });
    });
    
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte
{
    
}




@end
