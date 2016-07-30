//
//  CheckinViewController.m
//  CCIP
//
//  Created by Sars on 7/17/16.
//  Copyright © 2016 CPRTeam. All rights reserved.
//
#define TAG 99

#import <Google/Analytics.h>
#import "GatewayWebService/GatewayWebService.h"
#import "AppDelegate.h"
#import "CheckinViewController.h"
#import "CheckinViewCell.h"
#import "GuideViewController.h"

@interface CheckinViewController()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSArray *scenarios;
@property (strong, nonatomic) GuideViewController *guideViewController;

@end

@implementation CheckinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.appDelegate setCheckinView:self];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"CheckinViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reloadCard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.guideViewController != nil) {
        [self.guideViewController dismissViewControllerAnimated:YES
                                                     completion:^{
                                                         self.guideViewController = nil;
                                                     }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destination = segue.destinationViewController;
    if ([destination isMemberOfClass:[GuideViewController class]]) {
        self.guideViewController = (GuideViewController *)destination;
    }
}

- (void)reloadCard {
    BOOL hasToken = [self.appDelegate.accessToken length] > 0;
    if (!hasToken) {
        [self performSegueWithIdentifier:@"ShowGuide"
                                  sender:self.cards];
    } else {
        GatewayWebService *ws = [[GatewayWebService alloc] initWithURL:CC_STATUS(self.appDelegate.accessToken)];
        [ws sendRequest:^(NSDictionary *json, NSString *jsonStr) {
            if (json != nil) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:json];
                [userInfo removeObjectForKey:@"scenarios"];
                self.userInfo = [NSDictionary dictionaryWithDictionary:userInfo];
                self.scenarios = [json objectForKey:@"scenarios"];
                [self.appDelegate.oneSignal sendTag:@"user_id" value:[json objectForKey:@"user_id"]];
                [self.cards reloadData];
            }
        }];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([self.scenarios count] > 2) {
        // Hard code...
        return 3;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CheckinViewCell *cell = (CheckinViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"reuse" forIndexPath:indexPath];
    NSInteger idx = 1;
    
    // If the time is before 2016/08/20 17:00:00 show day 1, otherwise show day 2
    NSString *checkId, *lunchId;
    if ([self.appDelegate showWhichDay] == 1) {
        checkId = @"day1checkin";
        lunchId = @"day1lunch";
        
        if (indexPath.section == 0) {
            idx = 0;
        } else if (indexPath.section == 2) {
            idx = 2;
        }
    } else {
        checkId = @"day2checkin";
        lunchId = @"day2lunch";
        [cell.checkinDate setText:@"8/21"];
        
        if (indexPath.section == 0) {
            idx = 3;
        } else if (indexPath.section == 2) {
            idx = 4;
        }
    }
    
    switch (indexPath.section) {
        case 0:
            [cell setId:checkId];
            [cell.checkinTitle setText:NSLocalizedString(@"Checkin", nil)];
            [cell.checkinText setText:NSLocalizedString(@"CheckinText", nil)];
            break;
        case 1:
            [cell setId:@"kit"];
            [cell.checkinDate setText:@"COSCUP"];
            [cell.checkinTitle setText:NSLocalizedString(@"kit", nil)];
            [cell.checkinText setText:NSLocalizedString(@"CheckinNotice", nil)];
            [cell.checkinBtn setTitle:NSLocalizedString(@"UseButton", nil)
                             forState:UIControlStateNormal];
            break;
        case 2:
            [cell setId:lunchId];
            [cell.checkinTitle setText:NSLocalizedString(@"lunch", nil)];
            [cell.checkinText setText:NSLocalizedString(@"CheckinNotice", nil)];
            [cell.checkinBtn setTitle:NSLocalizedString(@"UseButton", nil)
                             forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    if ([self.scenarios[idx] objectForKey:@"used"]) {
        [cell.checkinBtn setTitle:NSLocalizedString(@"UseButtonPressed", nil)
                         forState:UIControlStateNormal];
        [cell.checkinBtn setBackgroundColor:[UIColor grayColor]];
    } else {
        [cell.checkinBtn setTitle:NSLocalizedString(@"CheckinViewButton", nil)
                         forState:UIControlStateNormal];
        [cell.checkinBtn setBackgroundColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
    }
    
    [self configureCell:cell withIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(CheckinViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    UIView *subview = [cell.contentView viewWithTag:TAG];
    [subview removeFromSuperview];
    
    switch (indexPath.section) {
        case 0:
            break;
        case 1:
            break;
        case 2:
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
