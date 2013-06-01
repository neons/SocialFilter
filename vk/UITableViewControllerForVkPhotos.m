//
//  UITableViewControllerForVkPhotos.m
//  diplom
//
//  Created by admin on 04.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewControllerForVkPhotos.h"
@interface UITableViewControllerForVkPhotos()
@property (nonatomic) BOOL  needCache;
@property (nonatomic, strong ) NSString * filePath;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIImage *defaultImage;
@property (strong, nonatomic) NSMutableDictionary * staticImageDictionary;
@property (nonatomic) CGSize cropSize;
@property (strong,nonatomic) NSDictionary *dictionaryWithArrayofPhoto;
@property (strong, nonatomic) Vkontakte *vkontakte;

-(void)saveCache;

@end

@implementation UITableViewControllerForVkPhotos

#pragma mark - View lifecycle

-(void)viewWillDisappear:(BOOL)animated{
    if (_needCache) 
        [self saveCache];
    [super viewWillDisappear:animated];
}

-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    _defaultImage =[UIImage imageNamed:@"tree.png"];
    [self createTable];
}

-(void) createTable{
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.tableView addSubview:_hud];
	_hud.dimBackground = YES;
    _hud.delegate = self;
    [_hud show:YES];
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _filePath = [DOCUMENTS stringByAppendingPathComponent:_aid];
         NSMutableData *data = [[NSMutableData alloc]initWithContentsOfFile:_filePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        _staticImageDictionary = [unarchiver decodeObjectForKey: @"static"];
        [unarchiver finishDecoding];
        self.cropSize = CGSizeMake(320, 320);
        _vkontakte = [Vkontakte sharedInstance];
        _vkontakte.delegate = self;
        if (![_vkontakte isAuthorized]) 
            [_vkontakte authenticate];
        [_vkontakte getUserAlbumsPhoto:_aid];      
         dispatch_sync(dispatch_get_main_queue(), ^{
             [_tableView reloadData];
            [_hud hide:YES];
            [_hud removeFromSuperview];
            _hud = nil;
            
        });
    });
}

- (void)vkontakteDidFinishGettinAlbumsPhoto:(NSDictionary *)info;{
    _dictionaryWithArrayofPhoto = info;
}


