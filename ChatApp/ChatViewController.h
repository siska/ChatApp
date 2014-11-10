//
//  ChatViewController.h
//  ChatApp
//
//  Created by S on 11/10/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *chatTextField;

@property (weak, nonatomic) IBOutlet UITextView *chatWindowTextView;

@end