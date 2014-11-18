//
//  MultipeerChatViewController.h
//  ChatApp
//
//  Created by Vi on 11/17/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import "JSQMessagesBubbleImage.h"
#import "JSQMessagesBubbleImageFactory.h"
#import "JSQMessageData.h"
#import "UIColor+JSQMessages.h"
#import "JSQMessagesTimestampFormatter.h"
#import "JSQMessagesAvatarImage.h"
#import "JSQMessagesAvatarImageFactory.h"
#import <Parse/Parse.h>
#import "Conversation.h"

@interface MultipeerChatViewController : JSQMessagesViewController <JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewDelegateFlowLayout>



@end
