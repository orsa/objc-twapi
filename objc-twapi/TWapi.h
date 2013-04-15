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
-(void)TWLoginRequestWithPassword:(NSString*) passw completionHandler:(void (^)(NSString *, NSError *))completionBlock;
-(void)TWLogoutRequest:(void (^)(NSDictionary *, NSError *))completionBlock;
-(NSDictionary *)TWEditRequest:(NSDictionary *)params;
-(void)TWEditRequestWithTitle:(NSString*)title andText:(NSString*)text completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;
-(void)TWTranslatedMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;
-(void)TWUntranslatedMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;
-(void)TWTranslationAidsForTitle:(NSString*)title withProject:(NSString*)proj completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;
- (void)TWTranslationReviewRequest:(NSString *)revision completionHandler:(void (^)(BOOL, NSError *))completionBlock;
- (NSString*) TWUserIdRequestOfUserName:(NSString*)userName;
-(void)TWProjectListMaxDepth:(NSInteger)depth completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;

-(void)TWQueryRequestAsync:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;

@property(nonatomic, copy)TWUser* user;
@end
