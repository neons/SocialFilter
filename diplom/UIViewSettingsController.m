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

- (IBAction)closeButton:(UIButton *)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _arrayWithSettings = [NSArray arrayWithObjects:@"Удалить кэш фото", nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_arrayWithSettings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"settingsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];}
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = _arrayWithSettings[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        NSFileManager *fileMgr = [[NSFileManager alloc] init];
        NSError *error = nil;
        NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:DOCUMENTS error:&error];
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        if ((error == nil)&([directoryContents count]>=1)) {
            for (NSString *path in directoryContents) {
                NSString *fullPath = [DOCUMENTS stringByAppendingPathComponent:path];
                BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
                if (!removeSuccess) {
                    NSLog(@"fail delete");
                }
                else{
                    NSLog(@"all del");
                }
            }
        }
        else {
            NSLog(@"some bad or nothing");
        }
    }
}

@end
