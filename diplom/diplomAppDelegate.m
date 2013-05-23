//
//  diplomAppDelegate.m
//  diplom
//
//  Created by admin on 08.10.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "diplomAppDelegate.h"

#define APP_ID @"18dfa27b99a44a14bc741aee591a01f8"
@interface diplomAppDelegate()
@property (strong, nonatomic) Reachability *internetReachability;
@end

@implementation diplomAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
   
    _internetReachability = [Reachability reachabilityForInternetConnection];
[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    [_internetReachability startNotifier];
    [self reachabilityChanged:nil];
   _instagram = [[Instagram alloc] initWithClientId:APP_ID
                                                delegate:nil];
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // Yes, so just open the session (this won't display any UX).
    }
        return YES;
}




- (void) reachabilityChanged: (NSNotification* )not{
    NetworkStatus netStatus = _internetReachability.currentReachabilityStatus;
    
    switch (netStatus) {
        case NotReachable:
            _internet = NO;
             break;
        case ReachableViaWiFi:
            _internet = YES;
            break;
        case ReachableViaWWAN:
            _internet = YES;
            break;
    }
}


- (void)applicationWillResignActive:(UIApplication *)application{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{    
    NSString *stringUrl = [url absoluteString];
    if ([stringUrl rangeOfString:@"ig18dfa27b99a44a14bc741aee591a01f8://"].location == NSNotFound)
        return [FBSession.activeSession handleOpenURL:url];
    else
        return [self.instagram handleOpenURL:url]; 
    
   
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSString *stringUrl = [url absoluteString];
    if ([stringUrl rangeOfString:@"ig18dfa27b99a44a14bc741aee591a01f8://"].location == NSNotFound)
        return [FBSession.activeSession handleOpenURL:url];
    else
        return [self.instagram handleOpenURL:url]; 
}


- (void)applicationWillEnterForeground:(UIApplication *)application{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    [FBSession.activeSession handleDidBecomeActive];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
