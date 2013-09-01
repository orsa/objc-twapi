//
//  TWapi.h
//  TWapi
//
//  Created by Or Sagi on 21/12/12.
//
//  Copyright 2013 Or Sagi, Tomer Tuchner
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <Foundation/Foundation.h>
#import "TWUser.h"

#define SERV_PATH @"https://translatewiki.net/w/api.php"
#define HOST @"https://translatewiki.net"

//DEBUG purpose
#define LOG(X) NSLog(@"%@\n",X)

@interface TWapi : NSObject

@property(nonatomic, copy)TWUser* user;
@property(nonatomic) dispatch_queue_t queue;

//synchronous version methods
-(NSMutableDictionary *)TWRequest:(NSDictionary *)params;
-(NSMutableDictionary *)TWQueryRequest:(NSDictionary *)params;
-(NSDictionary *)TWEditRequest:(NSDictionary *)params;
-(id) initForUser:(TWUser*) linkedUser;
-(void)TWPerformRequestWithParams:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;
-(void)TWLoginRequestWithPassword:(NSString*) passw completionHandler:(void (^)(NSString *, NSError *))completionBlock;
-(void)TWLoginRequestWithPassword:(NSString*) passw isMainThreadBlocked:(BOOL)isBlocked completionHandler:(void (^)(NSString *, NSError *))completionBlock;
-(void)TWLogoutRequest:(void (^)(NSDictionary *, NSError *))completionBlock;
-(void)TWEditRequestWithTitle:(NSString*)title andText:(NSString*)text completionHandler:(void (^)(NSError *, NSDictionary*))completionBlock;
-(void)TWTranslatedMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;
-(void)TWUntranslatedMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;
-(void)TWTranslationAidsForTitle:(NSString*)title withProject:(NSString*)proj completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;
-(void)TWTranslationReviewRequest:(NSString *)revision completionHandler:(void (^)(NSError *, NSDictionary*))completionBlock;
-(void)TWProjectListMaxDepth:(NSInteger)depth completionHandler:(void (^)(NSArray *, NSError *))completionBlock;
-(void)TWQueryRequestAsync:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;
- (NSString*)TWUserIdRequestOfUserName:(NSString*)userName;

@end
