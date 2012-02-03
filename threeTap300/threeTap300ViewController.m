//
//  threeTap300ViewController.m
//  threeTap300
//
//  Created by Ryan Smale on 7/06/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "threeTap300ViewController.h"
#import "YRDropdownView.h"

@implementation threeTap300ViewController
@synthesize _addressBook;
@synthesize addressesTableView = _addressesTableView;
@synthesize statusLabel = _statusLabel;

- (void)dealloc
{
    [_addressBook release];
    [_addressesTableView release];
    [_statusLabel release];
    [abNamesArray release];
    [abNumbersArray release];
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
    NSInteger counter = [abNamesArray count];
    if (counter == 0){
     // add a warning no entries??
        _statusLabel.text = NSLocalizedString(@"No entries in the address book were found", @"no entries in address book error");
    }
    
  // self.view.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:1];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.95];
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
    return [abNamesArray count];
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
    
    [cell.textLabel setText:[abNamesArray objectAtIndex:row]];
    // example code for populating a subtileStyle
    [cell.detailTextLabel setText:[abNumbersArray objectAtIndex:row]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    NSString * numberSelected = [abNumbersArray objectAtIndex:indexPath.row]; // get the number
    
    MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];// alloc the sms modal controller
	if([MFMessageComposeViewController canSendText])
	{
        controller.body = numberSelected;  // here we define waht gets passed to the message 
        
        NSString *NetworkCheckingNumber = @"300"; // this is the free txt number in nz to check if a number is on your network
		controller.recipients = [NSArray arrayWithObjects:NetworkCheckingNumber, nil]; // set 300 as recipient
		controller.messageComposeDelegate = self;
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

		[self presentModalViewController:controller animated:YES];
        [NetworkCheckingNumber release]; // dealloc
	}	
}

#pragma mark - load all the contacts __
-(void)loadAddressBook 
{
    
// Loading  all the entries from the Address Book into an array
    ABAddressBookRef _addressBookRef = ABAddressBookCreate();
    
    ABRecordRef source = ABAddressBookCopyDefaultSource(_addressBookRef);
   NSArray* AdressBookEntriesDump = (NSArray*)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(_addressBookRef, source, kABPersonSortByFirstName); // gets entries and sorts by first name
    
    abNamesArray = [[NSMutableArray alloc] initWithCapacity:   [AdressBookEntriesDump count]];      // init array for names
    abNumbersArray = [[NSMutableArray alloc] initWithCapacity: [AdressBookEntriesDump count]];    // init array for numbers
// now iterate though all the records and get the numbers
    for (id record in AdressBookEntriesDump) {
        CFTypeRef phoneProperty = ABRecordCopyValue((ABRecordRef)record, kABPersonPhoneProperty);
        NSArray *phoneNumbers = (NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
        CFRelease(phoneProperty);
        for (NSString *phone in phoneNumbers) {
            NSString* compositeName = (NSString *)ABRecordCopyCompositeName((ABRecordRef)record);
            
            //so, if a name has multiple phone numbers, we create duplicate records
            // of the name and co-responding phone number 
            [abNamesArray addObject:compositeName];
            [abNumbersArray addObject:phone];
            //  NSLog(@"%@",compositeName); // for debug
            [compositeName release];
        }
        [phoneNumbers release];
    }
    CFRelease(_addressBookRef);
    CFRelease(source);
    
    AdressBookEntriesDump = nil;
    [AdressBookEntriesDump release];
}

#pragma mark - sms feedback stuff

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller 
				 didFinishWithResult:(MessageComposeResult)result {
	// Notifies users about errors and general statuses associated with the app
	switch (result)
	{
		case MessageComposeResultCancelled:
            
            [YRDropdownView showDropdownInView:self.view title:@"entry cancelled" detail:@"you canceled"  image:nil animated:YES hideAfter:5 setBackground:@"yellow"];
		/*	_statusLabel.text =  NSLocalizedString(@"You Canceled", @"messge compose was canceled");
            self.view.backgroundColor = [UIColor orangeColor];
            [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(setBackgroundBlack) userInfo:nil repeats:NO];
            
            double cancelDelayInSeconds = 2.0; // time we want to delay in seconds
            dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, cancelDelayInSeconds * NSEC_PER_SEC); // sets the time
            dispatch_after(popTime2, dispatch_get_global_queue(0, 0), ^(void){  //does it overkill for this but good learning
                self.statusLabel.text = @"select then push send";
            });  
            */
			break;
            
		case MessageComposeResultSent:
            
            [YRDropdownView showDropdownInView:self.view title:@"Sent" detail:@"the result will return as a free sms in your messages" image:nil animated:YES hideAfter:5 setBackground:@"green"];

            break;
            
		case MessageComposeResultFailed:
			[YRDropdownView showDropdownInView:self.view title:@"Sending failed" detail:@"your phone was unable to send a message, check reception or try again later" image:nil animated:YES hideAfter:5 setBackground:@"red"];	
            
            break;
		default:
			_statusLabel.text =  NSLocalizedString(@"mesage not sent", @"default message");
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

-(void) setBackgroundBlack{
    self.view.backgroundColor = [UIColor blackColor]; 
}


@end
