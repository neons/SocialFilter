/*
 * Copyright 2011 Andrey Yastrebov
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@protocol VkontakteViewControllerDelegate;
@interface VkontakteViewController : UIViewController <UIWebViewDelegate, MBProgressHUDDelegate>
{
    MBProgressHUD *_hud;
    UIWebView *_webView;
    NSURL *_authLink;
    NSString *_userEmail;
}

@property (nonatomic, weak) id <VkontakteViewControllerDelegate> delegate;  

- (id)initWithAuthLink:(NSURL *)link;

@end

@protocol VkontakteViewControllerDelegate <NSObject>
@optional
- (void)authorizationDidSucceedWithToke:(NSString *)accessToken 
                                 userId:(NSString *)userId 
                                expDate:(NSDate *)expDate
                              userEmail:(NSString *)email;
- (void)authorizationDidFailedWithError:(NSError *)error;
- (void)authorizationDidCanceled;
@end