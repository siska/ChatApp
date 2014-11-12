//
//  ChatVC.m
//  ChatApp
//
//  Created by S on 11/11/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "ChatVC.h"

@interface ChatVC ()

@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];


}

//where is the senderID, name, etc coming from?
-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    Conversation *conversation = [Conversation object];

    conversation.users = [[NSArray alloc] initWithObjects:[PFUser currentUser], self.selectedUser, nil];
    conversation.message = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:date text:text];

    [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (error) {
            NSLog(@"Error: %@", [error userInfo]);
        }
        else {
            [self queryCurrentUserMessagesFromParse];
        }
    }];
}

-(void)queryCurrentUserMessagesFromParse
{

}

@end