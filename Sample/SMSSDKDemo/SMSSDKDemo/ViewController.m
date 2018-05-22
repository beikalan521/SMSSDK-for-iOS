//
//  ViewController.m
//  SMSSDKDemo
//
//  Created by youzu_Max on 2017/5/25.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "ViewController.h"
#import <SMS_SDK/SMSSDK.h>
#import <SMS_SDK/SMSSDK+ContactFriends.h>
#import "SMSSDKUI.h"
#import <MOBFoundation/MOBFoundation.h>

#define SMSSDKUIBundle [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"SMSSDKUI" ofType:@"bundle"]]

#define StatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define SMSSDKAlert(_S_, ...)     [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:(_S_), ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]

#define SMSSDKDEMORGB(colorHex) [UIColor colorWithRed:((float)((colorHex & 0xFF0000) >> 16)) / 255.0 green:((float)((colorHex & 0xFF00) >> 8)) / 255.0 blue:((float)(colorHex & 0xFF)) / 255.0 alpha:1.0]

#define SMSSDKDEMOColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configUI];
}

- (void)configUI
{
    
    float offset = 20;
    float topOffset = 50;
    float width = (self.view.frame.size.width - 20 - 2*offset) / 2.0;
    float height = (178.0 / 157.0) * width;
    
    
    //短信标题
    UILabel* label = [[UILabel alloc] init];
    label.frame = CGRectMake(offset, topOffset + StatusBarHeight, self.view.frame.size.width - 2 * offset, 26);
    label.text = NSLocalizedStringFromTableInBundle(@"smssdk", @"Localizable", SMSSDKUIBundle, nil);;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Helvetica" size:26];
    label.textColor = [UIColor blackColor];
    [self.view addSubview:label];
    
    //获取短信验证码
    {
        UIButton* regBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        regBtn.frame = CGRectMake(offset , 50 + 1 * 70 + StatusBarHeight, width, height);
        
        [regBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [regBtn addTarget:self action:@selector(getVerificationCodeText:) forControlEvents:UIControlEventTouchUpInside];
        [regBtn setBackgroundColor:SMSSDKDEMORGB(0xEFEFF3)];
        
        [self.view addSubview:regBtn];
        
        UIImageView *imageView = [UIImageView new];
        imageView.frame = CGRectMake((CGRectGetWidth(regBtn.frame) - ((77/124.0) * (height - 54))) / 2.0, 14, (77/124.0) * (height - 54), height - 54);
        imageView.image = [UIImage imageNamed:@"mobilecheck"];
        imageView.userInteractionEnabled = NO;
        [regBtn addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0, CGRectGetHeight(regBtn.frame) - 14 - 18, CGRectGetWidth(regBtn.frame), 14);
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"Helvetica" size:14];
        label.textColor = [UIColor blackColor];
        label.userInteractionEnabled = NO;
        label.text = NSLocalizedStringFromTableInBundle(@"RegisterByPhoneNumber", @"Localizable", SMSSDKUIBundle, nil);

        [regBtn addSubview:label];

    }

    //获取朋友列表按钮
    {
        UIButton* friendsBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        friendsBtn.frame = CGRectMake(self.view.frame.size.width - offset -  width, 50 + 1 * 70 + StatusBarHeight, width, height);
        [friendsBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [friendsBtn addTarget:self action:@selector(getAddressBookFriends) forControlEvents:UIControlEventTouchUpInside];
        [friendsBtn setBackgroundColor:SMSSDKDEMORGB(0xEFEFF3)];
        [self.view addSubview:friendsBtn];
        
        
        UIImageView *imageView = [UIImageView new];
        imageView.frame = CGRectMake((CGRectGetWidth(friendsBtn.frame) - ((77/124.0) * (height - 54))) / 2.0, 14, (77/124.0) * (height - 54), height - 54);
        imageView.image = [UIImage imageNamed:@"friendlist"];
        imageView.userInteractionEnabled = NO;
        [friendsBtn addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0, CGRectGetHeight(friendsBtn.frame) - 14 - 18, CGRectGetWidth(friendsBtn.frame), 14);
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"Helvetica" size:14];
        label.textColor = [UIColor blackColor];
        label.text = NSLocalizedStringFromTableInBundle(@"addressbookfriends", @"Localizable", SMSSDKUIBundle, nil);
        label.userInteractionEnabled = NO;

        [friendsBtn addSubview:label];
    }
    
    //UIImage *navImage = [self GetImageWithColor:[UIColor whiteColor] andHeight:44];
    //[self.navigationController.navigationBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBarHidden = YES;

}

