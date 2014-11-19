//
//  ChatVC.m
//  ChatApp
//
//  Created by S on 11/11/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "ChatVC.h"


@interface ChatVC ()
@property NSArray *usersInConversation;
@property NSArray *conversationsFromParse;
@property NSMutableArray *messages;
@property JSQMessagesAvatarImage *placeholderImageData;
@property JSQMessagesBubbleImage *outgoingBubbleImageData;
@property JSQMessagesBubbleImage *incomingBubbleImageData;

@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.usersInConversation = [[NSArray alloc] initWithObjects:[PFUser currentUser], self.selectedUser, nil];
    self.messages = [[NSMutableArray alloc] init];

    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];

    self.placeholderImageData = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"blank_avatar"] diameter:30.0];

    self.navigationItem.title = [self.selectedUser objectForKey:@"FirstName"];

    [self queryConversationsMessagesFromParse];
//    [self subscribeToPushChannels];
}

-(void)queryConversationsMessagesFromParse
{
    PFQuery *queryForConversations = [PFQuery queryWithClassName:@"Conversation"];
    [queryForConversations whereKey:@"users" containsAllObjectsInArray:self.usersInConversation];
    //[queryForConversations setLimit:10]; //review where this cuts it off at - most recent or oldest messages - only allows
    [queryForConversations findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error) {
             NSLog(@"Error: %@", error.userInfo);
             self.conversationsFromParse = [NSArray array];
         }
         else
         {
             self.conversationsFromParse = objects;
         }
         //NSLog(@"queryCurrentUserMessagesFromParse returned: %@", self.conversationsFromParse);
         [self createJSQMessagesFromConversations];

        
     }];
}

-(void)createJSQMessagesFromConversations
{
    for (Conversation *conversation in self.conversationsFromParse) {

        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:conversation.senderId senderDisplayName:conversation.senderDisplayName date:conversation.date text:conversation.text];

        [self.messages addObject:message];
    }

    [self.collectionView reloadData];

    if (self.messages.count > 9)
    {
        // delay offset change by a tiny amount, or it doesn't work
        // max added the above comment and set this up so that when the messages are loaded or when they are reloaded, the collection view automatically scrolls to the bottom - he also moved it out of the for loop - we don't want to reload it every time
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            CGFloat y = self.collectionView.contentSize.height;
            y -= self.collectionView.bounds.size.height;
            y += self.collectionView.contentInset.bottom;
            [self.collectionView setContentOffset:CGPointMake(0, y) animated:YES];
        }];
    }
}

/*[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:items - 1 inSection:0]
 atScrollPosition:UICollectionViewScrollPositionTop
 animated:animated];   */

//[self scrollToBottomAnimated:YES];


//[self.collectionView setContentOffset:CGPointMake(0, 300)];

//         [self automaticallyScrollsToMostRecentMessage];


//where is the senderID, name, etc coming from?
-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    Conversation *conversation = [Conversation object];

    conversation.users = [[NSArray alloc] initWithObjects:[PFUser currentUser], self.selectedUser, nil];
    conversation.text = text;
    conversation.senderId = [PFUser currentUser].objectId;
    conversation.senderDisplayName = [[PFUser currentUser] objectForKey:@"FirstName"];
    conversation.receiverID = self.selectedUser;
    conversation.date = date;
    NSLog(@"receiverID: %@", conversation.receiverID);
    NSLog(@" %@ ", self.selectedUser);

    [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (error) {
            NSLog(@"Error: %@", [error userInfo]);
        }
        else {
            self.messages = [NSMutableArray array];
            UITextView *textView = self.inputToolbar.contentView.textView;
            textView.text = nil;
            [textView.undoManager removeAllActions];
            [self queryConversationsMessagesFromParse];
            [self sendPushNotifications];

           
        }
    }];
}


