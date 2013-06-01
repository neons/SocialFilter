//
//  UIViewControllerFacebookPhotos.m
//  diplom
//
//  Created by admin on 24.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIViewControllerFacebookPhotos.h"

@interface UIViewControllerFacebookPhotos()
@property (strong, nonatomic) NSMutableDictionary *dictionaryWitSortPhotos;
@property (nonatomic) BOOL needCache;
@property (strong, nonatomic) UIImage *defaultImage;
@property (strong, nonatomic) NSMutableDictionary *staticImageDictionary;
@property (nonatomic) CGSize cropSize;
@property (nonatomic, strong ) NSString *filePath;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MBProgressHUD *hud;

-(void)saveCache;
-(void)pickImageForEdit:(id)sender;

@end

@implementation UIViewControllerFacebookPhotos



- (void)request:(FBRequest *)request didLoad:(id)result{
    NSLog(@"fb request did load");
}

#pragma mark - View lifecycle

-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    if (_needCache){
        _needCache = NO;
        [self saveCache];
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    _defaultImage= [UIImage imageNamed:@"tree.png"];
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.tableView addSubview:_hud];
	_hud.dimBackground = YES;
    _hud.labelText = @"Загрузка";
    [_hud show:YES];
    self.cropSize = CGSizeMake(320, 320);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _filePath = [DOCUMENTS stringByAppendingPathComponent:_albumsId];
        NSMutableData *data = [[NSMutableData alloc]initWithContentsOfFile:_filePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        _staticImageDictionary = [unarchiver decodeObjectForKey: @"static"];
        [unarchiver finishDecoding];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (FBSession.activeSession.isOpen) {

            NSString *path=[NSString stringWithFormat:@"%@/photos?limit=1000",_albumsId];
             [FBRequestConnection startWithGraphPath:path completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                 NSArray *array = result[@"data"];
                 _dictionaryWitSortPhotos=[NSMutableDictionary new];
                 
                 int numberRow=1;
                 int numberSection=0;
                 int index=0;
                 
                 while ([_dictionaryWitSortPhotos count]<([array count])) {
                     [_dictionaryWitSortPhotos setObject:[array objectAtIndex:index++] forKey:[NSString stringWithFormat:@"PhotoInSection%iInRow%i",numberSection, numberRow++]];
                     if ((numberRow%5)==0){
                         numberSection++;
                         numberRow=1;
                     }
                 }
                 [_tableView reloadData];
                 [_hud hide:YES];
                 [_hud removeFromSuperview];
                 _hud = nil;
             }];}
        });
    });
}


- (NSArray*)imageNamed:(NSArray*)arrayWithurl inIndexPaths:(NSIndexPath *)indexPath{
    
    NSMutableArray *finalArray=[NSMutableArray new];
    NSMutableArray *urlForDownload=[NSMutableArray new];
    for (NSString *obj in arrayWithurl)
    {
        UIImage*image=_staticImageDictionary[obj];
        if (image!=nil){
            [finalArray addObject:image];
        }
        else if(obj!=nil){
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
- (UIImage*)imageNamed:(NSString*)imageNamed cache:(BOOL)cache inIndexPath:(NSIndexPath *)indexPath {
    
    UIImage* retImage = [_staticImageDictionary objectForKey:imageNamed];
    
    if ((retImage == nil)&(imageNamed!=nil)){
        retImage=_defaultImage;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageNamed]]];\
            if (cache){
                if (_staticImageDictionary == nil){
                    _staticImageDictionary = [NSMutableDictionary new];
                }
                if (imageNamed) {
                    _needCache = YES;
                    [_staticImageDictionary setObject:image forKey:imageNamed];
                }
            } 
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSArray *arrayOfIndex=@[indexPath];
                [_tableView reloadRowsAtIndexPaths:arrayOfIndex withRowAnimation:UITableViewRowAnimationNone];
            });
        });
        
    }
    return retImage;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([_dictionaryWitSortPhotos count]%4!=0)
        return ([_dictionaryWitSortPhotos count]/4)+1;
    
    return [_dictionaryWitSortPhotos count]/4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { 
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"SecondCell";
    UITableViewCellCustomWithImage *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [UITableViewCellCustomWithImage cell];
    }
    
    NSString *photoUrl=[_dictionaryWitSortPhotos objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow1",indexPath.row]][@"picture"];
    NSString *photoUrl2=[_dictionaryWitSortPhotos objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow2",indexPath.row]][@"picture"];
    NSString *photoUrl3=[_dictionaryWitSortPhotos objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow3",indexPath.row]][@"picture"];
    NSString *photoUrl4=[_dictionaryWitSortPhotos objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow4",indexPath.row]][@"picture"];
    
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

-(void)pickImageForEdit :(id) sender{
    diplomAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if (delegate.internet) {
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    NSString *photoUrl=[_dictionaryWitSortPhotos objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow%i",gesture.view.tag/10,gesture.view.tag%10]][@"images"][1][@"source"];
    if (photoUrl){
    NSLog(@"urlphoto %@",photoUrl);
    NSData *photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]];

    GKImageCropViewController *cropController = [[GKImageCropViewController alloc] init];
    cropController.sourceImage = [UIImage imageWithData:photoData];
    cropController.cropSize = self.cropSize;
    cropController.delegate = self;
    [self.navigationController pushViewController:cropController animated:YES];
        }
    }
    else{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                            message:@"Отсутствует интернет подключение"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)saveCache{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cacheSettings"]){
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        _filePath = [DOCUMENTS stringByAppendingPathComponent:_albumsId];
        NSMutableData *data = [NSMutableData new];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
        [archiver encodeObject:_staticImageDictionary forKey: @"static"];
        [archiver finishEncoding];
        NSLog(@"file path %@",_filePath);
        [data writeToFile:_filePath atomically:YES];
         dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"successful save");         
        });
    });
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

@end
