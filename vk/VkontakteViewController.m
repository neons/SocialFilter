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

#import "VkontakteViewController.h"

@interface VkontakteViewController (Private)
- (NSString*)stringBetweenString:(NSString*)start 
                       andString:(NSString*)end 
                     innerString:(NSString*)str;
@end

@implementation VkontakteViewController (Private)

- (NSString*)stringBetweenString:(NSString*)start 
                       andString:(NSString*)end 
                     innerString:(NSString*)str 
{
    NSScanner* scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:nil];
    if ([scanner scanString:start intoString:nil]) 
    {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) 
        {
            return result;
        }
    }
    return nil;
}

@end

@implementation VkontakteViewController

@synthesize delegate;

- (id)initWithAuthLink:(NSURL *)link
{
    self = [super init];
    if (self) 
    {
        _authLink = link;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Отмена" 
                                                                              style:UIBarButtonItemStyleBordered 
                                                                             target:self 
                                                                             action:@selector(cancelButtonPressed:)];
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _webView = [[UIWebView alloc] initWithFrame:frame];
    _webView.autoresizesSubviews = YES;
    _webView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    _webView.delegate = self;
    [self.view addSubview:_webView];
    [_webView loadRequest:[NSURLRequest requestWithURL:_authLink]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)cancelButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(authorizationDidCanceled)])
    {
        [self.delegate authorizationDidCanceled];
    }
}

#pragma mark - WebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView 
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; 
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:_hud];
	_hud.dimBackground = YES;
    _hud.delegate = self;
    [_hud show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView 
{
    NSString *webViewText = [_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerText"];
    
    if ([webViewText caseInsensitiveCompare:@"security breach"] == NSOrderedSame) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Невозможно авторизироваться" 
                                                        message:@"Возможно Вы пытаетесь зайти из необычного места. Попробуйте авторизироваться на сайте vk.com и повторите попытку" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationDidFailedWithError:)]) 
        {
            [self.delegate authorizationDidFailedWithError:nil];
        }
    } 
    else if ([webView.request.URL.absoluteString rangeOfString:@"access_token"].location != NSNotFound) 
    {
        NSString *accessToken = [self stringBetweenString:@"access_token=" 
                                                andString:@"&" 
                                              innerString:[[[webView request] URL] absoluteString]];
        
        // Получаем id пользователя, пригодится нам позднее
        NSArray *userAr = [[[[webView request] URL] absoluteString] componentsSeparatedByString:@"&user_id="];
        NSString *user_id = [userAr lastObject];
        NSLog(@"User id: %@", user_id);
        
        NSString *expTime = [self stringBetweenString:@"expires_in=" 
                                            andString:@"&" 
                                          innerString:[[[webView request] URL] absoluteString]];
        NSDate *expirationDate = nil;
        if (expTime != nil) 
        {
            int expVal = [expTime intValue];
            if (expVal == 0) 
            {
                expirationDate = [NSDate distantFuture];
            } 
            else 
            {
                expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
            } 
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationDidSucceedWithToke:userId:expDate:userEmail:)]) 
        {
            [self.delegate authorizationDidSucceedWithToke:accessToken 
                                                userId:user_id 
                                               expDate:expirationDate
                                             userEmail:_userEmail];
        }
    } 
    else if ([webView.request.URL.absoluteString rangeOfString:@"error"].location != NSNotFound) 
    {
        NSLog(@"Error: %@", webView.request.URL.absoluteString);
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationDidFailedWithError:)]) 
        {
            [self.delegate authorizationDidFailedWithError:nil];
        }
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];  
    [_hud hide:YES];
    [_hud removeFromSuperview];
	_hud = nil;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error 
{
    
    NSLog(@"vkWebView Error: %@", [error localizedDescription]);
    if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationDidFailedWithError:)]) 
    {
        [self.delegate authorizationDidFailedWithError:error];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];  
    [_hud hide:YES];
    [_hud removeFromSuperview];
	_hud = nil;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType 
{    
    NSString *s = @"var filed = document.getElementsByClassName('filed'); "
    "var textField = filed[0];"
    "textField.value;";            
    NSString *email = [webView stringByEvaluatingJavaScriptFromString:s];
    if (([email length] != 0) && _userEmail == nil) 
    {
        _userEmail = email;
    }
    
    NSURL *URL = [request URL];
    // Пользователь нажал Отмена в веб-форме
    if ([[URL absoluteString] isEqualToString:@"http://api.vk.com/blank.html#error=access_denied&error_reason=user_denied&error_description=User%20denied%20your%20request"]) 
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationDidCanceled)]) 
        {
            [self.delegate authorizationDidCanceled];
        }
        return NO;
    }
	NSLog(@"Request: %@", [URL absoluteString]); 
	return YES;
}

@end
