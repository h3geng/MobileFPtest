//
//  Models.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/11/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Models : NSObject

@property (nonatomic, strong) NSMutableArray *items;

+ (Models *)getInstance;

- (void)loadItems;
- (GenericObject *)getModelById:(int)modelId;
- (GenericObject *)getModelByName:(NSString *)modelName;
- (NSMutableArray *)getModelsByClassId:(int)classId;

@end
