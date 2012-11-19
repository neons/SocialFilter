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

#import "Vkontakte.h"

@interface Vkontakte (Private)

- (void)storeSession;
- (BOOL)isSessionValid;
- (void)getCaptcha;
- (NSDictionary *)sendRequest:(NSString *)reqURl withCaptcha:(BOOL)captcha;
- (NSDictionary *)sendPOSTRequest:(NSString *)reqURl withImageData:(NSData *)imageData;
- (NSString *)URLEncodedString:(NSString *)str;
@end

@implementation Vkontakte (Private)

- (void)storeSession
{
    // Save authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"VKAccessTokenKey"];
    [defaults setObject:expirationDate forKey:@"VKExpirationDateKey"];
    [defaults setObject:userId forKey:@"VKUserID"];
    [defaults setObject:email forKey:@"VKUserEmail"];
    [defaults synchronize];
}

- (BOOL)isSessionValid 
{
    return (accessToken != nil && expirationDate != nil && userId != nil
            && NSOrderedDescending == [expirationDate compare:[NSDate date]]);
}

- (void)getCaptcha 
{
    NSString *captcha_img = [[NSUserDefaults standardUserDefaults] objectForKey:@"captcha_img"];
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Введите код:\n\n\n\n\n"
                                                          message:@"\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 45.0, 130.0, 50.0)];
    imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:captcha_img]]];
    [myAlertView addSubview:imageView];
    
    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 110.0, 260.0, 25.0)];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    
    myTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    myTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    myTextField.tag = 33;
    
    [myAlertView addSubview:myTextField];
    [myAlertView show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(_isCaptcha && buttonIndex == 1)
    {
        _isCaptcha = NO;
        
        UITextField *myTextField = (UITextField *)[actionSheet viewWithTag:33];
        [[NSUserDefaults standardUserDefaults] setObject:myTextField.text forKey:@"captcha_user"];
        NSLog(@"Captcha entered: %@",myTextField.text);
        
        // Вспоминаем какой был последний запрос и делаем его еще раз
        NSString *request = [[NSUserDefaults standardUserDefaults] objectForKey:@"request"];
        
        NSDictionary *newRequestDict =[self sendRequest:request withCaptcha:YES];
        NSString *errorMsg = [[newRequestDict  objectForKey:@"error"] objectForKey:@"error_msg"];
        if(errorMsg) 
        {
            NSError *error = [NSError errorWithDomain:@"vk.com" 
                                                 code:[[[newRequestDict  objectForKey:@"error"] objectForKey:@"error_code"] intValue] 
                                             userInfo:[newRequestDict  objectForKey:@"error"]];
            if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)]) 
            {
                [self.delegate vkontakteDidFailedWithError:error];
            }
            
        } 
        else 
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFinishPostingToWall:)]) 
            {
                [self.delegate vkontakteDidFinishPostingToWall:newRequestDict];
            }
            
        }
    }
}

- (NSDictionary *)sendRequest:(NSString *)reqURl withCaptcha:(BOOL)captcha 
{
    if(captcha == YES)
    {
        NSString *captcha_sid = [[NSUserDefaults standardUserDefaults] objectForKey:@"captcha_sid"];
        NSString *captcha_user = [[NSUserDefaults standardUserDefaults] objectForKey:@"captcha_user"];
        reqURl = [reqURl stringByAppendingFormat:@"&captcha_sid=%@&captcha_key=%@", captcha_sid, [self URLEncodedString: captcha_user]];
    }
    NSLog(@"Sending request: %@", reqURl);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqURl] 
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                                                       timeoutInterval:60.0]; 
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if(responseData)
    {        
        NSError* error;
        NSDictionary* dict = [NSJSONSerialization 
                              JSONObjectWithData:responseData                              
                              options:kNilOptions 
                              error:&error];
        
        NSString *errorMsg = [[dict objectForKey:@"error"] objectForKey:@"error_msg"];
        
        NSLog(@"Server response: %@ \nError: %@", dict, errorMsg);
        
        if([errorMsg isEqualToString:@"Captcha needed"])
        {
            _isCaptcha = YES;
            NSString *captcha_sid = [[dict objectForKey:@"error"] objectForKey:@"captcha_sid"];
            NSString *captcha_img = [[dict objectForKey:@"error"] objectForKey:@"captcha_img"];
            [[NSUserDefaults standardUserDefaults] setObject:captcha_img forKey:@"captcha_img"];
            [[NSUserDefaults standardUserDefaults] setObject:captcha_sid forKey:@"captcha_sid"];
            [[NSUserDefaults standardUserDefaults] setObject:reqURl forKey:@"request"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self getCaptcha];
        }
        
        return dict;
    }
    return nil;
}

