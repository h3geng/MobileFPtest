//
//  CameraPictureOverlayView.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-10-06.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "CameraPictureOverlayView.h"

@implementation CameraPictureOverlayView
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
}
*/
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setOpaque:NO];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        CGFloat x = screenRect.size.width/5;
        CGFloat y = (screenRect.size.height/10) * 2;
        CGFloat w = (screenRect.size.width - (2*screenRect.size.width/5));
        CGFloat h = (screenRect.size.height/10) * 4.2;
        
        // main face container
        CAShapeLayer *rectLayer = [CAShapeLayer layer];
        [rectLayer setPath:[[UIBezierPath bezierPathWithRect:CGRectMake(x, y, w, h)] CGPath]];
        [rectLayer setStrokeColor:[[UIColor colorWithRed:255/255.0f green:204/255.0f blue:0/255.0f alpha:1.0f] CGColor]];
        [rectLayer setLineWidth:3.0f];
        [rectLayer setFillColor:[[UIColor clearColor] CGColor]];
        [[self layer] addSublayer:rectLayer];
        
        // blured borders
        CAShapeLayer *blurLayer = [CAShapeLayer layer];
        [blurLayer setPath:[[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, x, screenRect.size.height)] CGPath]];
        [blurLayer setFillColor:[[UIColor blackColor] CGColor]];
        [blurLayer setOpacity:0.35f];
        [[self layer] addSublayer:blurLayer];
        blurLayer = [CAShapeLayer layer];
        [blurLayer setPath:[[UIBezierPath bezierPathWithRect:CGRectMake(x, 0, w, y)] CGPath]];
        [blurLayer setFillColor:[[UIColor blackColor] CGColor]];
        [blurLayer setOpacity:0.35f];
        [[self layer] addSublayer:blurLayer];
        blurLayer = [CAShapeLayer layer];
        [blurLayer setPath:[[UIBezierPath bezierPathWithRect:CGRectMake(x+w, 0, x, screenRect.size.height                                                                                       )] CGPath]];
        [blurLayer setFillColor:[[UIColor blackColor] CGColor]];
        [blurLayer setOpacity:0.35f];
        [[self layer] addSublayer:blurLayer];
        blurLayer = [CAShapeLayer layer];
        [blurLayer setPath:[[UIBezierPath bezierPathWithRect:CGRectMake(x, y+h, w, screenRect.size.height-y-h                                                                                       )] CGPath]];
        [blurLayer setFillColor:[[UIColor blackColor] CGColor]];
        [blurLayer setOpacity:0.35f];
        [[self layer] addSublayer:blurLayer];
        
        [self setUserInteractionEnabled:NO];
    }
    return self;
}

@end
