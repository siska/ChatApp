//
//  ConnectionViewController.m
//  ChatApp
//
//  Created by S on 11/10/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "ConnectionsViewController.h"
#import "AppDelegate.h"

@interface ConnectionsViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textName;
@property (weak, nonatomic) IBOutlet UISwitch *switchToggle;
@property (weak, nonatomic) IBOutlet UIButton *browseDeviceButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;

@property (weak, nonatomic) IBOutlet UITableView *tableViewConnectedDevices;


@property NSMutableArray *connectedDevicesArray;
@property (nonatomic, strong) AppDelegate *appDelegate;

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification;

@end

@implementation ConnectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.connectedDevicesArray = [[NSMutableArray alloc]init];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [[self.appDelegate mcManager]setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    [[self.appDelegate mcManager]advertiseSelf:self.switchToggle.isOn];

    self.textName.delegate = self;
    [self.tableViewConnectedDevices setDelegate:self];
    [self.tableViewConnectedDevices setDataSource:self];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerDidChangeStateWithNotification:)name:@"MCDidChangeStateNotification" object:nil];
}


#
- (IBAction)browseDevicePressed:(id)sender {
    [[self.appDelegate mcManager]setupMCBrowser];
    [[[self.appDelegate mcManager]browser]setDelegate:self];
    [self presentViewController:[[self.appDelegate mcManager]browser]animated:YES completion:nil];

}
- (IBAction)switchToggleVisibility:(id)sender {
    [self.appDelegate.mcManager advertiseSelf:self.switchToggle.isOn];
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [self.textName resignFirstResponder];
    self.appDelegate.mcManager.peerID = nil;
    self.appDelegate.mcManager.session = nil;
    self.appDelegate.mcManager.browser = nil;
    if ([self.switchToggle isOn]) {
        [self.appDelegate.mcManager.advertiser stop];
    }

    self.appDelegate.mcManager.advertiser = nil;


    [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:self.textName.text];
    [self.appDelegate.mcManager setupMCBrowser];
    [self.appDelegate.mcManager advertiseSelf:self.switchToggle.isOn];

    return YES;
}

#pragma browser finished and canceled
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [self.appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];

}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [self.appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}

#pragma tableView load
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }

    cell.textLabel.text = [self.connectedDevicesArray objectAtIndex:indexPath.row];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.connectedDevicesArray.count;
    // return [self.arrConnectedDevices count];
}

#pragma connecting to other devices

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    if (state != MCSessionStateConnected) {
        [self.connectedDevicesArray addObject:peerDisplayName];
    }else if(state == MCSessionStateNotConnected){
        if (self.connectedDevicesArray > 0) {
            NSUInteger indexOfDevices = [self.connectedDevicesArray indexOfObject:peerDisplayName];
            [self.connectedDevicesArray removeObjectAtIndex:indexOfDevices];
        }

    }
    if (state != MCSessionStateConnecting) {

        [self.tableViewConnectedDevices reloadData];

        BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] == 0);
        [self.disconnectButton setEnabled:!peersExist];
        [self.textName setEnabled:peersExist];
    }
}

#pragma disconnect device
- (IBAction)disconnectOnButtonPressed:(id)sender {
    [self.appDelegate.mcManager.session disconnect];
    self.textName.enabled = YES;
    [self.connectedDevicesArray removeAllObjects];
    [self.tableViewConnectedDevices reloadData];
}

@end