- (NSDictionary *)sendPOSTRequest:(NSString *)reqURl withImageData:(NSData *)imageData 
{
    NSLog(@"Sending request: %@", reqURl);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqURl] 
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                                                       timeoutInterval:60.0]; 
    [request setHTTPMethod:@"POST"]; 
    
    [request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuid);
    CFRelease(uuid);
    NSString *stringBoundary = [NSString stringWithFormat:@"0xKhTmLbOuNdArY-%@",uuidString];
    NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data;  boundary=%@", stringBoundary];
    
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];        
    [body appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
   
    if(responseData)
    {        
        NSError* error;
        NSDictionary* dict = [NSJSONSerialization 
                              JSONObjectWithData:responseData
                              options:kNilOptions 
                              error:&error];
        
        NSString *errorMsg = [[dict objectForKey:@"error"] objectForKey:@"error_msg"];
        
        NSLog(@"Server response: %@ \nError: %@", dict, errorMsg);
        
        return dict;
    }
    return nil;
}

- (NSString *)URLEncodedString:(NSString *)str
{
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (__bridge CFStringRef)str,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
	return result;
}

@end

@implementation Vkontakte

//#warning Provide your vkontakte app id
NSString * const vkAppId = @"3184669";//@"YOUR_VK_APP_ID";
NSString * const vkPermissions = @"wall,photos,offline";
NSString * const vkRedirectUrl = @"http://oauth.vk.com/blank.html";

@synthesize delegate;

#pragma mark - Initialize

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"VKAccessTokenKey"] 
            && [defaults objectForKey:@"VKExpirationDateKey"]
            && [defaults objectForKey:@"VKUserID"]
            && [defaults objectForKey:@"VKUserEmail"]) 
        {
            accessToken = [defaults objectForKey:@"VKAccessTokenKey"];
            expirationDate = [defaults objectForKey:@"VKExpirationDateKey"];
            userId = [defaults objectForKey:@"VKUserID"];
            email = [defaults objectForKey:@"VKUserEmail"];
        }
    }
    return self;
}

- (BOOL)isAuthorized
{    
    if (![self isSessionValid]) 
    {
        return NO;
    } 
    else 
    {
        return YES;
    }
}

- (void)authenticate
{
    NSString *authLink = [NSString stringWithFormat:@"http://oauth.vk.com/oauth/authorize?client_id=%@&scope=%@&redirect_uri=%@&display=touch&response_type=token", vkAppId, vkPermissions, vkRedirectUrl];
    NSURL *url = [NSURL URLWithString:authLink];
    
    VkontakteViewController *vkontakteViewController = [[VkontakteViewController alloc] initWithAuthLink:url];
    vkontakteViewController.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vkontakteViewController];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(showVkontakteAuthController:)]) 
    {
        [self.delegate showVkontakteAuthController:navController];
    }
}

