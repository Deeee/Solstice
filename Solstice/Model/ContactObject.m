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
@implementation ContactObject
- (id) init {
    if (self = [super init]) {
        self.homeAddress = [NSMutableArray new];
        self.homePhone = [NSMutableArray new];
        self.mobilePhone = [NSMutableArray new];
        self.workPhone = [NSMutableArray new];
        self.workEmail = [NSMutableArray new];
        self.birthDate = 1000000;
        self.name = @"Long press to edit";
        self.company = @"Long press to edit";
    }
    return self;
}
+(NSMutableArray *) extractFavorites:(NSMutableArray *) contactsArray {
    NSMutableArray *favorites = [NSMutableArray new];
    for (ContactObject *contact in contactsArray) {
        NSLog(@"%@ %d",contact.name,contact.isFavorite);
        if (contact.isFavorite) {
            [favorites addObject:contact];
        }
    }
    return favorites;
}
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
        NSString *homePhoneStr = [[phoneDict objectForKey:@"home"] description];
        if (homePhoneStr != nil) {
            [newContact.homePhone addObject:homePhoneStr];
        }
        NSString *mobilePhoneStr = [[phoneDict objectForKey:@"mobile"] description];
        if (mobilePhoneStr != nil) {
            [newContact.mobilePhone addObject:mobilePhoneStr];
        }
        NSString *workPhoneStr = [[phoneDict objectForKey:@"work"] description];
        if (workPhoneStr != nil) {
            [newContact.workPhone addObject:[[phoneDict objectForKey:@"work"] description]];
        }
        newContact.smallImageUrl = [[contact objectForKey:@"smallImageURL"] description];
        [ret addObject:newContact];
        [[ViewManager sharedViewManager] fetchContactsDetailsOnContact:newContact];
    }
    return ret;
}
-(void) updateContactWithJson:(NSDictionary *)json {
    self.isFavorite = [[json objectForKey:@"favorite"] boolValue];
    self.largeImageUrl = [[json objectForKey:@"largeImageURL"] description];
    [self.workEmail addObject:[[json objectForKey:@"email"] description]];
    NSDictionary *address = [json objectForKey:@"address"];
    self.street = [[address objectForKey:@"street"] description];
    self.city = [[address objectForKey:@"city"] description];
    self.state = [[address objectForKey:@"state"] description];
    self.country = [[address objectForKey:@"country"] description];
    self.zip = [[address objectForKey:@"zip"] description];
    NSString *addressAll = [NSString stringWithFormat:@"%@\n%@, %@ %@, %@",self.street,self.city,self.state,self.zip, self.country];
    [self.homeAddress addObject:addressAll];
    
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject: [self company] forKey: @"company"];
    [aCoder encodeObject: [self detailsUrl] forKey: @"detailsUrl"];
    [aCoder encodeObject: [self name] forKey:@"name"];
    [aCoder encodeObject: [self homePhone] forKey:@"homePhone"];
    [aCoder encodeObject: [self mobilePhone] forKey:@"mobilePhone"];
    [aCoder encodeObject: [self workPhone] forKey:@"workPhone"];
    [aCoder encodeObject: [self homeAddress] forKey:@"homeAddress"];
    [aCoder encodeObject: [self workEmail] forKey:@"workEmail"];
    [aCoder encodeObject: [self smallImageUrl] forKey:@"smallImageUrl"];
    [aCoder encodeObject: [self largeImageUrl] forKey:@"largeImageUrl"];

    [aCoder encodeObject: [NSNumber numberWithInt:[self birthDate]] forKey:@"birthDate"];
    [aCoder encodeObject: [NSNumber numberWithBool:self.isFavorite] forKey:@"isFavorite"];
    //    [aCoder encodeObject: [self selectedOption] forKey:@"selectedOption"];
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _company = [aDecoder decodeObjectForKey:@"company"];
        _detailsUrl = [aDecoder decodeObjectForKey:@"detailsUrl"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _homePhone = [aDecoder decodeObjectForKey:@"homePhone"];
        _mobilePhone = [aDecoder decodeObjectForKey:@"mobilePhone"];
        _workPhone = [aDecoder decodeObjectForKey:@"workPhone"];
        _homeAddress = [aDecoder decodeObjectForKey:@"homeAddress"];
        _workEmail = [aDecoder decodeObjectForKey:@"workEmail"];
        _smallImageUrl = [aDecoder decodeObjectForKey:@"smallImageUrl"];
        _largeImageUrl = [aDecoder decodeObjectForKey:@"largeImageUrl"];

        _birthDate = [[aDecoder decodeObjectForKey:@"birthDate"] intValue];
        _isFavorite = [[aDecoder decodeObjectForKey:@"isFavorite"] boolValue];
    }
    return self;
}
@end
