//
//  threeTap300ViewController.m
//  threeTap300
//
//  Created by Ryan Smale on 7/06/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "threeTap300ViewController.h"

@implementation threeTap300ViewController
@synthesize _addressBook;
@synthesize addressesTableView = _addressesTableView;

- (void)dealloc
{
    [_addressBook release];
    [_addressesTableView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [self loadAddressBook];
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [self setAddressesTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




#pragma mark - table view -
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_addressBookNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //NSLog(@"object at index is %@",[entriesArray objectAtIndex:0]); // debugging helper.
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    NSInteger row = [indexPath row];
    
    [cell.textLabel setText:[_addressBookNames objectAtIndex:row]];
    // example code for populating a subtileStyle
    [cell.detailTextLabel setText:[_addressBookPhones objectAtIndex:row]];
    
    //    NSString *path = @"TableViewPlaceholder.png";
    //    UIImage *theImage = [UIImage imageWithContentsOfFile:path];
    //    cell.imageView.image = theImage;
    
    
    //TODO: create a loop that finds the specific image for each entry. need to add a save field in the core data bit
    UIImage *cellImage = [UIImage imageNamed:@"TableViewPlaceholder.png"];
    cell.imageView.image = cellImage;
    
    return cell;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - trying to load all the contacts __
-(void)loadAddressBook
{
    // remember this function will be called each time you refresh the address book 
    // by pressing the address book button, so make sure you release before alloc again
    if ( _addressBookNames) { [_addressBookNames release]; }
    if ( _addressBookPhones) { [_addressBookPhones release]; }
    
    // Loading Address Book
    ABAddressBookRef _addressBookRef = ABAddressBookCreate();
    NSArray* allPeople = (NSArray *)ABAddressBookCopyArrayOfAllPeople(_addressBookRef);
    _addressBookNames = [[NSMutableArray alloc] initWithCapacity:[allPeople count]]; // aray for name
    _addressBookPhones = [[NSMutableArray alloc] initWithCapacity:[allPeople count]];// array for numbers
    
    // now iterate though all the records and suck out phone numbers
    for (id record in allPeople) {
        CFTypeRef phoneProperty = ABRecordCopyValue((ABRecordRef)record, kABPersonPhoneProperty);
        NSArray *phones = (NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
        CFRelease(phoneProperty);
        for (NSString *phone in phones) {
            NSString* compositeName = (NSString *)ABRecordCopyCompositeName((ABRecordRef)record);
            
            //so, if a name has multiple phone numbers, we create duplicate records
            // of the name and each phone #
            
            [_addressBookNames addObject:compositeName];
            [_addressBookPhones addObject:phone];
            NSLog(@"%@",compositeName);
            [compositeName release];
            
        }
        [phones release];
    }
    CFRelease(_addressBookRef);
    [allPeople release];
    allPeople = nil;
    
}


@end