- (void)logout
{
    NSString *logout = [NSString stringWithFormat:@"http://api.vk.com/oauth/logout?client_id=%@", vkAppId];
  //  https://oauth.vk.com/
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:logout] 
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                                                       timeoutInterval:60.0]; 
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request 
                                                 returningResponse:nil 
                                                             error:nil];
    NSLog(@"logout request %@", logout);
    NSLog(@"responseData %@",responseData);
    if(responseData)
    {
        NSError* error;
        NSDictionary* dict = [NSJSONSerialization 
                              JSONObjectWithData:responseData
                              options:kNilOptions 
                              error:&error];
        NSLog(@"Logout: %@", dict);
        
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray* vkCookies1 = [cookies cookiesForURL:
                               [NSURL URLWithString:@"http://api.vk.com"]];
        NSArray* vkCookies2 = [cookies cookiesForURL:
                               [NSURL URLWithString:@"http://vk.com"]];
        NSArray* vkCookies3 = [cookies cookiesForURL:
                               [NSURL URLWithString:@"http://login.vk.com"]];
        NSArray* vkCookies4 = [cookies cookiesForURL:
                               [NSURL URLWithString:@"http://oauth.vk.com"]];
        
        for (NSHTTPCookie* cookie in vkCookies1) 
        {
            [cookies deleteCookie:cookie];
        }
        for (NSHTTPCookie* cookie in vkCookies2) 
        {
            [cookies deleteCookie:cookie];
        }
        for (NSHTTPCookie* cookie in vkCookies3) 
        {
            [cookies deleteCookie:cookie];
        }
        for (NSHTTPCookie* cookie in vkCookies4) 
        {
            [cookies deleteCookie:cookie];
        }
        
        // Remove saved authorization information if it exists and it is
        // ok to clear it (logout, session invalid, app unauthorized)
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"VKAccessTokenKey"]) 
        {
            [defaults removeObjectForKey:@"VKAccessTokenKey"];
            [defaults removeObjectForKey:@"VKExpirationDateKey"];
            [defaults removeObjectForKey:@"VKUserID"];
            [defaults removeObjectForKey:@"VKUserEmail"];
            [defaults synchronize];
            
            // Nil out the session variables to prevent
            // the app from thinking there is a valid session
            if (accessToken) 
            {
                accessToken = nil;
            }
            if (expirationDate) 
            {
                expirationDate = nil;
            }
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFinishLogOut:)]) 
        {
            [self.delegate vkontakteDidFinishLogOut:self];
        }
    }
}
- (void)getUserAlbums
{    
    if (![self isAuthorized]) return;
    
    NSMutableString *requestString = [[NSMutableString alloc] init];
	[requestString appendFormat:@"%@/", @"https://api.vk.com/method"];
    [requestString appendFormat:@"%@?", @"photos.getAll"];
    [requestString appendFormat:@"uid=%@&", userId];
    [requestString appendFormat:@"access_token=%@", accessToken];
    NSLog(@"requestString getUserAlbums %@",requestString);
	NSURL *url = [NSURL URLWithString:requestString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	NSData *response = [NSURLConnection sendSynchronousRequest:request 
											 returningResponse:nil 
														 error:nil];
    
    NSError* error;
    NSDictionary* parsedDictionary2 = [NSJSONSerialization 
                                      JSONObjectWithData:response
                                      options:kNilOptions 
                                      error:&error];
    
    NSArray *array = [parsedDictionary2 objectForKey:@"response"];

    if ([parsedDictionary2 objectForKey:@"response"]) 
    {
        NSMutableDictionary *mutableDicti=[[NSMutableDictionary alloc]initWithDictionary:parsedDictionary2];        

        id objectInstance;
        int number=1;
        
        for (objectInstance in array)
            [mutableDicti setObject:objectInstance forKey:[NSString stringWithFormat:@"photo%i",number++]];
       
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFinishGettinUserInfo:)])
        {
            [self.delegate vkontakteDidFinishGettinUserInfo:mutableDicti];
        }
    }
    else
    {        
        NSDictionary *errorDict = [parsedDictionary2 objectForKey:@"error"];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
        {
            NSError *error = [NSError errorWithDomain:@"http://api.vk.com/method" 
                                                 code:[[errorDict objectForKey:@"error_code"] intValue]
                                             userInfo:errorDict];
            
            if (error.code == 5) 
            {
                [self logout];
            }
            
            [self.delegate vkontakteDidFailedWithError:error];
        }
    }
}

