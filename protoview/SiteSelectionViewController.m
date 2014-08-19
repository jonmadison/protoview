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
