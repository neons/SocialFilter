//
//  UIViewSettingsController.m
//  diplom
//
//  Created by admin on 15.11.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"

#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@interface SettingsViewController()
@property (strong,nonatomic) NSUserDefaults *userDefaults;
@property (weak, nonatomic) IBOutlet UISwitch *switcher;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation SettingsViewController

- (IBAction)closeButton:(UIButton *)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _switcher.on = [_userDefaults boolForKey:@"cacheSettings"];
    if(!_switcher.on)
        _deleteButton.alpha = 0;
}

- (IBAction)enableCache:(UISwitch *)sender {
    if(sender.isOn){
        [UIView animateWithDuration:0.3 animations:^{
            _deleteButton.alpha = 1;
        }];
    }
    else{
        [UIView animateWithDuration:0.3 animations:^{
            _deleteButton.alpha = 0;
        }];
    }
    [_userDefaults setBool:sender.on forKey:@"cacheSettings"];
}

- (IBAction)deleteCacheButton:(UIButton *)sender {
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:DOCUMENTS error:&error];
    if ((error == nil)&([directoryContents count]>=1)) {
        for (NSString *path in directoryContents) {
            NSString *fullPath = [DOCUMENTS stringByAppendingPathComponent:path];
            BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
            if (!removeSuccess) {
                NSLog(@"fail delete");
            }
            else{
                NSLog(@"all del");
                [_deleteButton setTitle:@"Память успешно освобождена" forState:UIControlStateNormal];
            }
        }
    }
    else {
        [_deleteButton setTitle:@"Нет кешированных фото альбомов" forState:UIControlStateNormal];
    }
    _deleteButton.enabled = NO;
}


@end
