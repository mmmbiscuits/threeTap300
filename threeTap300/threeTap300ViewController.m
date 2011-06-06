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
@synthesize statusLabel = _statusLabel;

- (void)dealloc
{
    [_addressBook release];
    [_addressesTableView release];
    [_statusLabel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
   _statusLabel.text =  NSLocalizedString(@"select a number to check", @"feed out string to inform the user of the status");
    [self loadAddressBook];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setAddressesTableView:nil];
    [self setStatusLabel:nil];
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
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    NSString * numberSelected = [_addressBookPhones objectAtIndex:indexPath.row]; // get the number
    
    NSLog(@"%@", numberSelected);
    
    MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];// alloc the sms modal controller
	if([MFMessageComposeViewController canSendText])
	{

        controller.body = numberSelected;  // here we define waht gets passed to the message 
        
        NSString *NetworkCheckingNumber = @"300";
		controller.recipients = [NSArray arrayWithObjects:NetworkCheckingNumber, nil]; // set 300 as recipient
		controller.messageComposeDelegate = self;
		[self presentModalViewController:controller animated:YES];
        [NetworkCheckingNumber release]; // dealloc
	}	

}

#pragma mark - load all the contacts __
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
          //  NSLog(@"%@",compositeName);
            [compositeName release];
            
        }
        [phones release];
    }
    CFRelease(_addressBookRef);
    [allPeople release];
    allPeople = nil;
    
}

#pragma mark - sms feedback stuff

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller 
				 didFinishWithResult:(MessageComposeResult)result {
	
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MessageComposeResultCancelled:
			_statusLabel.text =  NSLocalizedString(@"you canceled, push send to check if same provider", @"messge compose was canceled");
			break;
		case MessageComposeResultSent:
_statusLabel.text =  NSLocalizedString(@"Message sent a reply will return on that numbers status", @"message succesfully sent");			break;
		case MessageComposeResultFailed:
			_statusLabel.text =  NSLocalizedString(@"the message failed to send", @"there was an error in the sending of the message");
			break;
		default:
			_statusLabel.text =  NSLocalizedString(@"mesage not sent", @"default message");
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


@end
