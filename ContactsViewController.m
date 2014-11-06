//
//  ContactsViewController.m
//  ChatApp
//
//  Created by S on 11/4/14.
//  Copyright (c) 2014 Vi & Ryan. All rights reserved.
//

#import "ContactsViewController.h"
#import <Parse/Parse.h>
#import "MessageViewController.h"

@interface ContactsViewController () <UITableViewDataSource, UITableViewDelegate>

@property NSArray *contacts;
@property NSMutableDictionary *contactsSeparated;
@property NSArray *contactSectionTitles;
@property NSArray *allUsers;
@property PFUser *currentUserWithRelations;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property PFObject *selectedUser;

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
    [self queryForContacts];
}

-(void)queryForContacts
{
    PFRelation *relation = [self.currentUserWithRelations relationForKey:@"contacts"];

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
    NSLog(@"self.contacts: %@", self.contacts);
    NSLog(@"self.contactsSeparated: %@", self.contactsSeparated);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"FullConversationSegue"]) {
        MessageViewController *viewController = [segue destinationViewController];
        viewController.selectedUser = self.selectedUser;
    }
}

#pragma mark TableView DataSource

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *selectedUser = [self.contacts objectAtIndex:indexPath.row];
    self.selectedUser = selectedUser;
    [self performSegueWithIdentifier:@"FullConversationSegue" sender:tableView];
}

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
