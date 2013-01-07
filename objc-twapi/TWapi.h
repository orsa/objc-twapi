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
+(NSString *)TWLoginRequestForUser:(NSString*)username WithPassword:(NSString*) passw;
+(NSDictionary *)TWLogoutRequest;
+(NSDictionary *)TWEditRequest:(NSDictionary *)params;
+(NSDictionary *)TWMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit ByUserId:(NSString*) userId;
@end
