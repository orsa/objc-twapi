//
//  TWapi.m
//  TWapi
//
//  Created by Or Sagi on 21/12/12 (end of the world).
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
//
//*********************************************************************************
// This is an API wrapper implementation for: https://translatewiki.net/w/api.php
// Refer to: https://github.com/orsa/objc-twapi .
//*********************************************************************************
//

#import "TWapi.h"

@implementation TWapi

-(id) initForUser:(TWUser*) linkedUser
{
    self = [super init];
    if (self) {
        _user  = linkedUser;
        _queue=dispatch_queue_create("com.api.apiqueue", NULL);
        return self;
    }
    return nil;
}

//*********************************************************************************
//Asynchronous general request - this is the sole method which "speaks" to the API server.
//It does:
// a) prepare an HTTP request out of the given parameters;
// b) create a connection with the API server, send the request and receive its response;
// c) handle respose: invokes hanler, inform on error, parse JSON, and send it to the given completionBlock
//*********************************************************************************
-(void)TWPerformRequestWithParams:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock
{
    [self TWPerformRequestWithParams:params isMainThreadBlocked:NO completionHandler:completionBlock];
}

-(void)TWPerformRequestWithParams:(NSDictionary *)params isMainThreadBlocked:(BOOL)isBlocked completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock
{
    NSString *post = @"";
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithDictionary:params];
    [requestParams setObject:@"json" forKey:@"format"];
    dispatch_queue_t used_q=isBlocked ? _queue : dispatch_get_main_queue();
    
    //build URL line with query parameters - taken from requestParams dictionary.
    for( NSString *aKey in requestParams )
    {
        post = [post stringByAppendingString:aKey];
        post = [post stringByAppendingString:@"="];
        post = [post stringByAppendingString:[requestParams valueForKey:aKey]];
        post = [post stringByAppendingString:@"&"];
    };
    
    post = [post stringByPaddingToLength:[post length]-1 withString:0 startingAtIndex:0]; //ommit last '&'
    post = [[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]; //handles the odd plus(+) encoding for tokenks that passed to api server
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // Create the request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: SERV_PATH]];
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval: 15];
    [request setHTTPShouldHandleCookies:YES];
    
    // Make an NSOperationQueue
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        //[queue setName:@"com.your.unique.queue.name"];
    
    // Send an asyncronous request on the queue
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // If there was an error getting the data
        if (error)
        {
            /*dispatch_async(dispatch_get_main_queue(), ^(void) {
                completionBlock(nil, error);
            });*/
            dispatch_async(used_q, ^(void) {
                completionBlock(nil, error);
            });
            return;
        }
        
        // Decode the data
        NSError *jsonError;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        // If there was an error decoding the JSON
        if (jsonError)
        {
            dispatch_async(used_q, ^(void) {
                NSLog(@"JSON error");
                completionBlock(nil, error);
            });
            return;
        }
        
        //call completion handler
        dispatch_async(used_q, ^(void) {
            completionBlock(responseDict, nil);
        });
    }];
}


//general query - additional wrap is needed
-(void)TWQueryRequestAsync:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock
{
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithDictionary:params];
    [requestParams setObject:@"query" forKey:@"action"];
    [self TWPerformRequestWithParams:requestParams completionHandler:completionBlock];
}

//*********************************************************************************
//Login Request - this method handles login request by two steps
// 1)requests token
// 2)validate this token - login approval
//*********************************************************************************

-(void)TWLoginRequestWithPassword:(NSString*) passw completionHandler:(void (^)(NSString *, NSError *))completionBlock
{
    [self TWLoginRequestWithPassword:passw isMainThreadBlocked:NO completionHandler:completionBlock];
}

-(void)TWLoginRequestWithPassword:(NSString*) passw isMainThreadBlocked:(BOOL)isBlocked completionHandler:(void (^)(NSString *, NSError *))completionBlock
{
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] init];
    //add the login parameters
    requestParams[@"lgname"]=_user.userName;
    requestParams[@"lgpassword"]=passw;
    requestParams[@"action"]=@"login";
    dispatch_queue_t used_q=isBlocked ? _queue : dispatch_get_main_queue();
    
    [self TWPerformRequestWithParams:requestParams isMainThreadBlocked:isBlocked completionHandler:^(NSDictionary* responseData, NSError* error){
        if(!error){
            NSDictionary* lgid = responseData[@"login"];
            NSString *result = [[NSString alloc] initWithFormat:@"%@",[lgid valueForKey:@"result"]];
        
            if ([result isEqualToString:@"NeedToken"])  //now we have a first response, we need to make a second request with a 'token'
            {
                [requestParams setObject:[lgid valueForKey:@"token"] forKey:@"lgtoken"]; //add the token parameter
                [self TWPerformRequestWithParams:requestParams isMainThreadBlocked:isBlocked completionHandler:^(NSDictionary* responseData, NSError* error){
                    if(!error){
                        NSDictionary* lgid = responseData[@"login"];
                        NSString* result = lgid[@"result"];
                        if([result isEqualToString:@"Success"])
                        {
                            _user.isLoggedin = YES;
                            _user.userId = [(NSNumber*)lgid[@"lguserid"] stringValue];
                        }
                        //call completion handler after success
                        dispatch_async(used_q, ^(void) {
                            completionBlock(result, error);
                        });
                    }
                    else{
                        //call completion handler with error
                        dispatch_async(used_q, ^(void) {
                            completionBlock(nil, error);
                        });
                    }
                }];  //second request
            }
        }
        else
        {
            //call completion handler with error
            dispatch_async(used_q, ^(void) {
                completionBlock(nil, error);
            });
        }
    }];
}