- (void)getUserAlbumsCount
{    
    if (![self isAuthorized]) return;
    
    NSMutableString *requestString = [[NSMutableString alloc] init];
	[requestString appendFormat:@"%@/", @"https://api.vk.com/method"];
    [requestString appendFormat:@"%@?", @"photos.getAlbums"];
    [requestString appendFormat:@"uid=%@&", userId];
     NSMutableString *need_covers = [[NSMutableString alloc] init];
     [need_covers appendString:@"1"];
    [requestString appendFormat:@"need_covers=%@&",need_covers];
   
    [requestString appendFormat:@"access_token=%@", accessToken];
    NSLog(@"request %@",requestString);
	NSURL *url = [NSURL URLWithString:requestString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	NSData *response = [NSURLConnection sendSynchronousRequest:request 
											 returningResponse:nil 
														 error:nil];
	
    
    NSError* error;
    NSDictionary* parsedDictionary = [NSJSONSerialization 
                                       JSONObjectWithData:response
                                       options:kNilOptions 
                                       error:&error];

    
    NSArray *array = [parsedDictionary objectForKey:@"response"];
    
    if ([parsedDictionary objectForKey:@"response"]) 
    {
      
        NSMutableDictionary *mutableDicti=[[NSMutableDictionary alloc]init];
        int number=1;
        
        NSArray* arrayForTechnical = [self getUserTechnicalAlbums];
        if (arrayForTechnical){
        for (id objectInstance in arrayForTechnical)
            [mutableDicti setObject:objectInstance forKey:[NSString stringWithFormat:@"Album%i",number++]];
        }
        for (id objectInstance in array)
            [mutableDicti setObject:objectInstance forKey:[NSString stringWithFormat:@"Album%i",number++]];
        
        
        
       
        
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFinishGettinUserAlbumsCount:)])
        {
            [self.delegate vkontakteDidFinishGettinUserAlbumsCount:mutableDicti];
        }
    }
    else
    {        
        NSDictionary *errorDict = [parsedDictionary objectForKey:@"error"];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
        {
            NSError *error = [NSError errorWithDomain:@"http://api.vk.com/method" 
                                                 code:[[errorDict objectForKey:@"error_code"] intValue]
                                             userInfo:errorDict];
            
            if (error.code == 5) 
            {
                [self logout];
            }
            
            [self.delegate vkontakteDidFailedWithError:error];
        }
    }
}

-(void) getUserAlbumsPhoto:(NSString *)albumsAid;
{    
    if (![self isAuthorized]) return;
    
    NSMutableString *requestString = [[NSMutableString alloc] init];
	[requestString appendFormat:@"%@/", @"https://api.vk.com/method"];
    [requestString appendFormat:@"%@?", @"photos.get"];
    [requestString appendFormat:@"uid=%@&", userId];
    [requestString appendFormat:@"aid=%@&",albumsAid];
    [requestString appendFormat:@"access_token=%@", accessToken];
    NSLog(@"request %@",requestString);
	NSURL *url = [NSURL URLWithString:requestString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	NSData *response = [NSURLConnection sendSynchronousRequest:request 
											 returningResponse:nil 
														 error:nil];

    
    NSError* error;
    NSDictionary* parsedDictionary = [NSJSONSerialization 
                                      JSONObjectWithData:response
                                      options:kNilOptions 
                                      error:&error];
    
    
    NSArray *array = [parsedDictionary objectForKey:@"response"];
    
    if ([parsedDictionary objectForKey:@"response"]) 
    {
        NSMutableDictionary *mutableDicti=[[NSMutableDictionary alloc]init];
        
        int numberRow=1;
        int numberSection=0;
        int index=0;

        while ([mutableDicti count]<([array count])) {
            [mutableDicti setObject:[array objectAtIndex:index++] forKey:[NSString stringWithFormat:@"PhotoInSection%iInRow%i",numberSection, numberRow++]];
            if ((numberRow%5)==0) {
                numberSection++;
                numberRow=1;
            }
   
        }
        
        
       
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFinishGettinAlbumsPhoto:)])
        {
            [self.delegate vkontakteDidFinishGettinAlbumsPhoto:mutableDicti];
        }
    }
    else
    {        
        NSDictionary *errorDict = [parsedDictionary objectForKey:@"error"];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
        {
            NSError *error = [NSError errorWithDomain:@"http://api.vk.com/method" 
                                                 code:[[errorDict objectForKey:@"error_code"] intValue]
                                             userInfo:errorDict];
            
            if (error.code == 5) 
            {
                [self logout];
            }
            
            [self.delegate vkontakteDidFailedWithError:error];
        }
    }
}

