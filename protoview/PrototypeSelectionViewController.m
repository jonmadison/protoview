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
@property (nonatomic,retain) NSMutableDictionary* siteList;
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

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  _siteList = [defaults objectForKey:kProtoviewAvailableSites];
  if(_siteList==nil) _siteList = [[NSMutableDictionary alloc]init];
  [_mainTableView reloadData];
}

- (void)viewDidLoad
{  
  [super viewDidLoad];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDownloadingHUD) name:@"ProtoviewDownloadingFiles" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUnzippingHUD) name:@"ProtoviewUnzippingFiles" object:nil];
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
  NSArray* allKeys = [_siteList allKeys];
  
  Site* site = [Site objectFromData:_siteList[allKeys[indexPath.row]]];
  [[cell textLabel] setText:site.friendlyName];
  [[cell imageView] setImage:site.thumbnail];
  NSString* timeAgoString = [(NSDate*)site.createdAt timeAgoSinceNow];
  [cell.detailTextLabel setText:timeAgoString];
  return cell;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray* allKeys = [_siteList allKeys];
  _selectedSite = [Site objectFromData:_siteList[allKeys[indexPath.row]]];
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
           [_loadingHUD setBackgroundColor:[UIColor whiteColor]];
           [_loadingHUD setColor:[UIColor blackColor]];
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
               [_siteList setObject:[site asData] forKey:site.identifier];
               [[NSUserDefaults standardUserDefaults] setObject:_siteList forKey:kProtoviewAvailableSites];
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
    NSArray* allKeys = [_siteList allKeys];

    Site* site = [Site objectFromData:_siteList[allKeys[indexPath.row]]];
    [Util removePrototypeDirectory:site.identifier];
    [_siteList removeObjectForKey:site.identifier];
    [[NSUserDefaults standardUserDefaults] setObject:_siteList forKey:@"active_prototypes"];
    [tableView reloadData]; // tell table to refresh now
  }
}

- (void)showDownloadingHUD {
    [_loadingHUD setLabelText:@"Downloading..."];
}

- (void)showUnzippingHUD {
    [_loadingHUD setLabelText:@"Unzipping..."];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  ViewController* vc = [segue destinationViewController];
  [vc setSelectedSite:_selectedSite];
}


@end
