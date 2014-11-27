//
//  TwitterUserFeedsTableViewController.h
//  Twitter Profile
//
//  Created by Naveen Kumar Dungarwal on 11/26/14.
//  Copyright (c) 2014 Jeroen van Rijn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>


@interface TwitterUserFeedsTableViewController : UITableViewController
{
    
}

@property (strong, atomic) NSArray *tweets;
@property (strong, atomic) NSMutableDictionary *imagesDictionary;

-(void)getImageFromUrl:(NSString*)imageUrl asynchronouslyForImageView:(UIImageView*)imageView andKey:(NSString*)key;
@end