-(NSArray *) getUserTechnicalAlbums
{    
    
    BOOL haveError=NO;
    NSDictionary *errorDictionary;
    NSMutableDictionary *finalDictionary;
    
   
    
    NSArray* arrayTechnicalAids = [NSArray arrayWithObjects:@"wall", @"profile", @"saved", nil];
    
    
    for (id object in arrayTechnicalAids) {
        NSMutableString *requestString = [[NSMutableString alloc] init];
        [requestString appendFormat:@"%@/", @"https://api.vk.com/method"];
        [requestString appendFormat:@"%@?", @"photos.get"];
        [requestString appendFormat:@"uid=%@&", userId];
        NSMutableString *technicalRequest = requestString;
        [technicalRequest appendFormat:@"aid=%@&",object]; //wall profile saved
    
        [technicalRequest appendFormat:@"access_token=%@", accessToken];
        NSURL *url = [NSURL URLWithString:technicalRequest];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        NSData *response = [NSURLConnection sendSynchronousRequest:request 
                                                 returningResponse:nil 
                                                             error:nil];
        
        NSError* error;
        NSDictionary* parsedDictionary = [NSJSONSerialization 
                                          JSONObjectWithData:response
                                          options:kNilOptions 
                                          error:&error];
        if (![parsedDictionary objectForKey:@"response"]) {
            haveError = YES;
            errorDictionary = [NSDictionary dictionaryWithDictionary:parsedDictionary];
        }
        else
        {
            if(!finalDictionary){
                finalDictionary = [[NSMutableDictionary alloc] init]; 
            }
            [finalDictionary setObject:[parsedDictionary objectForKey:@"response"] forKey:object];
        }
                                                                         
    }
    
    
    NSMutableArray *lastArray = [[NSMutableArray alloc] init];
    
    if (haveError == NO) 
    {
       for (NSString*key in finalDictionary)
       {
           NSArray * lolarray = [finalDictionary objectForKey:key];
           
           id currentObject = [lolarray lastObject];
           if (currentObject){
          NSString * thumb_src = [currentObject objectForKey:@"src_small"];
           NSString *size = [NSString stringWithFormat:@"%i",[lolarray count]];
               NSString *aid = key;
               NSString *title = [[NSString alloc] init];
               if (key==@"profile") {
                   title=@"Фотографии с моей страницы"; 
               }
               else if (key==@"wall"){
                   title=@"Фотографии на моей стене"; 
               }
               else if (key==@"saved"){
                   title=@"Сохранненные фотографии";
               }
               
               
               NSDictionary *technicalAlbum=[[NSDictionary alloc] initWithObjectsAndKeys:thumb_src,@"thumb_src", title, @"title", size,@"size", aid, @"aid", nil];
               [lastArray addObject:technicalAlbum];
           }
       }
               return lastArray;
    }
    else
    {        
        NSDictionary *errorDict = [errorDictionary objectForKey:@"error"];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
        {
            NSError *error = [NSError errorWithDomain:@"http://api.vk.com/method" 
                                                 code:[[errorDict objectForKey:@"error_code"] intValue]
                                             userInfo:errorDict];
            
            if (error.code == 5) 
            {
                [self logout];
            }
            
            [self.delegate vkontakteDidFailedWithError:error];
        }
    }
    return nil;
}


