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
#import <DateTools.h>
#import "Site.h"
#import "UnzipManager.h"

@interface PrototypeSelectionViewController ()
@property Site* selectedSite;
@property (nonatomic,retain) NSMutableArray* siteList;
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
  _siteList = [[NSMutableArray alloc]init];
 
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDownloadingHUD) name:@"ProtoviewDownloadingFiles" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUnzippingHUD) name:@"ProtoviewUnzippingFiles" object:nil];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  _siteList = [defaults objectForKey:@"available_sites"];
  if(_siteList==nil) _siteList = [[NSMutableArray alloc]init];
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
  return _siteList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
  Site* site = [Site objectFromData:_siteList[indexPath.row]];
  [[cell textLabel] setText:site.friendlyName];
  NSString* timeAgoString = [(NSDate*)site.createdAt timeAgoSinceNow];
  [cell.detailTextLabel setText:timeAgoString];
  return cell;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  _selectedSite = [Site objectFromData:_siteList[indexPath.row]];
  return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  //Change the selected background view of the cell.
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction) didPressAddNewPrototype {
  UnzipManager* unzipper = [[UnzipManager alloc]init];
  
  [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect
                                  fromViewController:self completion:^(NSArray *results)
   {
     if ([results count]) {
       for(DBChooserResult* result in results) {
         if ([result.name rangeOfString:@"zip"].location == NSNotFound) {
           NSLog(@"not a zip file yo, ain't nobody got time for that.");
           dispatch_async(dispatch_get_main_queue(), ^{
             _loadingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
             [_loadingHUD setLabelText:@"Invalid File Type"];
             [_loadingHUD hide:YES];
           });
           return;
         } else {
           NSLog(@"zip file, processing");
           NSString *normalizedName = [result.name
                                       stringByReplacingOccurrencesOfString:@".zip" withString:@""];
           NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
           NSString *documentsDirectory = [paths objectAtIndex:0];
           _loadingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
           [_loadingHUD setLabelText:@"Fetching Zip File"];
           dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
             Site* site = [[Site alloc]init];
             NSString* prototypeWebserverPath = [NSString stringWithFormat:@"%@/prototypes/%@/",documentsDirectory,site.identifier];
             [Util createPrototypeDirectory:prototypeWebserverPath];
             
             [unzipper downloadAndUnzipFileNamed:result.name  intoDirectory:prototypeWebserverPath fromURL:result.link withCompletion:^(NSURL *unzippedLocation, NSError *unzipError) {
               if(unzipError) {
                 NSLog(@"unzipper error: %@",[unzipError localizedDescription]);
                 _loadingHUD.labelText = @"Error Loading...";
                 [_loadingHUD hide:YES];
                 return;
               }
               NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
               site.friendlyName = normalizedName;
               site.createdAt = date;
               
               [_siteList addObject:[site asData]];
               [[NSUserDefaults standardUserDefaults] setObject:_siteList forKey:@"available_sites"];
               [_loadingHUD hide:YES];
               [_mainTableView reloadData];
             }];
           });
           
         }
       }
     } else {
       // User canceled the action
     }
   }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    Site* site = [Site objectFromData:_siteList[indexPath.row]];
    [Util removePrototypeDirectory:site.friendlyName];
    [_siteList removeObject:site];
    [[NSUserDefaults standardUserDefaults] setObject:_siteList forKey:@"active_prototypes"];
    [tableView reloadData]; // tell table to refresh now
  }
}

- (void)showDownloadingHUD {
  dispatch_async(dispatch_get_main_queue(), ^{
    [_loadingHUD hide:YES];
    [_loadingHUD setLabelText:@"Downloading..."];
    [_loadingHUD show:YES];
  });
}

- (void)showUnzippingHUD {
  dispatch_async(dispatch_get_main_queue(), ^{
    [_loadingHUD hide:YES];
    [_loadingHUD setLabelText:@"Unzipping..."];
    [_loadingHUD show:YES];
  });
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  ViewController* vc = [segue destinationViewController];
  [vc setUrl:_selectedSite.identifier];
}


@end
