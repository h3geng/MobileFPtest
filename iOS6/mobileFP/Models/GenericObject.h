//
//  GenericObject.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 8/6/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenericObject : NSObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *genericId;
@property (nonatomic, strong) NSString *parentId;
@property (nonatomic, strong) NSString *value;

- (id)init;
- (void)initWithData:(NSMutableArray *)data;
- (NSString *)getServiceRelatedContent;
- (id)copyWithZone:(NSZone *)zone;

@end
