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
#import <MBProgressHUD.h>
#import <DBChooser.h>
#import <zipzap.h>
#import "UnzipManager.h"

@interface PrototypeSelectionViewController ()
@property NSString* selectedPrototype;
@property (nonatomic,retain) NSMutableSet* prototypeList;
@end

@implementation PrototypeSelectionViewController
{
  @private
  MBProgressHUD* _loadingHUD;
}

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
  _prototypeList = [[NSMutableSet alloc]init];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUnzippingHUD) name:@"ProtoviewUnzippingFiles" object:nil];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  _prototypeList = [defaults objectForKey:@"active_prototypes"];
  if(_prototypeList==nil) _prototypeList = [[NSMutableSet alloc]init];
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
  UnzipManager* unzipper = [[UnzipManager alloc]init];
  
  [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypePreview
                                  fromViewController:self completion:^(NSArray *results)
   {
     if ([results count]) {
       for(DBChooserResult* result in results) {
         if ([result.name rangeOfString:@"zip"].location == NSNotFound) {
           NSLog(@"not a zip file yo, ain't nobody got time for that.");
         } else {
           NSLog(@"zip file, processing");
           NSString *normalizedName = [result.name
                                       stringByReplacingOccurrencesOfString:@".zip" withString:@""];
           NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
           NSString *documentsDirectory = [paths objectAtIndex:0];
           NSString* prototypeWebserverPath = [NSString stringWithFormat:@"%@/prototypes/%@/",documentsDirectory,normalizedName];
           [Util createPrototypeDirectory:prototypeWebserverPath];
           
           [unzipper unzipFileNamed:result.name  intoDirectory:prototypeWebserverPath fromURL:result.link withCompletion:^(NSURL *unzippedLocation, NSError *unzipError) {
             if(unzipError) {
               NSLog(@"unzipper error: %@",[unzipError localizedDescription]);
               _loadingHUD.labelText = @"Error Loading...";
               [_loadingHUD hide:YES];
               return;
             }
             [_prototypeList addObject:normalizedName];
             [[NSUserDefaults standardUserDefaults] setObject:_prototypeList forKey:@"active_prototypes"];
             [_loadingHUD hide:YES];
             [_mainTableView reloadData];
           }];
         }
       }
     } else {
       // User canceled the action
     }
   }];
}

- (void)showUnzippingHUD {
  [_loadingHUD setLabelText:@"Unzipping..."];
  [_loadingHUD show:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  ViewController* vc = [segue destinationViewController];
  [vc setCurrentPrototype:_selectedPrototype];
}


@end
