//
//  ContactsViewController.m
//  ChatApp
//
//  Created by S on 11/4/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "ContactsViewController.h"
#import <Parse/Parse.h>

@interface ContactsViewController () <UITableViewDataSource, UITableViewDelegate>

@property NSArray *contacts;
@property NSMutableDictionary *contactsSeparated;
@property NSArray *contactSectionTitles;
@property NSArray *allUsers;

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contacts = [[NSArray alloc] init];
    self.contactsSeparated = [[NSMutableDictionary alloc] init];

    [self queryAllUsersFromParse];
    [self queryForContacts];
}

-(void)queryAllUsersFromParse
{
    PFQuery *queryForUsers = [PFQuery queryWithClassName:@"_User"];
    [queryForUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.userInfo);
            self.allUsers = [NSArray array];
        }
        else
        {
            self.allUsers = objects;
            [self saveAllContactsForUserToParse];
        }
    }];
}

-(void)saveAllContactsForUserToParse
{
    PFRelation *relationship = [[PFUser currentUser] relationForKey:@"contacts"];

    for (PFObject *contact in self.allUsers)
        [relationship addObject:contact];

    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error userInfo]);
        }
    }];
}

-(void)queryForContacts
{
    PFQuery *queryForContacts = [PFQuery queryWithClassName:@"FacebookFriend"];
    [queryForContacts whereKey:@"friendOf" equalTo:[PFUser currentUser]];
    [queryForContacts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.userInfo);
            self.contacts = [NSArray array];
        }
        else
        {
            self.contacts = objects; //[objects sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]; //I think I'll need to make it reference the name specifically?
  //          [self createDictionaryWithKeys];
  //          [self createArraysForDictionaryKeys];
        }
    }];
}
/*
-(void)createDictionaryWithKeys
{
    for (FacebookFriend *contact in self.contacts)
    {
        NSString *firstLetter = [contact.name substringToIndex:0];
        firstLetter =[firstLetter uppercaseString];

        NSMutableArray *emptyArray = [[NSMutableArray alloc] init];

        if ([self.contactsSeparated objectForKey:firstLetter] == nil)
        {
            [self.contactsSeparated setObject:emptyArray forKey:firstLetter];
        }
    }
    self.contactSectionTitles = [[self.contactsSeparated allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]; //this should order the keys for us
}

-(void)createArraysForDictionaryKeys
{
    for (FacebookFriend *contact in self.contacts)
    {
        NSString *firstLetter = [contact.name substringToIndex:0];
        firstLetter =[firstLetter uppercaseString];

        NSMutableArray *tempArrayForKeys = [NSMutableArray array];
        tempArrayForKeys = [self.contactsSeparated objectForKey:firstLetter];
        [tempArrayForKeys addObject:contact];

        [self.contactsSeparated setObject:tempArrayForKeys forKey:firstLetter];
    }
}

#pragma mark TableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.contactSectionTitles.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.contactSectionTitles objectAtIndex:section];
}
*/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    NSString *sectionTitle = [self.contactSectionTitles objectAtIndex:section];
//    NSArray *sectionContacts = [self.contactsSeparated objectForKey:sectionTitle];
//    return [sectionContacts count];

    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];

    // Configure the cell...
//    NSString *sectionTitle = [self.contactSectionTitles objectAtIndex:indexPath.section];
//    NSArray *sectionContacts = [self.contactsSeparated objectForKey:sectionTitle];
//    FacebookFriend *contact = [sectionContacts objectAtIndex:indexPath.row];
//    cell.textLabel.text = contact.name;

    return cell;
}













@end