#pragma mark - JSQMessages CollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.item];
    if (![message.senderId isEqualToString:[PFUser currentUser].objectId])
    {
        return self.outgoingBubbleImageData;
    }
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.placeholderImageData;
//    PFUser *user = self.usersInConversation[indexPath.item];
//    if (self.avatars[user.objectId] == nil)
//    {
//        PFFile *fileThumbnail = user[PF_USER_THUMBNAIL];
//        [fileThumbnail getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
//         {
//             if (error == nil)
//             {
//                 avatars[user.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData] diameter:30.0];
//                 [self.collectionView reloadData];
//             }
//         }];
//        return placeholderImageData;
//    }
//    else return avatars[user.objectId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 3 == 0)
    {
        JSQMessage *message = self.messages[indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.item];
    if ([message.senderId isEqualToString:[PFUser currentUser].objectId])
    {
        return nil;
    }

    if (indexPath.item - 1 > 0)
    {
        JSQMessage *previousMessage = self.messages[indexPath.item-1];
        if ([previousMessage.senderId isEqualToString:message.senderId])
        {
            return nil;
        }
    }
    return nil; //[[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    JSQMessage *message = self.messages[indexPath.item];
    if (![message.senderId isEqualToString:[PFUser currentUser].objectId])
    {
        cell.textView.textColor = [UIColor blackColor];
    }
    else
    {
        cell.textView.textColor = [UIColor whiteColor];
    }

    return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate



- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 3 == 0)
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.item];
    if ([message.senderId isEqualToString:[PFUser currentUser].objectId])  //self.senderId])
    {
        return 0.0f;
    }

    if (indexPath.item - 1 > 0)
    {
        JSQMessage *previousMessage = self.messages[indexPath.item-1];
        if ([previousMessage.senderId isEqualToString:[PFUser currentUser].objectId])
        {
            return 0.0f;
        }
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"didTapLoadEarlierMessagesButton");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didTapAvatarImageView");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didTapMessageBubbleAtIndexPath");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"didTapCellAtIndexPath %@", NSStringFromCGPoint(touchLocation));
}

//-(void)subscribeToPushChannels{
////
// //   PFQuery *pushQuery = [PFInstallation query];
////    [pushQuery whereKey:@"channels" equalTo:[PFUser user]]; // Set channel
////    [pushQuery whereKey:@"scores" equalTo:YES];
//
////    PFQuery *userQuery  = [PFUser query];
//    PFQuery *recieverOfMessage = [PFQuery queryWithClassName:@"Conversation"];
//    [recieverOfMessage whereKey:@"recieverID" equalTo:[PFUser currentUser]];
//    [recieverOfMessage orderByDescending:@"createdAt"];
//
//
//    [recieverOfMessage findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//     {
//         if (error) {
//             NSLog(@"Error: %@", error.userInfo);
//         }
//         else
//         {
//           //  Conversation *messagePush = [objects objectAtIndex:0];
//            // NSLog(@"hiiii %@", messagePush);
//             NSString *channelName = [NSString stringWithFormat:@"%@", recieverOfMessage];
//             PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//             [currentInstallation addUniqueObject:channelName forKey:@"channels"];
//             [currentInstallation saveInBackground];
//
//         }
//
//     }];
//}
-(void) sendPushNotifications{
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"channels" equalTo:[PFUser user]];

    PFQuery *recieverOfMessage = [PFQuery queryWithClassName:@"Conversation"];
        [recieverOfMessage whereKey:@"receiverID" equalTo:[PFUser currentUser]];
    
    
        [recieverOfMessage findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error) {
                 NSLog(@"Error: %@", error.userInfo);


             }
             else
             {

                 Conversation *conversationJustSent = [objects objectAtIndex:0];
                 NSString *channelName = conversationJustSent.objectId;
                 PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                 [currentInstallation addUniqueObject:channelName forKey:@"channels"];
                 [currentInstallation saveInBackground];


                 PFPush *push = [[PFPush alloc] init];
                 [push setChannel:@"channel"];
                 NSString *friendName = conversationJustSent.senderDisplayName;
                 NSString *messageString = [NSString stringWithFormat:@"You have a message from %@!", friendName];

                 [push setMessage:messageString];
                 [push sendPushInBackground];


    
             }
    
         }];



}

@end