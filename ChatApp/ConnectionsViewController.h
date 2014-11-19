//
//  ConnectionViewController.h
//  ChatApp
//
//  Created by S on 11/10/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ConnectionsViewController : UIViewController <MCBrowserViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textName;
@property (weak, nonatomic) IBOutlet UISwitch *switchToggle;
@property (weak, nonatomic) IBOutlet UIButton *browseDeviceButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UITableView *tableViewConnectedDevices;

- (IBAction)browseDevicePressed:(id)sender;
- (IBAction)switchToggleVisibility:(id)sender;
- (IBAction)disconnectOnButtonPressed:(id)sender;

@end