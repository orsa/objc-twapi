//
//  TWapi.h
//  TWapi
//
//  Created by Or Sagi on 21/12/12.
//  Copyright (c) 2012 Or Sagi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWapi : NSObject

+(NSMutableDictionary *)TWRequest:(NSDictionary *)params;
+(NSMutableDictionary *)TWQueryRequest:(NSDictionary *)params;
+(NSString *)TWLoginRequestForUser:(NSString*)username WithPassword:(NSString*) passw;
+(NSDictionary *)TWLogoutRequest;
+(NSDictionary *)TWEditRequest:(NSDictionary *)params;
+(NSMutableDictionary *)TWMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset ByUserId:(NSString*) userId;
+ (bool)TWTranslationReviewRequest:(NSString *)revision;
+ (NSString*) TWUserIdRequestOfUserName:(NSString*)userName;
@end
