//
//  TWapi.h
//  TWapi
//
//  Created by Or Sagi on 21/12/12.
//  Copyright (c) 2012 Or Sagi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWUser.h"

@interface TWapi : NSObject

-(id) initForUser:(TWUser*) linkedUser;
-(NSMutableDictionary *)TWRequest:(NSDictionary *)params;
-(NSMutableDictionary *)TWQueryRequest:(NSDictionary *)params;
-(NSString *)TWLoginRequestWithPassword:(NSString*) passw;
-(NSDictionary *)TWLogoutRequest;
-(NSDictionary *)TWEditRequest:(NSDictionary *)params;
-(NSMutableDictionary *)TWMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset;
- (bool)TWTranslationReviewRequest:(NSString *)revision;
- (NSString*) TWUserIdRequestOfUserName:(NSString*)userName;
-(NSArray *)TWProjectListMaxDepth:(NSInteger)depth;

@property(nonatomic, copy)TWUser* user;
@end