- (void)getUserInfo
{    
    if (![self isAuthorized]) return;
    
    NSMutableString *requestString = [[NSMutableString alloc] init];
	[requestString appendFormat:@"%@/", @"https://api.vk.com/method"];
    [requestString appendFormat:@"%@?", @"getProfiles"];
    [requestString appendFormat:@"uid=%@&", userId];
    NSMutableString *fields = [[NSMutableString alloc] init];
    [fields appendString:@"sex,bdate,photo,photo_big"];
    [requestString appendFormat:@"fields=%@&", fields];
    [requestString appendFormat:@"access_token=%@", accessToken];
    
	NSURL *url = [NSURL URLWithString:requestString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	NSData *response = [NSURLConnection sendSynchronousRequest:request 
											 returningResponse:nil 
														 error:nil];
	NSString *responseString = [[NSString alloc] initWithData:response 
                                                     encoding:NSUTF8StringEncoding];
	NSLog(@"%@",responseString);
    
    NSError* error;
    NSDictionary* parsedDictionary = [NSJSONSerialization 
                          JSONObjectWithData:response
                          options:kNilOptions 
                          error:&error];
    
    NSArray *array = [parsedDictionary objectForKey:@"response"];
    if ([parsedDictionary objectForKey:@"response"]) 
    {
        parsedDictionary = [array objectAtIndex:0];
        parsedDictionary = [NSMutableDictionary dictionaryWithDictionary:parsedDictionary];
        [parsedDictionary setValue:email forKey:@"email"];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFinishGettinUserInfo:)])
        {
            [self.delegate vkontakteDidFinishGettinUserInfo:parsedDictionary];
        }

    }
    else
    {        
        NSDictionary *errorDict = [parsedDictionary objectForKey:@"error"];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
        {
            NSError *error = [NSError errorWithDomain:@"http://api.vk.com/method" 
                                                 code:[[errorDict objectForKey:@"error_code"] intValue]
                                             userInfo:errorDict];
            
            if (error.code == 5) 
            {
                [self logout];
            }
            
            [self.delegate vkontakteDidFailedWithError:error];
        }
    }
}

- (void)postMessageToWall:(NSString *)message
{
    if (![self isAuthorized]) return;
            
    NSString *sendTextMessage = [NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&access_token=%@&message=%@", 
                                 userId, 
                                 accessToken, 
                                 [self URLEncodedString:message]];
    NSLog(@"sendTextMessage: %@", sendTextMessage);
    
    NSDictionary *result = [self sendRequest:sendTextMessage withCaptcha:NO];
    // Если есть описание ошибки в ответе
    NSString *errorMsg = [[result objectForKey:@"error"] objectForKey:@"error_msg"];
    if(errorMsg) 
    {
        NSDictionary *errorDict = [result objectForKey:@"error"];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
        {
            NSError *error = [NSError errorWithDomain:@"http://api.vk.com/method" 
                                                 code:[[errorDict objectForKey:@"error_code"] intValue]
                                             userInfo:errorDict];
            
            if (error.code == 5) 
            {
                [self logout];
            }
            
            [self.delegate vkontakteDidFailedWithError:error];
        }
    } 
    else 
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFinishPostingToWall:)]) 
        {
            [self.delegate vkontakteDidFinishPostingToWall:result];
        }
    }
}

- (void)postMessageToWall:(NSString *)message link:(NSURL *)url
{
    if (![self isAuthorized]) return;
    
    NSString *link = [url absoluteString];
    
    NSString *sendTextAndLinkMessage = [NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&access_token=%@&message=%@&attachment=%@", 
                                        userId, 
                                        accessToken, 
                                        [self URLEncodedString:message], 
                                        link];
    
    NSLog(@"sendTextAndLinkMessage: %@", sendTextAndLinkMessage);
    
    // Если запрос более сложный мы можем работать дальше с полученным ответом
    NSDictionary *result = [self sendRequest:sendTextAndLinkMessage withCaptcha:NO];
    NSString *errorMsg = [[result objectForKey:@"error"] objectForKey:@"error_msg"];
    if(errorMsg) 
    {
        NSDictionary *errorDict = [result objectForKey:@"error"];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
        {
            NSError *error = [NSError errorWithDomain:@"http://api.vk.com/method" 
                                                 code:[[errorDict objectForKey:@"error_code"] intValue]
                                             userInfo:errorDict];
            
            if (error.code == 5) 
            {
                [self logout];
            }
            
            [self.delegate vkontakteDidFailedWithError:error];
        }
    } 
    else 
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFinishPostingToWall:)]) 
        {
            [self.delegate vkontakteDidFinishPostingToWall:result];
        }
    }
}

