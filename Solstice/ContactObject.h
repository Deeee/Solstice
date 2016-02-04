//
//  ContactObject.h
//  Solstice
//
//  Created by Liu Di on 2/4/16.
//  Copyright © 2016 Di Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ContactObject : NSObject
@property int birthDate;
@property NSString *company;
@property NSString *detailsUrl;
@property NSString *name;
@property NSString *homePhone;
@property NSString *mobilePhone;
@property NSString *workPhone;
@property NSString *smallImageUrl;
+(NSMutableArray *) parseContactJson:(NSArray *)json;
@end