//*********************************************************************************
//Logout Request - this method handles logout.
//*********************************************************************************
-(void)TWLogoutRequest:(void (^)(NSDictionary *, NSError *))completionBlock
{
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithObjectsAndKeys:nil];
    [requestParams setObject:@"logout" forKey:@"action"];
    [self TWPerformRequestWithParams:requestParams completionHandler:completionBlock];
}

//*********************************************************************************
//Edit Request - this method handles edits, e.g translasions of messages.
//*********************************************************************************
-(void)TWEditRequestWithTitle:(NSString*)title andText:(NSString*)text completionHandler:(void (^)(BOOL, NSError *))completionBlock
{
    //request for a token
    NSMutableDictionary *tokRequestParams = [NSMutableDictionary alloc];
    tokRequestParams = [tokRequestParams initWithObjectsAndKeys:nil];
    tokRequestParams[@"action"]=@"tokens";
    tokRequestParams[@"type"]=@"edit";
    [self TWPerformRequestWithParams:tokRequestParams completionHandler:^(NSDictionary* responseData, NSError* error){
        //here should be verification
        NSMutableString * token = responseData[@"tokens"][@"edittoken"];//edit token
        
        //request for the review itself
        NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
        requestParams = [requestParams initWithObjectsAndKeys:nil];
        requestParams[@"action"]=@"edit";
        requestParams[@"title"]=title;
        requestParams[@"text"]=text;
        requestParams[@"token"]=token;
        
        [self TWPerformRequestWithParams:requestParams completionHandler:^(NSDictionary* responseData, NSError* error){
            //call the handler
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                completionBlock((!responseData[@"error"] && !responseData[@"warnings"]), error);
            });
        }];
    }];
}

-(void)TWMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset filter:(NSString*)filter completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock
{
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:nil];
    [requestParams setObject:@"messagecollection" forKey:@"list"];
    [requestParams setObject:proj forKey:@"mcgroup"];
    [requestParams setObject:lang forKey:@"mclanguage"];
    [requestParams setObject:[NSString stringWithFormat:@"%d",limit] forKey:@"mclimit"];
    [requestParams setObject:[NSString stringWithFormat:@"%d",offset] forKey:@"mcoffset"];
    [requestParams setObject:@"definition|translation|revision|properties" forKey:@"mcprop"];
    [requestParams setObject:filter forKey:@"mcfilter"];
    
    [self TWQueryRequestAsync:requestParams completionHandler:completionBlock];
}

-(void)TWTranslatedMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock
{
    NSString* mcfilter=[NSString stringWithFormat:@"!last-translator:%@|!reviewer:%@|!ignored|translated",_user.userId, _user.userId];
    [self TWMessagesListRequestForLanguage:lang Project:proj Limitfor:limit OffsetToStart:offset filter:mcfilter completionHandler:completionBlock];
}

-(void)TWUntranslatedMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock
{
    NSString* mcfilter=@"!ignored|!translated|!fuzzy";
    [self TWMessagesListRequestForLanguage:lang Project:proj Limitfor:limit OffsetToStart:offset filter:mcfilter completionHandler:completionBlock];
}

-(void)TWTranslationAidsForTitle:(NSString*)title withProject:(NSString*)proj completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock
{
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:nil];
    requestParams[@"action"]=@"translationaids";
    requestParams[@"title"]=title;
    requestParams[@"group"]=proj;
    
    [self TWPerformRequestWithParams:requestParams completionHandler:completionBlock];
    
    //return [self TWRequest:requestParams][@"helpers"];
}

