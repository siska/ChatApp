//
//  ViewController.h
//  ChatApp
//
//  Created by S on 11/4/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <FacebookSDK/FacebookSDK.h>



@interface RootViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, FBLoginViewDelegate>


@end

