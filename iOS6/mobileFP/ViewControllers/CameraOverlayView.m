//
//  CameraOverlayView.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-05-25.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "CameraOverlayView.h"

@implementation CameraOverlayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //[self setBackgroundColor:[UIColor clearColor]];
    //[self setAlpha:1.0f];
    //[self setOpaque:NO];
    //[self.layer setBorderWidth:1.5f];
    //[self.layer setMasksToBounds:YES];
    //[self.layer setBorderColor:[UIColor colorWithRed:252/255.0f green:205/255.0f blue:1/255.0f alpha:1.0f].CGColor];
    
    //[self.layer setCornerRadius:50.0f];
    //everything for label
    UILabel *label = [[UILabel alloc] init];
    [label setText:@"For best"];
    label.textColor = [UIColor whiteColor];
    [label setNumberOfLines:0];
    [label setBackgroundColor:[UIColor colorWithRed:252/255.0f green:205/255.0f blue:1/255.0f alpha:1.0f]];
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[UIFont systemFontOfSize:18.0f]];
    [label sizeToFit];
    [label setFrame:CGRectMake(rect.size.width - 100, rect.size.height - 100, 100, 100)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Rotate"]];
    [imageView setFrame:CGRectMake(3*rect.size.width / 4 - 19, rect.size.height - 66, 38, 38)];
    [imageView setBackgroundColor:[UIColor clearColor]];
 
    //add the components to the view
    //[self addSubview: label];
    //[self addSubview: imageView];
    //label.center = self.center;
}
*/
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setOpaque:NO];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Rotate"]];
        [imageView setFrame:CGRectMake(3*self.bounds.size.width / 4 - 19, self.bounds.size.height - 66, 38, 38)];
        [imageView setBackgroundColor:[UIColor clearColor]];
        
        //add the components to the view
        //[self addSubview: label];
        [self addSubview: imageView];
    }
    return self;
}

@end
