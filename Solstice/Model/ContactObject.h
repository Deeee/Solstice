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

@property NSMutableArray *homePhone;
@property NSMutableArray *mobilePhone;
@property NSMutableArray *workPhone;
@property NSMutableArray *homeAddress;
@property NSMutableArray *workEmail;

@property NSString *smallImageUrl;

@property NSString *largeImageUrl;
@property NSString *street;
@property NSString *city;
@property NSString *state;
@property NSString *country;
@property NSString *zip;
@property BOOL isFavorite;
+(NSMutableArray *) parseContactJson:(NSArray *)json;
+(NSMutableArray *) extractFavorites:(NSMutableArray *) contactsArray;
-(void) updateContactWithJson:(NSDictionary *)json;
@end
