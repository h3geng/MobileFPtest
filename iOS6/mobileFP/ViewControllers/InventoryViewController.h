//
//  InventoryViewController.h
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/11/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InventoryViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate>

@property Inventory *inventory;
@property NSDateFormatter *dateFormatter;

@property NSMutableArray *selection;
@property NSString *selectionTitle;

@property GenericObject *selectedClass;
@property GenericObject *selectedModel;
@property GenericObject *selectedHome;
@property GenericObject *selectedCurrent;
@property GenericObject *selectedStatus;
@property GenericObject *selectedJobCost;

@property int selectedObjectType;
@property bool itemDuplicate;
@property GenericObject *selectedObject;

- (IBAction)savePressed:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *classLabel;
@property (strong, nonatomic) IBOutlet UILabel *modelLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLabel;
@property (strong, nonatomic) IBOutlet UILabel *itemLabel;
@property (strong, nonatomic) IBOutlet UILabel *serialLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *vendorLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *lifeCycleLabel;
@property (strong, nonatomic) IBOutlet UILabel *homeLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *jobCostLabel;
@property (strong, nonatomic) IBOutlet UILabel *activeLabel;

@property (strong, nonatomic) IBOutlet UILabel *classDetailLabel;
@property (strong, nonatomic) IBOutlet UILabel *modelDetailLabel;
@property (strong, nonatomic) IBOutlet UITextField *tagTextField;
@property (strong, nonatomic) IBOutlet UITextField *itemTextField;
@property (strong, nonatomic) IBOutlet UITextField *serialTextField;
@property (strong, nonatomic) IBOutlet UITextField *dateTextField;
@property (strong, nonatomic) IBOutlet UITextField *vendorTextField;
@property (strong, nonatomic) IBOutlet UITextField *priceTextField;
@property (strong, nonatomic) IBOutlet UITextField *lifeCycleTextField;
@property (strong, nonatomic) IBOutlet UILabel *homeDetailLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentDetailLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusDetailLabel;
@property (strong, nonatomic) IBOutlet UILabel *jobCostDetailLabel;
@property (strong, nonatomic) IBOutlet UISwitch *activeSwitcher;

@property (strong, nonatomic) IBOutlet UIDatePicker *defaultDatePicker;

@end
