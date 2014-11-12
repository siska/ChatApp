//
//  Conversation.h
//  ChatApp
//
//  Created by S on 11/12/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JSQMessage.h"

@interface Conversation : PFObject <PFSubclassing>

@property PFUser *userOne;
@property PFUser *userTwo;
@property JSQMessage *message;

@end
