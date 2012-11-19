//
//  UITableViewControllerForVkPhotos.m
//  diplom
//
//  Created by admin on 04.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewControllerForVkPhotos.h"
@interface UITableViewControllerForVkPhotos()
@property (nonatomic, strong) NSData *data;
@property  BOOL  needCache;
@property (nonatomic, strong ) NSString * filePath;
@property (strong, nonatomic)     MBProgressHUD *hud;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIImage *defaultImage;

-(void) createTable;

@end

@implementation UITableViewControllerForVkPhotos
@synthesize dictionaryWithArrayofPhoto=_dictionaryWithArrayofPhoto;
@synthesize vkontakte=_vkontakte;
@synthesize aid=_aid;
@synthesize staticImageDictionary=_staticImageDictionary;
@synthesize data=_data;
@synthesize needCache=_needCache;
@synthesize filePath=_filePath;
@synthesize cropSize;
@synthesize hud=_hud;
@synthesize tableView = _tableView;
@synthesize defaultImage=_defaultImage;
 // для остановки установить значение "NO"


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    _defaultImage= [UIImage alloc];
    _defaultImage =[UIImage imageNamed:@"tree.png"];
    [self createTable];
    
    
}

-(void) createTable
{
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.tableView addSubview:_hud];
	_hud.dimBackground = YES;
    _hud.delegate = self;
    [_hud show:YES];
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _filePath = [DOCUMENTS stringByAppendingPathComponent:_aid];
        _data = [[NSMutableData alloc]initWithContentsOfFile:_filePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:_data];
        _staticImageDictionary = [unarchiver decodeObjectForKey: @"static"];
        [unarchiver finishDecoding];
        NSLog(@"static %i", [_staticImageDictionary count]);
        self.cropSize = CGSizeMake(320, 320);
        
        _vkontakte = [Vkontakte sharedInstance];
        _vkontakte.delegate = self;
        if (![_vkontakte isAuthorized]) 
        {
            [_vkontakte authenticate];
        }
        [_vkontakte getUserAlbumsPhoto:_aid];      
         dispatch_sync(dispatch_get_main_queue(), ^{
             [_tableView reloadData];
            [_hud hide:YES];
            [_hud removeFromSuperview];
            _hud = nil;
            
        });
    });
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




- (void)vkontakteDidFinishGettinAlbumsPhoto:(NSDictionary *)info;
{
    _dictionaryWithArrayofPhoto = info;
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





#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_dictionaryWithArrayofPhoto count]%4!=0)
        return ([_dictionaryWithArrayofPhoto count]/4)+1;
    
    return [_dictionaryWithArrayofPhoto count]/4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    return 80;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"SecondCell";
    UITableViewCellCustomWithImage *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [UITableViewCellCustomWithImage cell];
    }
    
    NSString *photoUrl=[[_dictionaryWithArrayofPhoto objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow1",indexPath.row]]objectForKey:@"src"];
    NSString *photoUrl2=[[_dictionaryWithArrayofPhoto objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow2",indexPath.row]]objectForKey:@"src"];
    NSString *photoUrl3=[[_dictionaryWithArrayofPhoto objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow3",indexPath.row]]objectForKey:@"src"];
    NSString *photoUrl4=[[_dictionaryWithArrayofPhoto objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow4",indexPath.row]]objectForKey:@"src"];
    
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
    
    int n;
    n = indexPath.row*10+cell.firstImage.tag;
    
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
    NSString *photoUrl=[[_dictionaryWithArrayofPhoto objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow%i",gesture.view.tag/10,gesture.view.tag%10]]objectForKey:@"src_big"];
    NSData *photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]];
    if (_needCache) 
    {
        if (_needCache) 
        { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
    }
    
    GKImageCropViewController *cropController = [[GKImageCropViewController alloc] init];
    cropController.sourceImage = [UIImage imageWithData:photoData];
    cropController.cropSize = self.cropSize;
    cropController.delegate = self;
    [self.navigationController pushViewController:cropController animated:YES];
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
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte
{

}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    
    //[[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)backButton:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
    if (_needCache) 
    { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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

}



@end
