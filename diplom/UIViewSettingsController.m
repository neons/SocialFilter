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
    [super didReceiveMemoryWarning];
    
}

- (IBAction)closeButton:(UIButton *)sender 
{
    [self.presentingViewController dismissModalViewControllerAnimated:YES];

}
#pragma mark - View lifecycle



- (void)viewDidLoad
{
    [super viewDidLoad];
    _arrayWithSettings = [NSArray arrayWithObjects:@"Удалить кэш фото", nil];
}


- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
                    NSLog(@"all del");
                }
            }
        }
        else 
        {
            NSLog(@"some bad or nothing");
        }
        
        UIImageView *view=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"checkedd.png"]];
        view.frame = CGRectMake(258,4,58,58);  
        [self.tableView addSubview:view];
        [view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1];
        }
}

@end
