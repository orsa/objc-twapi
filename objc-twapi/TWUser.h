//
//  TWUser.h
//  TWapi
//
//  Copyright 2013 Or Sagi, Tomer Tuchner
//

#import <Foundation/Foundation.h>

@interface TWUser : NSObject

@property(nonatomic, copy)NSString* userName; // user name
@property(nonatomic, copy)NSString* userId;   // user id
@property BOOL isLoggedin;  // did the authentication succeed, and the user is logged in

-(id) init;

@end