//*********************************************************************************
//Translation Review Request - this method handles message translasion acceptance.
//*********************************************************************************
- (void)TWTranslationReviewRequest:(NSString *)revision completionHandler:(void (^)(BOOL, NSError *))completionBlock
{
    //request for a token
    NSMutableDictionary *tokRequestParams = [NSMutableDictionary alloc];
    tokRequestParams = [tokRequestParams initWithObjectsAndKeys:nil];
    [tokRequestParams setObject:@"tokens" forKey:@"action"];
    [tokRequestParams setObject:@"translationreview" forKey:@"type"];
    [self TWPerformRequestWithParams:tokRequestParams completionHandler:^(NSDictionary* responseData, NSError* error){
        //here should be verification
        NSMutableString * token = [[NSMutableString alloc] initWithFormat:@"%@",[responseData[@"tokens"] valueForKey:@"translationreviewtoken"]]; //get the token string itself
        
        //request for the review itself
        NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
        requestParams = [requestParams initWithObjectsAndKeys:nil];
        [requestParams setObject:@"translationreview" forKey:@"action"];
        [requestParams setObject:revision forKey:@"revision"];
        [requestParams setObject:token forKey:@"token"];
        
        [self TWPerformRequestWithParams:requestParams completionHandler:^(NSDictionary* responseData, NSError* error){
            
            //call the handler
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                completionBlock((!responseData[@"error"] && !responseData[@"warnings"]), error);
            });
        }];
    }];
}

//*********************************************************************************
//This method retreives project list & details from server.
//*********************************************************************************
-(void)TWProjectListMaxDepth:(NSInteger)depth completionHandler:(void (^)(NSArray *, NSError *))completionBlock
{
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:nil];
    [requestParams setObject:@"messagegroups" forKey:@"meta"];
    [requestParams setObject:[NSString stringWithFormat:@"%d",depth] forKey:@"mgdepth"];
    [requestParams setObject:@"tree" forKey:@"mgformat"];
    [requestParams setObject:@"id|label" forKey:@"mgprop"];
    
    [self TWQueryRequestAsync:requestParams completionHandler:^(NSDictionary* responseData, NSError* error){
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            completionBlock(responseData[@"query"][@"messagegroups"], error);
        });
    }];
}

//TODO add some more wrapper functionalities...



#pragma mark - deprecated methods
//synchronous version methods

-(NSMutableDictionary *)TWRequest:(NSDictionary *)params
{
    NSString *post = @"";
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithDictionary:params];
    [requestParams setObject:@"json" forKey:@"format"];
    
    //build URL line with query parameters - taken from requestParams dictionary.
    for( NSString *aKey in requestParams )
    {
        post = [post stringByAppendingString:aKey];
        post = [post stringByAppendingString:@"="];
        post = [post stringByAppendingString:[requestParams valueForKey:aKey]];
        post = [post stringByAppendingString:@"&"];
    };
    
    post = [post stringByPaddingToLength:[post length]-1 withString:0 startingAtIndex:0]; //ommit last '&'
    post = [[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]; //handles the odd plus(+) encoding for tokenks that passed to api server
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: SERV_PATH]];
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval: 15];
    
    //LOG(request);
    //LOG([request allHTTPHeaderFields]);
    //LOG(postData);
    
    //send request
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    [request setHTTPShouldHandleCookies:YES];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    //_user.authCookie = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[request URL]][0];
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", post, [responseCode statusCode]);
        return 0;
    }
    //parse JSON response
    NSError *jsonParsingError = nil;
    NSMutableDictionary *Data = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonParsingError];
    //LOG(Data);
    //LOG([responseCode allHeaderFields]);
    
    //DEBUG: showing cookies
    //[[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){LOG(obj);}];
    return Data;
}

-(NSDictionary *)TWEditRequest:(NSDictionary *)params
{
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithDictionary:params];
    [requestParams setObject:@"edit" forKey:@"action"];
    NSDictionary * result = [self TWRequest:requestParams];
    self.user.isLoggedin = NO;
    return result;
}

-(NSMutableDictionary*)TWQueryRequest:(NSDictionary *)params
{
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithDictionary:params];
    [requestParams setObject:@"query" forKey:@"action"];
    return [self TWRequest:requestParams];
}

- (NSString*) TWUserIdRequestOfUserName:(NSString*)userName
{
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:nil];
    [requestParams setObject:@"users" forKey:@"list"];
    [requestParams setObject:userName forKey:@"ususers"];
    
    NSDictionary* result = [self TWQueryRequest:requestParams];
    NSString* resUser;
    if (result)
    {
        
        resUser = [[NSString alloc] initWithString:result[@"query"][@"users"][0][@"name"]];
        if ([[resUser lowercaseString] isEqualToString:[userName lowercaseString]])
            return result [@"users"][@"userid"];
        
    }
    return nil;
}

@end