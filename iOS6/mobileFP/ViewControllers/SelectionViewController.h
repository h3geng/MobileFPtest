//
//  SelectionViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/11/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectionViewController : UITableViewController

@property NSMutableArray *selection;
@property NSString *selectionTitle;

@property int selectedObjectType;
@property GenericObject *selectedObject;

@end
