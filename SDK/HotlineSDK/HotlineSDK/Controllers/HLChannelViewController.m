//
//  HLChannelViewController.m
//  HotlineSDK
//
//  Created by user on 04/11/15.
//  Copyright © 2015 Freshdesk. All rights reserved.
//

#import "HLChannelViewController.h"
#import "HLMacros.h"
#import "HLTheme.h"
#import "FDLocalNotification.h"
#import "FDChannelUpdater.h"
#import "HLChannel.h"
#import "HLContainerController.h"
#import "FDMessageController.h"
#import "FDChannelListViewCell.h"
#import "KonotorMessage.h"
#import "KonotorConversation.h"
#import "FDDateUtil.h"

@interface HLChannelViewController ()

@property (nonatomic, strong) NSMutableArray *channels;


@end

@implementation HLChannelViewController

-(void)willMoveToParentViewController:(UIViewController *)parent{
    [super willMoveToParentViewController:parent];
    parent.title = @"Channels";
    self.channels = [[NSMutableArray alloc] init];
    [self setNavigationItem];
    [self updateChannels];
    [self localNotificationSubscription];
}

-(void)viewWillAppear:(BOOL)animated{
    [self fetchUpdates];
}

-(void)updateChannels{
    [[KonotorDataManager sharedInstance]fetchAllVisibleChannels:^(NSArray *channels, NSError *error) {
        if (!error) {
            self.channels = channels;
            [self.tableView reloadData];
        }
    }];
}

-(void)setNavigationItem{
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]initWithTitle:HLLocalizedString(@"FAQ_GRID_VIEW_CLOSE_BUTTON_TITLE_TEXT") style:UIBarButtonItemStylePlain target:self action:@selector(closeButton:)];
    
    self.parentViewController.navigationItem.leftBarButtonItem = closeButton;
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
}

-(void)localNotificationSubscription{
    __weak typeof(self)weakSelf = self;
    [[NSNotificationCenter defaultCenter]addObserverForName:HOTLINE_CHANNELS_UPDATED object:nil queue:nil usingBlock:^(NSNotification *note) {
        HideNetworkActivityIndicator();
        [weakSelf updateChannels];
        NSLog(@"Got Notifications !!!");
    }];
}

-(void)fetchUpdates{
    FDChannelUpdater *updater = [[FDChannelUpdater alloc]init];
    [[KonotorDataManager sharedInstance]areChannelsEmpty:^(BOOL isEmpty) {
        if(isEmpty)[updater resetTime];
        ShowNetworkActivityIndicator();
        [updater fetchWithCompletion:^(BOOL isFetchPerformed, NSError *error) {
            if (!isFetchPerformed) HideNetworkActivityIndicator();
        }];
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"HLChannelsCell";
    FDChannelListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[FDChannelListViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (indexPath.row < self.channels.count) {
        HLChannel *channel =  self.channels[indexPath.row];
        if (channel.icon) {
            cell.imgView.image = [UIImage imageWithData:channel.icon];
        }else{
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
            NSString *firstLetter = [channel.name substringToIndex:1];
            firstLetter = [firstLetter uppercaseString];
            label.text = firstLetter;
            label.font = [UIFont boldSystemFontOfSize:16];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor lightGrayColor];
            label.layer.cornerRadius = label.frame.size.height / 2.0f;
            UIGraphicsBeginImageContext(label.frame.size);
            [[label layer] renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            cell.imgView.image = image;
        }
        cell.imgView.layer.cornerRadius = cell.imgView.frame.size.width / 2;
        cell.imgView.layer.masksToBounds = YES;
        cell.titleLabel.text  = channel.name;
        cell.detailLabel.text = channel.hasWelcomeMessage.text;
        NSInteger unreadCount = [self getUnreadCountForConversation:channel.hasConversations];
        [cell.badgeView updateBadgeCount:1];
        cell.lastUpdatedLabel.text= [FDDateUtil itemCreatedDurationSinceDate:channel.lastUpdated];
    }
    return cell;
}

-(NSInteger)getUnreadCountForConversation:(NSSet *)conversations{
    NSArray *conversationsArray = conversations.allObjects;
    KonotorConversation *conversation = conversationsArray.firstObject;
    NSInteger unreadCount = conversation.unreadMessagesCount;
    if (unreadCount==0) {
        return 0;
    }else{
        return unreadCount;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)sectionIndex{
    return self.channels.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.channels.count) {
        FDMessageController *conversationController = [[FDMessageController alloc]initWithChannel:nil andPresentModally:NO];
        HLContainerController *container = [[HLContainerController alloc]initWithController:conversationController];
        [self.navigationController pushViewController:container animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

-(void)closeButton:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end