//
//  ReceiptViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-03-23.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "ReceiptViewController.h"

@interface ReceiptViewController ()

@end

@implementation ReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:@"Receipt"];
    if (_expenseId > 0) {
        [UTIL showActivity:@""];
        
        [self loadExpenseReceipt];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadExpenseReceipt {
    [API getExpenseReceipt:USER.sessionId expenseId:_expenseId completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *expenseReceiptId = [result valueForKey:@"getExpenseReceiptResult"];
        if (![expenseReceiptId isEqual: @"0"]) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@", RECEIPT_URL, USER.sessionId, expenseReceiptId]];
            [self->_expenseImage loadRequest:[NSURLRequest requestWithURL:url]];
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cameraPressed:(id)sender {
    [_sourcePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [_sourcePicker setAllowsEditing:YES];
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) { // authorized
        [self presentViewController:_sourcePicker animated:YES completion:^ {
            [self.tabBarController.tabBar setHidden:YES];
        }];
    } else if (status == AVAuthorizationStatusDenied) { // denied
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"image_source_denied", [UTIL getLanguage], @"")];
    } else if (status == AVAuthorizationStatusRestricted) { // restricted
        [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"image_source_denied", [UTIL getLanguage], @"")];
    } else if (status == AVAuthorizationStatusNotDetermined) { // not determined
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) { // Access has been granted
                [self presentViewController:self->_sourcePicker animated:YES completion:^ {
                    [self.tabBarController.tabBar setHidden:YES];
                }];
            } else { // Access denied
                [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"image_source_denied", [UTIL getLanguage], @"")];
            }
        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^ {
        [self.tabBarController.tabBar setHidden:NO];
    }];
    
    _selectedImage = info[UIImagePickerControllerOriginalImage];
    [_expenseImage setBackgroundColor:[UIColor colorWithPatternImage:_selectedImage]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^ {
        [self.tabBarController.tabBar setHidden:NO];
    }];
}

@end
