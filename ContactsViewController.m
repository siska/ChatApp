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
@property PFUser *currentUserWithRelations;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contacts = [[NSArray alloc] init];
    self.contactsSeparated = [[NSMutableDictionary alloc] init];

    [self queryAllUsersFromParse];
}

-(void)queryAllUsersFromParse
{
    PFQuery *queryForUsers = [PFQuery queryWithClassName:@"_User"];
    [queryForUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (error) {
            NSLog(@"Error: %@", error.userInfo);
            self.allUsers = [NSArray array];
        }
        else
        {
            self.allUsers = objects;
            NSLog(@"1. Should see all users: %@", self.allUsers);
        }
        [self saveAllContactsForUserToParse];
    }];
}

-(void)saveAllContactsForUserToParse
{
    PFRelation *relationship = [[PFUser currentUser] relationForKey:@"contacts"];

    for (PFObject *contact in self.allUsers)
    {
        [relationship addObject:contact];
    }

    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (error)
        {
            NSLog(@"Error: %@", [error userInfo]);
        }
    }];
    self.currentUserWithRelations = [PFUser currentUser];
    NSLog(@"2. should see the current user with the relationship information: %@", self.currentUserWithRelations);
    [self queryForContacts];
}

-(void)queryForContacts
{   NSLog(@"queryForContacts called");
    PFRelation *relation = [self.currentUserWithRelations relationForKey:@"contacts"];
    NSLog(@"3.1 see what the PFRelation returns: %@", relation);

    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) // results contains all current users relations
    {
        if (error)
        {
            NSLog(@"Error in queryForContacts: %@", error.userInfo);
        }
        else
        {
            self.contacts = results; //[objects sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]; //say name specfcly?
            NSLog(@"3.2 Should see all the contacts for the current user: %@", self.contacts);
        }
        [self createDictionaryWithKeys];
    }];
}

-(void)createDictionaryWithKeys //creates the keys in a dictionary with empty arrays - those will be set later
{
    for (PFUser *contact in self.contacts)
    {
        NSString *firstLetter = [contact.username substringToIndex:0];
        firstLetter =[firstLetter uppercaseString];

        NSMutableArray *emptyArray = [[NSMutableArray alloc] init];

        if ([self.contactsSeparated objectForKey:firstLetter] == nil)
        {
            [self.contactsSeparated setObject:emptyArray forKey:firstLetter];
        }
    }
    self.contactSectionTitles = [[self.contactsSeparated allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]; //this should order the keys for us
    [self createArraysForDictionaryKeys];
}

-(void)createArraysForDictionaryKeys
{
    for (PFUser *contact in self.contacts)
    {
        NSString *firstLetter = [contact.username substringToIndex:0];
        firstLetter =[firstLetter uppercaseString];

        NSMutableArray *tempArrayForKeys = [NSMutableArray array];
        tempArrayForKeys = [self.contactsSeparated objectForKey:firstLetter];
        [tempArrayForKeys addObject:contact];

        [self.contactsSeparated setObject:tempArrayForKeys forKey:firstLetter];
    }
    [self.tableView reloadData];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *sectionTitle = [self.contactSectionTitles objectAtIndex:section];
    NSArray *sectionContacts = [self.contactsSeparated objectForKey:sectionTitle];
    return [sectionContacts count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];

    // Configure the cell...
    NSString *sectionTitle = [self.contactSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionContacts = [self.contactsSeparated objectForKey:sectionTitle];
    PFUser *contact = [sectionContacts objectAtIndex:indexPath.row];
    cell.textLabel.text = contact.username;

    return cell;
}













@end
