//
//  ClaimPhotoObject.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-05-16.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "ClaimPhotoObject.h"

@implementation ClaimPhotoObject

- (id)init {
    self = [super init];
    if (self) {
        _selfId = 0;
        _claimIndx = 0;
        _phaseIndx = 0;
        _phaseName = @"";
        _photoDescription = @"";
        _photo = nil;
        _thumbnail = nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_selfId forKey:@"selfId"];
    [encoder encodeInt:_claimIndx forKey:@"claimIndx"];
    [encoder encodeInt:_phaseIndx forKey:@"phaseIndx"];
    [encoder encodeObject:_phaseName forKey:@"phaseName"];
    [encoder encodeObject:_photoDescription forKey:@"photoDescription"];
    [encoder encodeObject:_photo forKey:@"photo"];
    [encoder encodeObject:_thumbnail forKey:@"thumbnail"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _selfId = [decoder decodeIntForKey:@"selfId"];
        _claimIndx = [decoder decodeIntForKey:@"claimIndx"];
        _phaseIndx = [decoder decodeIntForKey:@"phaseIndx"];
        _phaseName = [decoder decodeObjectForKey:@"phaseName"];
        _photoDescription = [decoder decodeObjectForKey:@"photoDescription"];
        _photo = [decoder decodeObjectForKey:@"photo"];
        _thumbnail = [decoder decodeObjectForKey:@"thumbnail"];
    }
    return self;
}

- (void)upload:(void(^)(bool result))completion {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    if ([APP_MODE isEqual: @"1"]) {
        [request setURL:[NSURL URLWithString:UPLOAD_PRODUCTION_URL]];
    } else {
        [request setURL:[NSURL URLWithString:UPLOAD_TEST_URL]];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ddMMyyyyHHmmss"];
    
    NSString *boundary = [NSString stringWithFormat:@"---------------------------147378098314664%@", [formatter stringFromDate:[NSDate date]]];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    NSString *fileName = [NSString stringWithFormat:@"%d-%@-%d", _claimIndx, [formatter stringFromDate:[NSDate date]], _selfId];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSString stringWithFormat:@"%@", USER.sessionId] forKey:@"sessionId"];
    [params setObject:[NSString stringWithFormat:@"%d", USER.regionId] forKey:@"regionId"];
    [params setObject:[NSString stringWithFormat:@"%d", _claimIndx] forKey:@"claimIndx"];
    [params setObject:[NSString stringWithFormat:@"%d", _phaseIndx] forKey:@"phaseIndx"];
    [params setObject:@"Image" forKey:@"fileType"];
    [params setObject:fileName forKey:@"fileName"];
    [params setObject:@"jpg" forKey:@"fileExt"];
    [params setObject:_photoDescription forKey:@"description"];
    [params setObject:@"" forKey:@"fileBase64"];
    
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // resize image
    CGFloat max = 1280.0f;
    CGFloat scaleFactor = 1.0f;
    CGSize scaledSize = CGSizeMake(_photo.size.width, _photo.size.height);
    
    if (_photo.size.width > _photo.size.height) {
        if (_photo.size.width > max) {
            scaleFactor = _photo.size.width / _photo.size.height;
            scaledSize.width = max;
            scaledSize.height = scaledSize.width / scaleFactor;
        }
    } else {
        if (_photo.size.height > max) {
            scaleFactor = _photo.size.height / _photo.size.width;
            scaledSize.height = max;
            scaledSize.width = scaledSize.height / scaleFactor;
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(scaledSize, YES, 1.0f);
    CGRect scaledImageRect = CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height);
    [_photo drawInRect:scaledImageRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // adding a watermark to all the photos being uploaded
    NSDateFormatter *formatterCurrentYear = [[NSDateFormatter alloc] init];
    [formatterCurrentYear setDateFormat:@"yyyy"];
    NSString *currentYearString = [formatterCurrentYear stringFromDate:[NSDate date]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:scaledImageRect];
    [imageView setImage:scaledImage];
    [imageView setBackgroundColor:[UIColor whiteColor]];
    UILabel *watermarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, scaledImageRect.size.height - 30, scaledImageRect.size.width, 30)];
    watermarkLabel.text = [NSString stringWithFormat:@"   Copyright %@, FirstOnSite Restoration Limited", currentYearString];
    watermarkLabel.textAlignment = NSTextAlignmentLeft;
    watermarkLabel.textColor = [UIColor whiteColor];
    watermarkLabel.backgroundColor = [UIColor blackColor];
    [imageView addSubview:watermarkLabel];
    
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imageWithWatermark = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImageJPEGRepresentation(imageWithWatermark, 0.65f);
    //NSLog(@"Size of Image(bytes):%lu",(unsigned long)[imageData length]);
    
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n", fileName, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    NSURLSessionDataTask *postDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSData *resultsData;
        NSMutableArray *responseData;
        if (error) {
            resultsData = [[NSString stringWithFormat:@"{\"error\":\"%@\"}", [error localizedDescription]] dataUsingEncoding:NSUTF8StringEncoding];
            responseData = [NSJSONSerialization JSONObjectWithData:resultsData options:NSJSONReadingMutableContainers error:&error];
        } else {
            NSString *results = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            resultsData = [results dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            responseData = [NSJSONSerialization JSONObjectWithData:resultsData options:NSJSONReadingMutableLeaves error:&error];
        }
        
        if ([[responseData valueForKey:@"Status"] intValue] == 0) {
            completion(true);
        } else {
            completion(false);
        }
        
    }];
    
    [postDataTask resume];
}

@end
