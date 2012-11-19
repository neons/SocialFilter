//
//  UIViewSettingsController.m
//  diplom
//
//  Created by admin on 15.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIViewSettingsController.h"
#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@interface UIViewSettingsController()

@property (nonatomic,strong) NSArray *arrayWithSettings;

@end

@implementation UIViewSettingsController

@synthesize tableView=_tableView;
@synthesize arrayWithSettings=_arrayWithSettings;

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

- (IBAction)closeButton:(UIButton *)sender 
{
    [self.presentingViewController dismissModalViewControllerAnimated:YES];

}
#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib. settingsCell
- (void)viewDidLoad
{
    [super viewDidLoad];
     
    _arrayWithSettings = [NSArray arrayWithObjects:@"Удалить кэш фото", nil];
}


- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_arrayWithSettings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"settingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];}
   
    cell.textLabel.text = [_arrayWithSettings objectAtIndex:indexPath.row];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    
    if (indexPath.row==0) {
        NSFileManager *fileMgr = [[NSFileManager alloc] init];
        NSError *error = nil;
        NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:DOCUMENTS error:&error];
        
        if ((error == nil)&([directoryContents count]>=1)) 
        {
            for (NSString *path in directoryContents) {
                NSString *fullPath = [DOCUMENTS stringByAppendingPathComponent:path];
                BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
                if (!removeSuccess) 
                {
                    NSLog(@"fail delete");
                }
                else
                {
                   
                    
                }
            }
        }
        else 
        {
            NSLog(@"some bad or nothing");
        }
        UIImageView *view=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"checkedd.png"]];
        view.frame = CGRectMake(258,5,58,58);  
        [self.tableView addSubview:view];
        [_tableView performSelector:@selector(reloadData) withObject:nil afterDelay:3];
        [view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:3];
        
    }
    
    
    
    
    
}


@end
