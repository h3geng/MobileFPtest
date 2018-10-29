//
//  WhatsNewView.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-05-25.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "WhatsNewView.h"

@implementation WhatsNewView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [self setBackgroundColor:[UTIL blueColor]];
    [self setAlpha:0.85f];
    
    CGFloat top = 64.0f;
    
    UILabel *label = [[UILabel alloc] init];
    [label setText:NSLocalizedStringFromTable(@"whats_new", [UTIL getLanguage], @"")];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont systemFontOfSize:17]];
    [label sizeToFit];
    [label setFrame:CGRectMake(15, top, self.frame.size.width, label.frame.size.height)];
    top += label.frame.size.height + 24;
    
    [self addSubview:label];
    
    NSString *appDate = @"";
    NSString *appBuild = @"";
    
    NSURL *legalUrl = [[NSBundle mainBundle] URLForResource:@"Legal" withExtension:@"plist" subdirectory:@"Settings.bundle"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:legalUrl];
    NSMutableArray *array = [dictionary objectForKey:@"PreferenceSpecifiers"];
    
    for (id val in array) {
        if ([[val objectForKey:@"Key"] isEqualToString:@"appBuild"]) {
            appBuild = [val objectForKey:@"DefaultValue"];
        } else {
            if ([[val objectForKey:@"Key"] isEqualToString:@"appDate"]) {
                appDate = [val objectForKey:@"DefaultValue"];
            }
        }
    }
    
    if (![appBuild isEqualToString:@""]) {
        label = [[UILabel alloc] init];
        [label setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedStringFromTable(@"build", [UTIL getLanguage], @""), appBuild]];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont systemFontOfSize:15]];
        [label sizeToFit];
        [label setFrame:CGRectMake(15, top, self.frame.size.width, label.frame.size.height)];
        top += label.frame.size.height + 4;
        [self addSubview:label];
    }
    
    if (![appDate isEqualToString:@""]) {
        label = [[UILabel alloc] init];
        [label setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedStringFromTable(@"release_date", [UTIL getLanguage], @""), appDate]];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont systemFontOfSize:15]];
        [label sizeToFit];
        [label setFrame:CGRectMake(15, top, self.frame.size.width, label.frame.size.height)];
        top += label.frame.size.height + 4;
        [self addSubview:label];
    }
    
    top += 12;
    NSString *changes = NSLocalizedStringFromTable(@"changes", [UTIL getLanguage], @"");
    NSArray *items = [changes componentsSeparatedByString:@"|"];
    
    for (NSString *item in items) {
        label = [[UILabel alloc] init];
        [label setText:[NSString stringWithFormat:@"- %@", item]];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont systemFontOfSize:15]];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [label setNumberOfLines:-1];
        [label setFrame:CGRectMake(15, top, self.frame.size.width, 100)];
        [label sizeToFit];
        [label setFrame:CGRectMake(15, top, self.frame.size.width, label.frame.size.height)];
        top += label.frame.size.height + 6;
        [self addSubview:label];
    }
    
    UIButton *dismissButton = [[UIButton alloc] init];
    [dismissButton setTitle:NSLocalizedStringFromTable(@"dismiss", [UTIL getLanguage], @"") forState:UIControlStateNormal];
    [dismissButton setBackgroundColor:[UIColor whiteColor]];
    [dismissButton setTitleColor:[UTIL darkBlueColor] forState:UIControlStateNormal];
    [dismissButton setTintColor:[UTIL darkBlueColor]];
    [dismissButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    
    [dismissButton.layer setCornerRadius:5.0f];
    [dismissButton setTitleEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    [dismissButton sizeToFit];
    [dismissButton addTarget:self action:@selector(dismissPressed:) forControlEvents:UIControlEventTouchUpInside];
    [dismissButton setFrame:CGRectMake((self.bounds.size.width - (dismissButton.bounds.size.width + 80))/2, self.bounds.size.height - dismissButton.bounds.size.height - 60, dismissButton.bounds.size.width + 80, dismissButton.bounds.size.height + 10)];
    [self addSubview:dismissButton];
}

- (void)dismissPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"whatsNewDismissed" object:nil userInfo:nil];
}

@end
