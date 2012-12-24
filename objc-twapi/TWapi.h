//
//  TWapi.h
//  TWapi
//
//  Created by Or Sagi on 21/12/12.
//  Copyright (c) 2012 Or Sagi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWapi : NSObject

+(NSDictionary *)TWRequest:(NSDictionary *)params;
+(NSDictionary *)TWQueryRequest:(NSDictionary *)params;
+(NSDictionary *)TWLoginRequest:(NSDictionary *)params;
+(NSDictionary *)TWLogoutRequest:(NSDictionary *)params;
+(NSDictionary *)TWEditRequest:(NSDictionary *)params;
@end
