//
//  AppDelegate.h
//  Twitter Profile
//
//  Created by Jeroen van Rijn on 05-02-13.
//  Copyright (c) 2013 Jeroen van Rijn. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat kCollectionFeedWidthPortrait;
extern CGFloat kCollectionFeedWidthLandscape;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


+(AppDelegate*)instance;
-(void)showError:(NSString*)errorMessage;
@end
