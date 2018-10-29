//
//  ClaimOwner.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 2018-02-21.
//  Copyright © 2018 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClaimOwner : Contact

@property Address *address;
@property NSString *email2;
@property NSString *phone2;
@property NSString *phone2Ext;
@property NSString *contactName;
@property NSString *contactPhone;
@property NSString *phone2Formatted;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;

@end
