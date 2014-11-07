//
//  MessageViewController.m
//  ChatApp
//
//  Created by S on 11/5/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "MessageViewController.h"

@interface MessageViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIView *messageView; //is this necessary?
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)reloadMessageTableView
{
    //will reload the view on message to show all messages
}

#pragma mark UITextField Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.messageTextField.text = @"";
    [self addMessageToParse:textField];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Save To Parse

-(void)addMessageToParse:(UITextField *)textField
{
    Message *message = [Message object];

    message.message = textField.text;
    message.userCurrent = [PFUser currentUser];
    message.userContact = self.selectedUser;
    NSLog(@"message.userContact: %@", message.userContact);

    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error userInfo]);
        }
        else {
            [self reloadMessageTableView];
        }
    }];
}

@end
