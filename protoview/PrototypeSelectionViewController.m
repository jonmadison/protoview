//
//  PrototypeSelectionViewController.m
//  protoview
//
//  Created by Madison, Jon on 8/14/14.
//  Copyright (c) 2014 nordlab. All rights reserved.
//

#import "PrototypeSelectionViewController.h"
#import "ViewController.h"
#import "Util.h"

@interface PrototypeSelectionViewController ()
@property NSString* selectedPrototype;
@property (nonatomic,retain) NSMutableArray* prototypeList;
@end

@implementation PrototypeSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  _prototypeList = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  return _prototypeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
  NSString* prototypeName = (NSString*)[_prototypeList objectAtIndex:indexPath.row];
  [[cell textLabel] setText:prototypeName];
  return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Return NO if you do not want the specified item to be editable.
  return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  _selectedPrototype = _prototypeList[indexPath.row];
  return indexPath;
  
}

- (IBAction) didPressAddNewPrototype {
  if (![[DBSession sharedSession] isLinked]) {
    [[DBSession sharedSession] linkFromController:self];
  } else {
    [self showDropboxFilePicker];
  }
}

- (void)showDropboxFilePicker {
  
}

- (void)copyPrototypesFrom:(NSString*)path toPrototypesPath:(NSString*)prototypesPath {
  [Util createDirectory:prototypesPath];
  
  for(NSString* path in _prototypeList) {
    [Util copyPrototypeHTMLFromPath:path toPath:prototypesPath];
  }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  ViewController* vc = [segue destinationViewController];
  [vc setCurrentPrototype:_selectedPrototype];
}


@end
