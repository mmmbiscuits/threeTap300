//
//  threeTap300ViewController.h
//  threeTap300
//
//  Created by Ryan Smale on 7/06/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
@interface threeTap300ViewController : UIViewController {
    NSMutableArray* _addressBookNames;      // holds a list of all the address book names
    NSMutableArray* _addressBookPhones;     // holds a list of all the phone #s (there is a 1:1 between _addressBookPhones and Names)
    UITableView *_addressesTableView;
}

@property(nonatomic, retain)NSMutableArray *_addressBook;
@property (nonatomic, retain) IBOutlet UITableView *addressesTableView;

-(void)loadAddressBook;                     // should be called at the start to load the contact book into an array for faster search

@end
