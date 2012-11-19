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

#import <Foundation/Foundation.h>
#import "VkontakteViewController.h"

extern NSString * const vkAppId;
extern NSString * const vkPermissions;
extern NSString * const vkRedirectUrl;

@protocol VkontakteDelegate;

@interface Vkontakte : NSObject <VkontakteViewControllerDelegate, UIAlertViewDelegate>
{    

    NSString *accessToken;
    NSDate *expirationDate;
    NSString *userId;
    NSString *email;

    BOOL _isCaptcha;
}

@property (nonatomic, weak) id <VkontakteDelegate> delegate;

+ (id)sharedInstance;
- (BOOL)isAuthorized;
- (void)authenticate;
- (void)logout;
- (void)getUserInfo;
- (void)postMessageToWall:(NSString *)message;
- (void)postMessageToWall:(NSString *)message link:(NSURL *)url;
- (void)postImageToWall:(UIImage *)image;
- (void)postImageToWall:(UIImage *)image text:(NSString *)message;
- (void)postImageToWall:(UIImage *)image text:(NSString *)message link:(NSURL *)url;
-(void) getUserAlbums;
-(void) getUserAlbumsCount;
-(void) getUserAlbumsPhoto:(NSString *)albumsAid;
-(NSArray *) getUserTechnicalAlbums;

@end

@protocol VkontakteDelegate <NSObject>
@required
- (void)vkontakteDidFailedWithError:(NSError *)error;
- (void)showVkontakteAuthController:(UIViewController *)controller;
- (void)vkontakteAuthControllerDidCancelled;
@optional
- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte;
- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte;

- (void)vkontakteDidFinishGettinUserInfo:(NSDictionary *)info;
- (void)vkontakteDidFinishPostingToWall:(NSDictionary *)responce;
- (void)vkontakteDidFinishGettinUserAlbumsCount:(NSDictionary *)info;
- (void)vkontakteDidFinishGettinAlbumsPhoto:(NSDictionary *)info;

@end
