//
//  InstagramAlbumsVIewController.m
//  diplom
//
//  Created by admin on 16.01.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "InstagramPhotosViewController.h"
#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@interface InstagramPhotosViewController()

@property (strong, nonatomic) NSMutableDictionary * dictionaryWitSortPhotos;
@property  BOOL  needCache;
@property (strong, nonatomic) UIImage *defaultImage;
@property (strong, nonatomic) NSMutableDictionary * staticImageDictionary;
@property (nonatomic, strong ) NSString * filePath;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)    MBProgressHUD *hud;

-(void)saveCache;
-(void)pickImageForEdit :(id) sender;

@end


@implementation InstagramPhotosViewController


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

- (void)viewDidLoad
{
    [super viewDidLoad];
    _defaultImage= [UIImage alloc];
    _defaultImage =[UIImage imageNamed:@"tree.png"];
    
    diplomAppDelegate* appDelegate = (diplomAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    appDelegate.instagram.sessionDelegate = self;
    
    

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _filePath = [DOCUMENTS stringByAppendingPathComponent:@"instagram"];
        NSMutableData *data = [[NSMutableData alloc]initWithContentsOfFile:_filePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        _staticImageDictionary = [unarchiver decodeObjectForKey: @"static"];
        [unarchiver finishDecoding];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if ([appDelegate.instagram isSessionValid]) {
                
                NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"users/self/media/recent", @"method", nil];
                [appDelegate.instagram requestWithParams:params
                                                delegate:self];
                _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                [self.tableView addSubview:_hud];
                _hud.dimBackground = YES;
                [_hud show:YES];
            } else {
                
                [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
            }

        });
    });
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


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (_needCache) 
        [self saveCache];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}



#pragma mark - Table view data source



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
    
    NSString *photoUrl=[[[[_dictionaryWitSortPhotos objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow1",indexPath.row]]objectForKey:@"images"] objectForKey:@"thumbnail"] objectForKey:@"url"];
    NSString *photoUrl2=[[[[_dictionaryWitSortPhotos objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow2",indexPath.row]]objectForKey:@"images"] objectForKey:@"thumbnail"] objectForKey:@"url"];
    NSString *photoUrl3=[[[[_dictionaryWitSortPhotos objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow3",indexPath.row]]objectForKey:@"images"] objectForKey:@"thumbnail"] objectForKey:@"url"];
    NSString *photoUrl4=[[[[_dictionaryWitSortPhotos objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow4",indexPath.row]]objectForKey:@"images"] objectForKey:@"thumbnail"] objectForKey:@"url"];
    
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

-(void)saveCache
{
    _needCache = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        _filePath = [DOCUMENTS stringByAppendingPathComponent:@"instagram"];
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

-(void)pickImageForEdit :(id) sender
{
    diplomAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if (delegate.internet)
        {
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    NSString *photoUrl=[[[[_dictionaryWitSortPhotos objectForKey:[NSString stringWithFormat:@"PhotoInSection%iInRow%i",gesture.view.tag/10,gesture.view.tag%10]]objectForKey:@"images"]objectForKey:@"standard_resolution"] objectForKey:@"url"];
    
            if (photoUrl)
        {
            NSLog(@"urlphoto %@",photoUrl);
            NSData *photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]];
        
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                                 bundle: nil];    
        
        
            diplomViewController *controller = (diplomViewController*)[mainStoryboard 
                                                                   instantiateViewControllerWithIdentifier: @"filterController"];
            controller.imageFromPicker = [UIImage imageWithData:photoData];
            [self.navigationController pushViewController:controller animated:YES]; 

       
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
}

#pragma mark - IGRequestDelegate

- (void)request:(IGRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Instagram did fail: %@", error);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)request:(IGRequest *)request didLoad:(id)result {
    NSMutableArray * array = [result objectForKey:@"data"];
    
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
    [_hud hide:YES];
    [_hud removeFromSuperview];
    _hud = nil;
    [self.tableView reloadData];
}


#pragma - IGSessionDelegate

-(void)igDidLogin {
    NSLog(@"Instagram did login");
    diplomAppDelegate* appDelegate = (diplomAppDelegate*)[UIApplication sharedApplication].delegate;
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.instagram.accessToken forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"users/self/media/recent", @"method", nil];
    [appDelegate.instagram requestWithParams:params
                                    delegate:self];
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.tableView addSubview:_hud];
    _hud.dimBackground = YES;
    [_hud show:YES];
    
}

-(void)igDidNotLogin:(BOOL)cancelled {
    NSLog(@"Instagram did not login");
    NSString* message = nil;
    if (cancelled) {
        message = @"Access cancelled!";
    } else {
        message = @"Access denied!";
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(void)igDidLogout {
    NSLog(@"Instagram did logout");
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)igSessionInvalidated {
    NSLog(@"Instagram session was invalidated");
    [self igDidLogout];
    [[self navigationController] popViewControllerAnimated:YES];
}



@end