- (UIImage*) GetImageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect r= CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}


- (void)getVerificationCodeText:(id)sender
{
    [self getVerificationCodeWithMethod:SMSGetCodeMethodSMS];
}

- (void)getVerificationCodeVoice:(id)sender
{
    [self getVerificationCodeWithMethod:SMSGetCodeMethodVoice];
}

- (void)getVerificationCodeWithMethod:(SMSGetCodeMethod)method
{
    //不需要模板id
    //SMSSDKUIGetCodeViewController *vc = [[SMSSDKUIGetCodeViewController alloc] initWithMethod:method];
    
    //需要模板id,请后台申请 模板id
    SMSSDKUIGetCodeViewController *vc = [[SMSSDKUIGetCodeViewController alloc] initWithMethod:method template:@"1319972"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)getAddressBookFriends
{
    [SMSSDKUIProcessHUD showProcessHUDWithInfo:@"正在获取好友列表..."];
    [SMSSDK getAllContactFriends:^(NSError *error, NSArray *friendsArray) {
        
        if (error)
        {
            if(error.code == NSURLErrorNotConnectedToInternet)
            {
                [SMSSDKUIProcessHUD showMsgHUDWithInfo:NSLocalizedStringFromTableInBundle(@"nonetwork", @"Localizable", SMSSDKUIBundle, nil)];
                [SMSSDKUIProcessHUD dismissWithDelay:1.5 result:^{
                    
                }];
            }
            else
            {
                [SMSSDKUIProcessHUD dismiss];
                //SMSSDKAlert(@"获取好友列表失败:%@",[ViewController errorTextWithError:error]);
                SMSSDKAlert(@"%@",[ViewController errorTextWithError:error]);
            }

        }
        else
        {
            NSLog(@"%@",friendsArray);
            [SMSSDKUIProcessHUD showSuccessInfo:[NSString stringWithFormat:@"获取到%zd条好友信息",friendsArray.count]];
            [SMSSDKUIProcessHUD dismissWithDelay:1 result:^{
                
                SMSSDKUIContactFriendsViewController *vc = [[SMSSDKUIContactFriendsViewController alloc] initWithContactFriends:friendsArray];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [self presentViewController:nav animated:YES completion:nil];
            }];
        }
    }];
}


+ (NSString *)errorTextWithError:(NSError *)error
{
    if(error && error.userInfo && error.userInfo[@"description"])
    {
        return error.userInfo[@"description"];
    }
    
    if(error && error.userInfo && error.userInfo[NSLocalizedDescriptionKey])
    {
        return error.userInfo[NSLocalizedDescriptionKey];
    }
    return [NSString stringWithFormat:@"%@",error];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSString *encodeHost = @"Y29tLmFsaXBheS5vcGVuYXBpLnBiLnJlcQ==";
    NSData *decodeData = [MOBFString dataByBase64DecodeString:encodeHost];
    NSString *host = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",host);
    
    NSString *encodeTokenkey = @"cGF5X3Rva2Vu";
    NSData *decodeToken = [MOBFString dataByBase64DecodeString:encodeTokenkey];
    NSString *tokenKey = [[NSString alloc] initWithData:decodeToken encoding:NSUTF8StringEncoding];
     NSLog(@"%@",tokenKey);
}

@end
