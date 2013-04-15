//
//  TWapi.h
//  TWapi
//
//  Created by Or Sagi on 21/12/12.
//  Copyright (c) 2012 Or Sagi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWUser.h"

#define SERV_PATH @"https://translatewiki.net/w/api.php"
#define HOST @"https://translatewiki.net"

//DEBUG purpose
#define LOG(X) NSLog(@"%@\n",X)

@interface TWapi : NSObject

-(void)TWPerformRequestWithParams:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;

-(id) initForUser:(TWUser*) linkedUser;
-(NSMutableDictionary *)TWRequest:(NSDictionary *)params;
-(NSMutableDictionary *)TWQueryRequest:(NSDictionary *)params;
-(NSString *)TWLoginRequestWithPassword:(NSString*) passw;
-(NSDictionary *)TWLogoutRequest;
-(NSDictionary *)TWEditRequest:(NSDictionary *)params;
-(bool)TWEditRequestWithTitle:(NSString*)title andText:(NSString*)text;
-(void)TWTranslatedMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;
-(void)TWUntranslatedMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;
-(NSMutableDictionary*)TWTranslationAidsForTitle:(NSString*)title withProject:(NSString*)proj;
- (bool)TWTranslationReviewRequest:(NSString *)revision;
- (NSString*) TWUserIdRequestOfUserName:(NSString*)userName;
-(NSArray *)TWProjectListMaxDepth:(NSInteger)depth;

-(void)TWQueryRequestAs:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;

@property(nonatomic, copy)TWUser* user;
@end
