//
//  TwitterUserFeedsTableViewController.m
//  Twitter Profile
//
//  Created by Naveen Kumar Dungarwal on 11/26/14.
//  Copyright (c) 2014 Jeroen van Rijn. All rights reserved.
//

#import "TwitterUserFeedsTableViewController.h"
#import "AppDelegate.h"

@interface TwitterUserFeedsTableViewController ()

@end

@implementation TwitterUserFeedsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagesDictionary = [NSMutableDictionary dictionary];
    
    [self refreshTwitterFeedWithCompletion];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)refreshTwitterFeedWithCompletion{
    // Request access to the Twitter accounts
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            
            // Check if the users has setup at least one Twitter account
            
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
                NSLog(@"request.account ...%@",twitterAccount.username);
                
                
                NSURL* url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
                NSDictionary* params = @{@"count" : @"50", @"screen_name" : twitterAccount.username};
                
                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                        requestMethod:SLRequestMethodGET
                                                                  URL:url parameters:params];
                
                request.account = twitterAccount;
                
                [request performRequestWithHandler:^(NSData *responseData,
                                                     NSHTTPURLResponse *urlResponse, NSError *error) {
                    
                    
                    if (error)
                    {
                        NSString* errorMessage = [NSString stringWithFormat:@"There was an error reading your Twitter feed. %@",
                                                  [error localizedDescription]];
                        
                        [[AppDelegate instance] showError:errorMessage];
                    }
                    else
                    {
                        NSError *jsonError;
                        NSArray *responseJSON = [NSJSONSerialization
                                                 JSONObjectWithData:responseData
                                                 options:NSJSONReadingAllowFragments
                                                 error:&jsonError];
                        
                        if (jsonError)
                        {
                            NSString* errorMessage = [NSString stringWithFormat:@"There was an error reading your Twitter feed. %@",
                                                      [jsonError localizedDescription]];
                            
                                            [[AppDelegate instance] showError:errorMessage];
                        }
                        else
                        {
                            NSLog(@"responseJSON..%@",(NSDictionary*)responseJSON.description);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self reloadData:responseJSON];

                                
                            });
                        }
                    }
                }];
            }
        }
    }];
}



-(void)reloadData:(NSArray*)jsonResponse
{
    self.tweets = jsonResponse;
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.tweets.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *tweetDictionary = self.tweets[indexPath.row];
    
    NSDictionary *user = tweetDictionary[@"user"];
    
    
    NSString *userName = user[@"name"];
    NSString *tweetContaint = tweetDictionary[@"text"];
    
     cell.imageView.image = [UIImage imageNamed:@"images.png"];
    
    NSString* imageUrl = [user objectForKey:@"profile_image_url"];
    [self getImageFromUrl:imageUrl asynchronouslyForImageView:cell.imageView andKey:userName];
    
    NSArray *days = [NSArray arrayWithObjects:@"Mon ", @"Tue ", @"Wed ", @"Thu ", @"Fri ", @"Sat ", @"Sun ", nil];
    NSArray *calendarMonths = [NSArray arrayWithObjects:@"Jan", @"Feb", @"Mar",@"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec", nil];
    NSString *dateStr = [tweetDictionary objectForKey:@"created_at"];
    
    for (NSString *day in days) {
        if ([dateStr rangeOfString:day].location == 0) {
            dateStr = [dateStr stringByReplacingOccurrencesOfString:day withString:@""];
            break;
        }
    }
    
    NSArray *dateArray = [dateStr componentsSeparatedByString:@" "];
    NSArray *hourArray = [[dateArray objectAtIndex:2] componentsSeparatedByString:@":"];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSString *aux = [dateArray objectAtIndex:0];
    int month = 0;
    for (NSString *m in calendarMonths) {
        month++;
        if ([m isEqualToString:aux]) {
            break;
        }
    }
    components.month = month;
    components.day = [[dateArray objectAtIndex:1] intValue];
    components.hour = [[hourArray objectAtIndex:0] intValue];
    components.minute = [[hourArray objectAtIndex:1] intValue];
    components.second = [[hourArray objectAtIndex:2] intValue];
    components.year = [[dateArray objectAtIndex:4] intValue];
    
    NSTimeZone *gmt = [NSTimeZone timeZoneForSecondsFromGMT:2];
    [components setTimeZone:gmt];
    
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *date = [calendar dateFromComponents:components];
    
    NSString *tweetDate = [self getTimeAsString:date];
    
    NSString *tweetValues = [NSString stringWithFormat:@"%@ :%@",userName,tweetDate];
    
    cell.textLabel.text = tweetValues;
    
    cell.detailTextLabel.text = tweetContaint;
//    cell.textLabel.frame =
//    CGRectMake(cell.textLabel.frame.origin.x,
//               cell.textLabel.frame.origin.y,
//               cell.bounds.size.width - 84,
//               [self heightForCellAtIndex:indexPath.row]-50);
//    cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
    
    
    
    
    return cell;

}

- (CGFloat)heightForCellAtIndex:(NSUInteger)index {
    
    NSDictionary *tweet = self.tweets[index];
    CGFloat cellHeight = 55;
    NSString *tweetText = tweet[@"text"];
    
    CGFloat width = kCollectionFeedWidthPortrait;
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        width = kCollectionFeedWidthLandscape;
    }
    CGSize labelHeight = [tweetText sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(width - 84, 4000)];
    
    cellHeight += labelHeight.height;
    return cellHeight;
}


- (NSString*)getTimeAsString:(NSDate *)lastDate {
    NSTimeInterval dateDiff =  [[NSDate date] timeIntervalSinceDate:lastDate];
    
    int nrSeconds = dateDiff;//components.second;
    int nrMinutes = nrSeconds / 60;
    int nrHours = nrSeconds / 3600;
    int nrDays = dateDiff / 86400; //components.day;
    
    NSString *time;
    if (nrDays > 5){
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterShortStyle];
        [dateFormat setTimeStyle:NSDateFormatterNoStyle];
        
        time = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:lastDate]];
    } else {
        // days=1-5
        if (nrDays > 0) {
            if (nrDays == 1) {
                time = @"1 day ago";
            } else {
                time = [NSString stringWithFormat:@"%d days ago", nrDays];
            }
        } else {
            if (nrHours == 0) {
                if (nrMinutes < 2) {
                    time = @"just now";
                } else {
                    time = [NSString stringWithFormat:@"%d minutes ago", nrMinutes];
                }
            } else { // days=0 hours!=0
                if (nrHours == 1) {
                    time = @"1 hour ago";
                } else {
                    time = [NSString stringWithFormat:@"%d hours ago", nrHours];
                }
            }
        }
    }
    
    return [NSString stringWithFormat:NSLocalizedString(@"%@", @"label"), time];
}


-(void)getImageFromUrl:(NSString*)imageUrl asynchronouslyForImageView:(UIImageView*)imageView andKey:(NSString*)key{
    
    dispatch_async(dispatch_get_global_queue(
                                             DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *url = [NSURL URLWithString:imageUrl];
        
        __block NSData *imageData;
        
        dispatch_sync(dispatch_get_global_queue(
                                                DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            imageData =[NSData dataWithContentsOfURL:url];
            
            if(imageData){
                
                [self.imagesDictionary setObject:[UIImage imageWithData:imageData] forKey:key];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    imageView.image = self.imagesDictionary[key];
                });
            }
        });
    });
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
