//
//  Contact.h
//  ChatApp
//
//  Created by S on 11/5/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@interface Friend : PFObject <PFSubclassing>
@property NSString *name;
@property NSString *fbID;
@property NSString *lastName;
@property NSString *firstName;
@property NSString *email;
@property PFUser *friendOf;

@end
