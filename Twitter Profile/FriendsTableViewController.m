//
//  FriendsTableViewController.m
//  Twitter Profile
//
//  Created by Naveen Kumar Dungarwal on 11/26/14.
//  Copyright (c) 2014 Jeroen van Rijn. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "AppDelegate.h"

@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imagesDictionary = [NSMutableDictionary dictionary];
    
    
    [self refreshTwitterFriendsListWithCompletion];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshTwitterFriendsListWithCompletion{
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
                
                
                NSURL* url = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/list.json"];
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
                            NSLog(@"friends responseJSON..%@",(NSDictionary*)responseJSON.description);
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
    NSDictionary *followersDict = (NSDictionary*)jsonResponse;
    self.tweets = [followersDict objectForKey:@"users"];
    [self.tableView reloadData];
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
    
    NSDictionary *user = self.tweets[indexPath.row];
    
    NSString *userName = user[@"name"];
    
    cell.imageView.image = [UIImage imageNamed:@"images.png"];
    
    NSString* imageUrl = [user objectForKey:@"profile_image_url"];
    [self getImageFromUrl:imageUrl asynchronouslyForImageView:cell.imageView andKey:userName];
    
    cell.textLabel.text = userName;
    
    return cell;
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
