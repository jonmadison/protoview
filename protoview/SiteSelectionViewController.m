//
//  SiteSelectionViewController.m
//  protoview
//
//  Created by Madison, Jon on 8/18/14.
//  Copyright (c) 2014 nordlab. All rights reserved.
//

#import "SiteSelectionViewController.h"
#import "Site.h"
#import "ViewController.h"
#import "UnzipManager.h"
#import "Util.h"
#import <DBChooser.h>
#import <MBProgressHUD.h>
#import <DateTools.h>
#import <UIAlertView+Blocks.h>
#import <RIButtonItem.h>

@interface SiteSelectionViewController ()
@property Site* selectedSite;
@property (nonatomic,retain) NSMutableDictionary* siteList;
@end

@implementation SiteSelectionViewController
{
@private
  MBProgressHUD* _loadingHUD;
  NSInteger timesCalled;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  _siteList = [Util savedSiteListAsObjectDictionary];
  if(_siteList==nil) _siteList = [[NSMutableDictionary alloc]init];
  [_sitesCollectionView reloadData];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  timesCalled = 0;
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDownloadingHUD) name:@"ProtoviewDownloadingFiles" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUnzippingHUD) name:@"ProtoviewUnzippingFiles" object:nil];
}

#pragma mark Editable Mode
- (void)setEditableModeYes:(UILongPressGestureRecognizer*)sender
{
  if (sender.state == UIGestureRecognizerStateBegan){
    [self setEditableMode:YES];
  }
}

- (void)setEditableMode:(BOOL)editable
{
  if(editable) {
    [_buttonItemEditSites setTitle:@"Cancel"];
  } else {
    [_buttonItemEditSites setTitle:@"Edit"];
  }
  
  for(id key in [_siteList allKeys]) {
    Site* site = _siteList[key];
    site.isDeletable = editable;
    [_siteList setObject:site forKey:site.identifier];
  }
  [_sitesCollectionView reloadItemsAtIndexPaths:_sitesCollectionView.indexPathsForVisibleItems];
}

#pragma mark IBActions
- (IBAction) didPressAddNewPrototype {
  [self handleAddNewPrototype];
}

- (IBAction) editOrCancelButtonPressed:(id)sender {
  if([_buttonItemEditSites.title isEqualToString:@"Edit"]){
    [self setEditableMode:YES];
  } else {
    [self setEditableMode:NO];
  }
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return _siteList.count;
}

#pragma mark UICollectionViewDelegate
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
  [self configureCell:cell atIndexpath:indexPath];
  return cell;
}

- (void)configureCell:(UICollectionViewCell*)cell atIndexpath:(NSIndexPath*)indexPath
{
  UIImageView* imageView = (UIImageView*)[cell viewWithTag:100];
  [imageView.layer setShadowColor:[UIColor blackColor].CGColor];
  [imageView.layer setShadowOpacity:0.3];
  [imageView.layer setShadowRadius:2.0];
  [imageView.layer setShadowOffset:CGSizeMake(1.0, 1.0)];

  UIImageView* deleteImageView = (UIImageView*)[cell viewWithTag:400];

  NSArray* allKeys = [_siteList allKeys];
  
  Site* site = _siteList[allKeys[indexPath.row]];
  [imageView setImage:site.thumbnail];
  UILabel* labelName = (UILabel*)[cell viewWithTag:200];
  [labelName setText:site.friendlyName];
  UILabel* labelCreated = (UILabel*)[cell viewWithTag:300];
  NSString* timeAgoString = [(NSDate*)site.createdAt timeAgoSinceNow];
  [labelCreated setText:timeAgoString];

  UILongPressGestureRecognizer* recognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(setEditableModeYes:)];
  [recognizer setMinimumPressDuration:1];
  [cell addGestureRecognizer:recognizer];

  
  if(site.isDeletable) {
    [recognizer setEnabled:NO];
    [deleteImageView setAlpha:0.9f];
    [self wiggleCell:cell];
  } else {
    UIImageView* deleteImageView = (UIImageView*)[cell viewWithTag:400];
    [deleteImageView setAlpha:0.0f];
    [recognizer setEnabled:YES];
  }
}



- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray* allKeys = [_siteList allKeys];
  _selectedSite = _siteList[allKeys[indexPath.row]];
  if(_selectedSite.isDeletable) {
    NSLog(@"confirm delete of site id %@",_selectedSite.identifier);
    
    NSString* title = [NSString stringWithFormat:@"Delete \"%@\"",_selectedSite.friendlyName];
    NSString* message = [NSString stringWithFormat:@"Deleting %@ will remove all of its data.",_selectedSite.friendlyName];
    
    RIButtonItem* deleteItem = [RIButtonItem itemWithLabel:@"Delete" action:^{
      [Util removePrototypeDirectory:_selectedSite.identifier];
      [_siteList removeObjectForKey:_selectedSite.identifier];
      [Util saveSiteListToDefaults:_siteList];
      [_sitesCollectionView deleteItemsAtIndexPaths:@[indexPath]];
    }];
    
    RIButtonItem* cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                               cancelButtonItem:cancelItem
                                               otherButtonItems:deleteItem, nil];
    [alertView show];
    return NO;
  }

  return YES;
}

- (void)showDownloadingHUD {
  [_loadingHUD setLabelText:@"Downloading..."];
}

- (void)showUnzippingHUD {
  [_loadingHUD setLabelText:@"Unzipping..."];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  ViewController* vc = [segue destinationViewController];
  [vc setSelectedSite:_selectedSite];
}

#pragma mark utilities
-(void)wiggleCell:(UICollectionViewCell*)cell
{
  [UIView beginAnimations:@"wiggle" context:nil];
  [UIView setAnimationDuration:0.15];
  [UIView setAnimationRepeatAutoreverses:YES];
  [UIView setAnimationRepeatCount:FLT_MAX];
  
  //wiggle 1 degree both sides
  cell.transform = CGAffineTransformMakeRotation(0.05);
  cell.transform = CGAffineTransformMakeRotation(-0.05);

  [UIView commitAnimations];
}


- (void)handleAddNewPrototype
{
  UnzipManager* unzipper = [[UnzipManager alloc]init];
  
  [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect
                                  fromViewController:self completion:^(NSArray *results)
   {
     if ([results count]) {
       for(DBChooserResult* result in results) {
         if ([result.name rangeOfString:@"zip"].location == NSNotFound) {
           NSLog(@"not a zip file yo, ain't nobody got time for that.");
           dispatch_async(dispatch_get_main_queue(), ^{
             UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid file type. I work with zip files." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
             [alert show];
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
               [_siteList setObject:site forKey:site.identifier];
               [Util saveSiteListToDefaults:_siteList];
               [_loadingHUD hide:YES];
               [_sitesCollectionView reloadData];
             }];
           });
           
         }
       }
     } else {
       // User canceled the action
     }
   }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
