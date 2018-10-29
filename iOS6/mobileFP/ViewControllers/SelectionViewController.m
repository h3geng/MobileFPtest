//
//  SelectionViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 12/11/14.
//  Copyright (c) 2014 FirstOnSite. All rights reserved.
//

#import "SelectionViewController.h"
#import "InventoryViewController.h"
#import "ClaimEquipmentViewController.h"
#import "TimesheetViewController.h"
#import "ClaimNoteViewController.h"
#import "EquipmentDetailsViewController.h"

@interface SelectionViewController ()

@end

@implementation SelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (!_selection) {
        _selection = [[NSMutableArray alloc] init];
    }
    
    if (!_selectionTitle || [_selectionTitle isEqual: @""]) {
        _selectionTitle = NSLocalizedStringFromTable(@"select", [UTIL getLanguage], @"");
    }
    
    [self setTitle:_selectionTitle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _selection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    GenericObject *go = [_selection objectAtIndex:[indexPath row]];
    [cell.textLabel setText:go.value];
    
    if ([go.genericId isEqual: _selectedObject.genericId]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedObject = [[_selection objectAtIndex:[indexPath row]] copy];
    
    UIViewController *parent = [APP_DELEGATE getPreviousScreen];
    if ([parent isKindOfClass:[InventoryViewController class]]) {
        InventoryViewController *inventoryViewController = (InventoryViewController *)parent;
        switch (_selectedObjectType) {
            case 1:
                [inventoryViewController setSelectedClass:_selectedObject];
                [inventoryViewController setSelectedModel:[[GenericObject alloc] init]];
                break;
            case 2:
                [inventoryViewController setSelectedModel:_selectedObject];
                break;
            case 3:
                [inventoryViewController setSelectedHome:_selectedObject];
                break;
            case 4:
                [inventoryViewController setSelectedCurrent:_selectedObject];
                break;
            case 5:
                [inventoryViewController setSelectedStatus:_selectedObject];
                break;
            case 6:
                [inventoryViewController setSelectedJobCost:_selectedObject];
                break;
        }
    }
    
    if ([parent isKindOfClass:[ClaimEquipmentViewController class]]) {
        ClaimEquipmentViewController *claimEquipmentViewController = (ClaimEquipmentViewController *)parent;
        switch (_selectedObjectType) {
            case 1:
                [claimEquipmentViewController setSelectionObject:_selectedObject];
                break;
        }
    }
    
    if ([parent isKindOfClass:[TimesheetViewController class]]) {
        TimesheetViewController *timesheetViewController = (TimesheetViewController *)parent;
        [timesheetViewController setSelectionObject:_selectedObject];
    }
    
    if ([parent isKindOfClass:[ClaimNoteViewController class]]) {
        ClaimNoteViewController *claimNoteViewController = (ClaimNoteViewController *)parent;
        switch (_selectedObjectType) {
            case 1:
                [claimNoteViewController setDepartmentObject:_selectedObject];
                break;
            case 2:
                [claimNoteViewController setPhaseObject:_selectedObject];
                break;
        }
    }
    
    if ([parent isKindOfClass:[EquipmentDetailsViewController class]]) {
        EquipmentDetailsViewController *equipmentDetailsViewController = (EquipmentDetailsViewController *)parent;
        [equipmentDetailsViewController setPhaseObject:_selectedObject];
        [equipmentDetailsViewController setReloadOnAppear:false];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
