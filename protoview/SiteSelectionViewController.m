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

@interface SiteSelectionViewController ()
@property Site* selectedSite;
@property (nonatomic,retain) NSMutableDictionary* siteList;
@end

@implementation SiteSelectionViewController
{
@private
  MBProgressHUD* _loadingHUD;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  _siteList = [[defaults objectForKey:kProtoviewAvailableSites] mutableCopy];
  if(_siteList==nil) _siteList = [[NSMutableDictionary alloc]init];
  [_sitesCollectionView reloadData];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDownloadingHUD) name:@"ProtoviewDownloadingFiles" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUnzippingHUD) name:@"ProtoviewUnzippingFiles" object:nil];
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
               [_siteList setObject:[site asData] forKey:site.identifier];
               [[NSUserDefaults standardUserDefaults] setObject:_siteList forKey:kProtoviewAvailableSites];
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return _siteList.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  
  UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
  UIImageView* imageView = (UIImageView*)[cell viewWithTag:100];
  NSArray* allKeys = [_siteList allKeys];
  
  Site* site = [Site objectFromData:_siteList[allKeys[indexPath.row]]];
  [imageView setImage:site.thumbnail];
  UILabel* labelName = (UILabel*)[cell viewWithTag:200];
  [labelName setText:site.friendlyName];
  UILabel* labelCreated = (UILabel*)[cell viewWithTag:300];
  NSString* timeAgoString = [(NSDate*)site.createdAt timeAgoSinceNow];
  [labelCreated setText:timeAgoString];
  return cell;
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray* allKeys = [_siteList allKeys];
  _selectedSite = [Site objectFromData:_siteList[allKeys[indexPath.row]]];
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

@end
