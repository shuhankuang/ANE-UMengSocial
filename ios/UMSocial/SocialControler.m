//
//  SocialControler.m
//  UMSocial_Sdk_Demo
//
//  Created by mani on 13-7-18.
//  Copyright (c) 2013年 yeahugo. All rights reserved.
//

#import "SocialControler.h"
#import "UMSocialBarViewController.h"
#import "UMSocialConfig.h"
#import "UMSocialData.h"
#import "UMSocialTabBarController.h"
#import "UMSocialSnsService.h"
#import "UMSocialData.h"
#import "WXApi.h"
#import "UMSocialConfig.h"
#import "FlashRuntimeExtensions.h"

#define shared (const uint8_t*)"shared"
#define ok (const uint8_t*)"200"

@implementation SocialControler
{
    CGSize size;
    UMSocialData *socialData;
}

@synthesize window = _window;

-(id) init
{
    self = [super init];
    
    size = [UIScreen mainScreen].bounds.size;
    size = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? size : CGSizeMake(size.height, size.width);
    
    return self;
}

-(void) initBar
{
    [UMSocialData openLog:NO];
    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
    [UMSocialConfig setSnsPlatformNames:@[UMShareToSina,UMShareToTencent,UMShareToQzone,UMShareToEmail]];
    [UMSocialConfig setSupportSinaSSO:NO];
    UIViewController *uic = self.window.rootViewController;
    [uic addChildViewController:self];
    [uic.view addSubview:self.view];
    socialData = [[UMSocialData alloc] initWithIdentifier:@"share"];
    _socialBar = [[UMSocialBar alloc] initWithUMSocialData:socialData withViewController:self.window.rootViewController];
    _socialBar.socialUIDelegate = self;
    _socialBar.hidden = YES;
    [self.view addSubview:_socialBar];
    UIApplication *uia = [UIApplication sharedApplication];
    if(uia.statusBarHidden)
        [self.view setFrame:CGRectMake(352, 713, 320, 50)];
    else
        [self.view setFrame:CGRectMake(352, 698, 320, 50)];
}

-(void) viewDidLoad
{
    [UMSocialControllerService defaultControllerService].socialUIDelegate = self;
}

-(void) status:(BOOL)visible
{
    if(!visible)
        _socialBar.hidden = YES;
    else
        _socialBar.hidden = NO;
    NSLog(@"status: %c",_socialBar.hidden);
}

-(void) share:(NSString *)text image:(NSString *)img
{
    
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    UITouch* any_touch = [touches anyObject];
//    float radius = [[any_touch valueForKey:@"pathMajorRadius"] floatValue];
    if(_socialBar)
    {
        CGRect rect = _socialBar.frame;
        NSLog(@"Frame: %f, %f, %f, %f",rect.size.width, rect.size.height, rect.origin.x, rect.origin.y);
//        [self.view setFrame:rect];
    }
}

-(void) share:(NSString*)dataID shareText:(NSString *)text imageUrl:(NSString *)imageUrl title:(NSString *)title
{
    if(!title)
        title = @"分享给你有意思的儿童安全内容";
//    UMSocialData *socialData = [[UMSocialData alloc] initWithIdentifier:dataID withTitle:title];
    [socialData setIdentifier:dataID];
    [socialData setTitle:title];
    if(text)
        socialData.shareText = text;
    if(imageUrl)
        socialData.shareImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
    UMSocialControllerService *scs = [[UMSocialControllerService alloc] initWithUMSocialData:socialData];
    scs.socialUIDelegate = self;
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    snsPlatform.snsClickHandler(self.window.rootViewController, scs, YES);
    
}

-(void) dataID:(NSString*)dataID shareText:(NSString *)text imageUrl:(NSString *)imageUrl title:(NSString *)title
{
    [socialData setIdentifier:dataID];
    [socialData setTitle:title];
    if(text)
        socialData.shareText = text;
    if(imageUrl)
        socialData.shareImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
    if(title)
        socialData.title = title;    
//    [_socialBar setSocialData:socialData];
    _socialBar.socialData = socialData;
    [_socialBar updateButtonNumber];
    _socialBar.hidden = NO;
    NSLog(@"dataID2: %@",dataID);
}

-(void) didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    if(response.responseCode == 200)
        FREDispatchStatusEventAsync(self.freContext, shared, (uint8_t*)ok);
}

@end