- (UIImage*)imageNamed:(NSString*)imageNamed cache:(BOOL)cache inIndexPath:(NSIndexPath *)indexPath {
    UIImage* retImage = _staticImageDictionary[imageNamed];

    if ((retImage == nil)&(imageNamed!=nil)){
        retImage=_defaultImage;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageNamed]]];
            
            if (cache){
                if (_staticImageDictionary == nil){
                    _staticImageDictionary = [[NSMutableDictionary alloc] init];
                }
                if (imageNamed) {
                    _needCache = YES;
                    [_staticImageDictionary setObject:image forKey:imageNamed];
                }
            } 
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSArray *arrayOfIndex=[[NSArray alloc] initWithObjects:indexPath, nil];
                [_tableView reloadRowsAtIndexPaths:arrayOfIndex withRowAnimation:UITableViewRowAnimationNone];
            });
        });
    }
    return retImage;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([_dictionaryWithArrayofPhoto count]%4!=0)
        return ([_dictionaryWithArrayofPhoto count]/4)+1;
    
    return [_dictionaryWithArrayofPhoto count]/4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSArray*)imageNamed:(NSArray*)arrayWithurl inIndexPaths:(NSIndexPath *)indexPath{
    NSMutableArray *finalArray=[NSMutableArray new];
    NSMutableArray *urlForDownload=[NSMutableArray new];
    for (NSString* obj in arrayWithurl){
        UIImage*image=_staticImageDictionary[obj];
        if (image!=nil){
            [finalArray addObject:image];
        }
        else if(obj!=nil) {
            [finalArray addObject:_defaultImage];
            [urlForDownload addObject:obj];
            _needCache = YES;
        }
    }
    if ([urlForDownload count]>=1) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if (_staticImageDictionary == nil){
                _staticImageDictionary = [NSMutableDictionary new];
            }
            for (id obj in urlForDownload) {
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:obj]]];
                [_staticImageDictionary setObject:image forKey:obj];
            }
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSArray *arrayOfIndex=@[indexPath];
                [_tableView reloadRowsAtIndexPaths:arrayOfIndex withRowAnimation:UITableViewRowAnimationNone];
            });
        });
    }
    return finalArray;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"SecondCell";
    UITableViewCellCustomWithImage *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [UITableViewCellCustomWithImage cell];
    }
    
    NSString *photoUrl=[_dictionaryWithArrayofPhoto objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow1",indexPath.row]][@"src"];
    NSString *photoUrl2=[_dictionaryWithArrayofPhoto objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow2",indexPath.row]][@"src"];
    NSString *photoUrl3=[_dictionaryWithArrayofPhoto objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow3",indexPath.row]][@"src"];
    NSString *photoUrl4=[_dictionaryWithArrayofPhoto objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow4",indexPath.row]][@"src"];
    
    NSArray *array=[[NSArray alloc]initWithArray:[self imageNamed:[NSArray arrayWithObjects:photoUrl,photoUrl2,photoUrl3,photoUrl4, nil] inIndexPaths:indexPath]];
 
    if ([array count]==4){
        cell.firstImage.image = array[0];
        cell.secondImage.image = array[1];
        cell.thirdImage.image = array[2];
        cell.fourthImage.image = array[3];
    }
    else{
        cell.firstImage.image = [self imageNamed:photoUrl cache:YES inIndexPath:indexPath];
        cell.secondImage.image = [self imageNamed:photoUrl2 cache:YES inIndexPath:indexPath];
        cell.thirdImage.image = [self imageNamed:photoUrl3 cache:YES inIndexPath:indexPath];
        cell.fourthImage.image = [self imageNamed:photoUrl4 cache:YES inIndexPath:indexPath];
    }
    
    UITapGestureRecognizer *tapped1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickImageForEdit:)];
    UITapGestureRecognizer *tapped2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickImageForEdit:)];
    UITapGestureRecognizer *tapped3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickImageForEdit:)];
    UITapGestureRecognizer *tapped4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickImageForEdit:)];
        
    cell.firstImage.tag = 1;
    cell.secondImage.tag=2;
    cell.thirdImage.tag=3;
    cell.fourthImage.tag=4;
    cell.firstImage.tag = indexPath.row*10+cell.firstImage.tag;
    cell.secondImage.tag = indexPath.row*10+cell.secondImage.tag;
    cell.thirdImage.tag = indexPath.row*10+cell.thirdImage.tag;
    cell.fourthImage.tag = indexPath.row*10+cell.fourthImage.tag;
    
    tapped1.numberOfTapsRequired = 1;
    tapped2.numberOfTapsRequired = 1;
    tapped3.numberOfTapsRequired = 1;
    tapped4.numberOfTapsRequired = 1;
    
    [cell.firstImage addGestureRecognizer:tapped1];
    [cell.secondImage addGestureRecognizer:tapped2];
    [cell.thirdImage addGestureRecognizer:tapped3];
    [cell.fourthImage addGestureRecognizer:tapped4];
    
    return cell;
}




-(void)pickImageForEdit :(id) sender
{
    diplomAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if (delegate.internet){
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    NSString *photoUrl=[[_dictionaryWithArrayofPhoto objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow%i",gesture.view.tag/10,gesture.view.tag%10]]objectForKey:@"src_xbig"];
    if (photoUrl){
        NSData *photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]];
    
    GKImageCropViewController *cropController = [[GKImageCropViewController alloc] init];
    cropController.sourceImage = [UIImage imageWithData:photoData];
    cropController.cropSize = self.cropSize;
    cropController.delegate = self;
    [self.navigationController pushViewController:cropController animated:YES];
        }
    }else{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                            message:@"Отсутствует интернет подключение"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)imageCropController:(GKImageCropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle: nil];    
    
    diplomViewController *controller = (diplomViewController*)[mainStoryboard 
                                                               instantiateViewControllerWithIdentifier: @"filterController"];
    controller.imageFromPicker = croppedImage;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error{
    NSLog(@"fail");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showVkontakteAuthController:(UIViewController *)controller{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentModalViewController:controller animated:YES];
}

- (void)vkontakteAuthControllerDidCancelled{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte{
    NSLog(@"finish login");
}


-(void)saveCache{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cacheSettings"]){
    _needCache = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            _filePath = [DOCUMENTS stringByAppendingPathComponent:_aid];
            NSMutableData *data = [NSMutableData new];
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
            [archiver encodeObject:_staticImageDictionary forKey:@"static"];
            [archiver finishEncoding];
            [data writeToFile:_filePath atomically:YES];
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"successful save");         
        });
    });
    }
}

@end
