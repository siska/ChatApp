//
//  MultipeerChatViewController.m
//  ChatApp
//
//  Created by Vi on 11/17/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "MultipeerChatViewController.h"
#import "AppDelegate.h"

@interface MultipeerChatViewController ()

@property NSArray *usersInConversation;
@property NSArray *chatConvo;
@property NSMutableArray *messages;
@property NSString *message;
@property NSDate *date;
@property NSString *peerDisplayName;
@property JSQMessagesAvatarImage *placeholderImageData;
@property JSQMessagesBubbleImage *outgoingBubbleImageData;
@property JSQMessagesBubbleImage *incomingBubbleImageData;

@property AppDelegate *appDelegate;


@end


@implementation MultipeerChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.usersInConversation = self.appDelegate.mcManager.session.connectedPeers;
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    self.placeholderImageData = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"blank_avatar"] diameter:30.0];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createJSQMessagesFromConversations:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];


}

-(void)viewDidAppear:(BOOL)animated{
    self.view.backgroundColor = [UIColor purpleColor];
}



- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID};

    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification" object:nil userInfo:dict];
}




-(void)createJSQMessagesFromConversations:(NSNotification *)notification
{

        MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
        self.peerDisplayName = peerID.displayName;

        NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
        NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];


        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.peerDisplayName senderDisplayName:self.peerDisplayName date:[NSDate date] text:receivedText];

        [self.messages addObject:message];
        [self.collectionView reloadData];
        

}


-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text
{

    self.messages = [NSMutableArray array];
    UITextView *textView = self.inputToolbar.contentView.textView;
    NSData *dataSend = [textView.text dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *allConnected = self.appDelegate.mcManager.session.connectedPeers;

    textView.text = nil;
    [textView.undoManager removeAllActions];
    NSError *error;
    [self.appDelegate.mcManager.session sendData:dataSend toPeers:allConnected withMode:MCSessionSendDataReliable error:&error];
    if (error) {
        NSLog(@"OH NO! %@", [error localizedDescription]);
    }

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
    if (![message.senderId isEqualToString:self.peerDisplayName])
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
    if ([message.senderId isEqualToString:self.peerDisplayName])
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
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
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
    if (![message.senderId isEqualToString:self.peerDisplayName])
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
    if ([message.senderId isEqualToString:self.peerDisplayName])  //self.senderId])
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



@end
