//
//  Message.h
//  ChatApp
//
//  Created by S on 11/6/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Message : PFObject <PFSubclassing>

@property NSString *message;
@property PFUser *userCurrent;
@property PFUser *userContact;

@end
