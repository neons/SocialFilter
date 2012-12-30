//
//  UIViewControllerFacebookPhotos.m
//  diplom
//
//  Created by admin on 24.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIViewControllerFacebookPhotos.h"

@interface UIViewControllerFacebookPhotos()
@property (strong, nonatomic) NSMutableDictionary * dictionaryWitSortPhotos;
@property  BOOL  needCache;
@property (strong, nonatomic) UIImage *defaultImage;
@property (strong, nonatomic) NSMutableDictionary * staticImageDictionary;
@property (nonatomic, assign) CGSize cropSize;
@property (nonatomic, strong ) NSString * filePath;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)     MBProgressHUD *hud;


-(void)saveCache;
-(void)pickImageForEdit :(id) sender;
@end

@implementation UIViewControllerFacebookPhotos

@synthesize tableView=_tableView;
@synthesize albumsId=_albumsId;
@synthesize dictionaryWitSortPhotos=_dictionaryWitSortPhotos;
@synthesize needCache=_needCache;
@synthesize defaultImage=_defaultImage;
@synthesize staticImageDictionary=_staticImageDictionary;
@synthesize filePath=_filePath;
@synthesize cropSize;
@synthesize hud=_hud;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)backButton:(id)sender 
{
    if (_needCache)
        [self saveCache];
    [[self navigationController] popViewControllerAnimated:YES];
}



- (void)request:(FBRequest *)request didLoad:(id)result
{
   
    NSArray *array =[result objectForKey:@"data"];

    
    _dictionaryWitSortPhotos=[[NSMutableDictionary alloc]init];
    
    int numberRow=1;
    int numberSection=0;
    int index=0;
    
    while ([_dictionaryWitSortPhotos count]<([array count])) {
        [_dictionaryWitSortPhotos setObject:[array objectAtIndex:index++] forKey:[NSString stringWithFormat:@"PhotoInSection%iInRow%i",numberSection, numberRow++]];
        if ((numberRow%5)==0) {
            numberSection++;
            numberRow=1;
        }
        
    }
    [_tableView reloadData];
    [_hud hide:YES];
    [_hud removeFromSuperview];
    _hud = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle



-(void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    _defaultImage= [UIImage alloc];
    _defaultImage =[UIImage imageNamed:@"tree.png"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _filePath = [DOCUMENTS stringByAppendingPathComponent:_albumsId];
        NSMutableData *data = [[NSMutableData alloc]initWithContentsOfFile:_filePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        _staticImageDictionary = [unarchiver decodeObjectForKey: @"static"];
        [unarchiver finishDecoding];
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            diplomAppDelegate *delegate = (diplomAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSString *string=[NSString stringWithFormat:@"%@/photos?limit=1000",_albumsId];
            [[delegate facebook] requestWithGraphPath:string andDelegate:self];
        });
    });
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.tableView addSubview:_hud];
	_hud.dimBackground = YES;
    [_hud show:YES];
        self.cropSize = CGSizeMake(320, 320);

}


- (NSArray*)imageNamed:(NSArray*)arrayWithurl inIndexPaths:(NSIndexPath *)indexPath
{
    NSMutableArray *finalArray=[[NSMutableArray alloc]init];
    NSMutableArray *urlForDownload=[[NSMutableArray alloc]init];
    for (id obj in arrayWithurl)
    {
        UIImage*image=[_staticImageDictionary objectForKey:obj];
        if (image!=nil)
        {
            [finalArray addObject:image];
        }
        else if(obj!=nil)   
        {
            [finalArray addObject:_defaultImage];
            [urlForDownload addObject:obj];
            _needCache = YES;
        }
    }
    if ([urlForDownload count]>=1) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
          // NSLog(@"download image");
            if (_staticImageDictionary == nil)
            {
                _staticImageDictionary = [[NSMutableDictionary alloc] init];
            }
            for (id obj in urlForDownload) 
            {
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:obj]]];
                [_staticImageDictionary setObject:image forKey:obj];
            }
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSArray *arrayOfIndex=[[NSArray alloc] initWithObjects:indexPath, nil];
                [_tableView reloadRowsAtIndexPaths:arrayOfIndex withRowAnimation:UITableViewRowAnimationNone];
            });
        });
    }
    
    
    return finalArray;
}
- (UIImage*)imageNamed:(NSString*)imageNamed cache:(BOOL)cache inIndexPath:(NSIndexPath *)indexPath 
{
    UIImage* retImage = [_staticImageDictionary objectForKey:imageNamed];
    
    if ((retImage == nil)&(imageNamed!=nil))
    {
        retImage=_defaultImage;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageNamed]]];
            
            if (cache)
            {
                if (_staticImageDictionary == nil)
                {
                    _staticImageDictionary = [[NSMutableDictionary alloc] init];
                }
                if (imageNamed) 
                {
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_dictionaryWitSortPhotos count]%4!=0)
        return ([_dictionaryWitSortPhotos count]/4)+1;
    
    return [_dictionaryWitSortPhotos count]/4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"SecondCell";
    UITableViewCellCustomWithImage *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [UITableViewCellCustomWithImage cell];
    }
    
    NSString *photoUrl=[[_dictionaryWitSortPhotos objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow1",indexPath.row]]objectForKey:@"picture"];
    NSString *photoUrl2=[[_dictionaryWitSortPhotos objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow2",indexPath.row]]objectForKey:@"picture"];
    NSString *photoUrl3=[[_dictionaryWitSortPhotos objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow3",indexPath.row]]objectForKey:@"picture"];
    NSString *photoUrl4=[[_dictionaryWitSortPhotos objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow4",indexPath.row]]objectForKey:@"picture"];
    
    NSArray *array=[[NSArray alloc]initWithArray:[self imageNamed:[NSArray arrayWithObjects:photoUrl,photoUrl2,photoUrl3,photoUrl4, nil] inIndexPaths:indexPath]];
    
    if ([array count]==4)
    {
        cell.firstImage.image = [array objectAtIndex:0];
        cell.secondImage.image = [array objectAtIndex:1];
        cell.thirdImage.image = [array objectAtIndex:2];
        cell.fourthImage.image = [array objectAtIndex:3];
    }
    else
    {
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
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    NSString *photoUrl=[[[[_dictionaryWitSortPhotos objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow%i",gesture.view.tag/10,gesture.view.tag%10]]objectForKey:@"images"]objectAtIndex:1]objectForKey:@"source"];
    if (photoUrl)
    {
        NSLog(@"urlphoto %@",photoUrl);
        NSData *photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]];
    
    if (_needCache) 
        [self saveCache];
    
    
    GKImageCropViewController *cropController = [[GKImageCropViewController alloc] init];
    cropController.sourceImage = [UIImage imageWithData:photoData];
    cropController.cropSize = self.cropSize;
    cropController.delegate = self;
    [self.navigationController pushViewController:cropController animated:YES];
    }
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)saveCache
{
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        _filePath = [DOCUMENTS stringByAppendingPathComponent:_albumsId];
        NSMutableData *data = [[NSMutableData alloc]init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
        [archiver encodeObject:_staticImageDictionary forKey: @"static"];
        [archiver finishEncoding];
        NSLog(@"first file %@",_filePath);
        [data writeToFile:_filePath atomically:YES];        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"successful save");         
        });
    });
    
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

@end
