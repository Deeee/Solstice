//
//  ContactObject.m
//  Solstice
//
//  Created by Liu Di on 2/4/16.
//  Copyright © 2016 Di Liu. All rights reserved.
//

#import "ContactObject.h"
#import "Constants.h"
#import "ViewManager.h"
#import "AlertViewManager.h"
#import "NSNull+Json.h"
@implementation ContactObject
+(NSMutableArray *) parseContactJson:(NSArray *)json {
    NSMutableArray *ret = [NSMutableArray new];
    for (NSDictionary *contact in json) {
        NSLog(@"contactdict\n%@",contact);
        ContactObject *newContact = [ContactObject new];
        newContact.birthDate = [[contact objectForKey:@"birthdate"] intValue];
        newContact.company = [[contact objectForKey:@"company"] description];
        newContact.detailsUrl = [[contact objectForKey:@"detailsURL"] description];
        newContact.name = [[contact objectForKey:@"name"] description];
        NSDictionary *phoneDict = [contact objectForKey:@"phone"];
        newContact.homePhone = [[phoneDict objectForKey:@"home"] description];
        newContact.mobilePhone = [[phoneDict objectForKey:@"mobile"] description];
        newContact.workPhone = [[phoneDict objectForKey:@"work"] description];
        newContact.smallImageUrl = [[contact objectForKey:@"smallImageURL"] description];
        [ret addObject:newContact];
    }
    NSLog(@"before returning count is %ld",[ret count]);
    return ret;
}
@end