- (void)postImageToWall:(UIImage *)image text:(NSString *)message link:(NSURL *)url
{
    if (![self isAuthorized]) return;
    
    NSString *getWallUploadServer = [NSString stringWithFormat:@"https://api.vk.com/method/photos.getWallUploadServer?owner_id=%@&access_token=%@", userId, accessToken];
    
    NSDictionary *uploadServer = [self sendRequest:getWallUploadServer withCaptcha:NO];
    
    NSString *upload_url = [[uploadServer objectForKey:@"response"] objectForKey:@"upload_url"];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    
    NSDictionary *postDictionary = [self sendPOSTRequest:upload_url withImageData:imageData];
    
    NSString *hash = [postDictionary objectForKey:@"hash"];
    NSString *photo = [postDictionary objectForKey:@"photo"];
    NSString *server = [postDictionary objectForKey:@"server"];
    
    NSString *saveWallPhoto = [NSString stringWithFormat:@"https://api.vk.com/method/photos.saveWallPhoto?owner_id=%@&access_token=%@&server=%@&photo=%@&hash=%@", 
                               userId, 
                               accessToken,
                               server,
                               photo,
                               hash];
    
    saveWallPhoto = [saveWallPhoto stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *saveWallPhotoDict = [self sendRequest:saveWallPhoto withCaptcha:NO];
    
    NSDictionary *photoDict = [[saveWallPhotoDict objectForKey:@"response"] lastObject];
    NSString *photoId = [photoDict objectForKey:@"id"];
    
    NSString *postToWallLink;
    
    if (url) 
    {
        postToWallLink = [NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&access_token=%@&message=%@&attachments=%@,%@", 
                          userId, 
                          accessToken, 
                          [self URLEncodedString:message], 
                          photoId,
                          [url absoluteURL]];
    } 
    else 
    {
        postToWallLink = [NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&access_token=%@&message=%@&attachment=%@", 
                          userId, 
                          accessToken, 
                          [self URLEncodedString:message], 
                          photoId];
    }
    
    NSDictionary *postToWallDict = [self sendRequest:postToWallLink withCaptcha:NO];
    NSString *errorMsg = [[postToWallDict  objectForKey:@"error"] objectForKey:@"error_msg"];
    if(errorMsg) 
    {
        NSDictionary *errorDict = [postToWallDict objectForKey:@"error"];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
        {
            NSError *error = [NSError errorWithDomain:@"http://api.vk.com/method" 
                                                 code:[[errorDict objectForKey:@"error_code"] intValue]
                                             userInfo:errorDict];
            
            if (error.code == 5) 
            {
                [self logout];
            }
            
            [self.delegate vkontakteDidFailedWithError:error];
        }
    } 
    else 
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFinishPostingToWall:)]) 
        {
            [self.delegate vkontakteDidFinishPostingToWall:postToWallDict];
        }
    }
}

- (void)postImageToWall:(UIImage *)image
{   
    [self postImageToWall:image text:@""];
}

- (void)postImageToWall:(UIImage *)image text:(NSString *)message
{
    [self postImageToWall:image text:message link:nil];
}

#pragma mark - VkontakteViewControllerDelegate

- (void)authorizationDidSucceedWithToke:(NSString *)_accessToken 
                                 userId:(NSString *)_userId 
                                expDate:(NSDate *)_expDate
                              userEmail:(NSString *)_email

{
    accessToken = _accessToken;
    userId = _userId;
    expirationDate = _expDate;
    email = _email;
    
    [self storeSession];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFinishLogin:)]) 
    {
        [self.delegate vkontakteDidFinishLogin:self];
    }
}

- (void)authorizationDidFailedWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)]) 
    {
        [self.delegate vkontakteDidFailedWithError:error];
    }
}

- (void)authorizationDidCanceled
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteAuthControllerDidCancelled)]) 
    {
        [self.delegate vkontakteAuthControllerDidCancelled];
    }
}

- (void)didFinishGettingUserEmail:(NSString *)_email
{
    email = _email;
}

@end
