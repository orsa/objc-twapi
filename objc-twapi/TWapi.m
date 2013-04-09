//
//  TWapi.m
//  TWapi
//
//  Created by Or Sagi on 21/12/12 (end of the world).
//  Copyright (c) 2012 Or Sagi. All rights reserved.
//

#import "TWapi.h"

@implementation TWapi


-(id) initForUser:(TWUser*) linkedUser
{
    self = [super init];
    if (self) {
        _user  = linkedUser;
        return self;
    }
    return nil;
}

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


-(NSMutableDictionary *)TWQueryRequest:(NSDictionary *)params //general query - additional wrap is needed
{
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithDictionary:params];
    [requestParams setObject:@"query" forKey:@"action"];
    return [self TWRequest:requestParams];
}


-(NSString *)TWLoginRequestWithPassword:(NSString*) passw
{
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] init];
    //add the login parameters
    [requestParams setObject:_user.userName forKey:@"lgname"];
    [requestParams setObject:passw forKey:@"lgpassword"];
    [requestParams setObject:@"login" forKey:@"action"];
    
    NSDictionary * responseData;
    responseData =  [self TWRequest:requestParams]; //get response
    
    NSDictionary* lgid = responseData[@"login"];
    NSString *result = [[NSString alloc] initWithFormat:@"%@",[lgid valueForKey:@"result"]];
    
    if ([result isEqualToString:@"NeedToken"])  //now we have a first response, we need to make a second request with a 'token'
    {
        [requestParams setObject:[lgid valueForKey:@"token"] forKey:@"lgtoken"]; //add the token parameter
        responseData =  [self TWRequest:requestParams];  //second request
        lgid = responseData[@"login"];
        result = lgid[@"result"];
    }
    if([result isEqualToString:@"Success"])
    {
        _user.isLoggedin = YES;
        _user.userId = [(NSNumber*)lgid[@"lguserid"] stringValue];
    }
    return (result); //return the login result [Success, NotExists, WrongPass...]
}

-(NSDictionary *)TWLogoutRequest
{
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithObjectsAndKeys:nil];
    [requestParams setObject:@"logout" forKey:@"action"];
    return [self TWRequest:requestParams];
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

-(bool)TWEditRequestWithTitle:(NSString*)title andText:(NSString*)text
{
    //request for a token
    NSMutableDictionary *tokRequestParams = [NSMutableDictionary alloc];
    tokRequestParams = [tokRequestParams initWithObjectsAndKeys:nil];
    tokRequestParams[@"intoken"]=@"edit";
    tokRequestParams[@"titles"]=title;
    tokRequestParams[@"prop"]=@"info";
    NSDictionary * responseData;
    responseData =  [self TWQueryRequest:tokRequestParams];

    //here should be verification
    NSArray* listOfPages=[responseData[@"query"][@"pages"] allValues];
    NSMutableString * token = [NSMutableString stringWithString:listOfPages[0][@"edittoken"]]; //get the token string itself
    
    //request for the review itself
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithObjectsAndKeys:nil];
    requestParams[@"action"]=@"edit";
    requestParams[@"title"]=title;
    requestParams[@"text"]=text;
    requestParams[@"token"]=token;
    
    responseData =  [self TWRequest:requestParams];
    
    return (!responseData[@"error"] && !responseData[@"warnings"]);
}

-(NSMutableDictionary *)TWMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset filter:(NSString*)filter
{
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:nil];
    [requestParams setObject:@"messagecollection" forKey:@"list"];
    [requestParams setObject:proj forKey:@"mcgroup"];
    [requestParams setObject:lang forKey:@"mclanguage"];
    [requestParams setObject:[NSString stringWithFormat:@"%d",limit] forKey:@"mclimit"];
    [requestParams setObject:[NSString stringWithFormat:@"%d",offset] forKey:@"mcoffset"];
    [requestParams setObject:@"definition|translation|revision|properties" forKey:@"mcprop"];
    [requestParams setObject:filter forKey:@"mcfilter"];
    
    return [self TWQueryRequest:requestParams];
}

-(NSMutableDictionary *)TWTranslatedMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset
{
    NSString* mcfilter=[NSString stringWithFormat:@"!last-translator:%@|!reviewer:%@|!ignored|translated",_user.userId, _user.userId];
    return [self TWMessagesListRequestForLanguage:lang Project:proj Limitfor:limit OffsetToStart:offset filter:mcfilter];
}

-(NSMutableDictionary *)TWUntranslatedMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset
{
    NSString* mcfilter=@"!ignored|!translated|!fuzzy";
    return [self TWMessagesListRequestForLanguage:lang Project:proj Limitfor:limit OffsetToStart:offset filter:mcfilter];
}

-(NSMutableDictionary*)TWTranslationAidsForTitle:(NSString*)title withProject:(NSString*)proj
{
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:nil];
    requestParams[@"action"]=@"translationaids";
    requestParams[@"title"]=title;
    requestParams[@"group"]=proj;
    
    return [self TWRequest:requestParams][@"helpers"];
}

- (bool)TWTranslationReviewRequest:(NSString *)revision  //accept action
{
    //request for a token
    NSMutableDictionary *tokRequestParams = [NSMutableDictionary alloc];
    tokRequestParams = [tokRequestParams initWithObjectsAndKeys:nil];
    [tokRequestParams setObject:@"tokens" forKey:@"action"];
    [tokRequestParams setObject:@"translationreview" forKey:@"type"];
    NSDictionary * responseData;
    responseData =  [self TWRequest:tokRequestParams];
    
    //here should be verification
    NSMutableString * token = [[NSMutableString alloc] initWithFormat:@"%@",[responseData[@"tokens"] valueForKey:@"translationreviewtoken"]]; //get the token string itself
    
    //request for the review itself
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithObjectsAndKeys:nil];
    [requestParams setObject:@"translationreview" forKey:@"action"];
    [requestParams setObject:revision forKey:@"revision"];
    [requestParams setObject:token forKey:@"token"];
    
    responseData =  [self TWRequest:requestParams];
    
    return (!responseData[@"error"] && !responseData[@"warnings"]);
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

-(NSArray *)TWProjectListMaxDepth:(NSInteger)depth
{
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:nil];
    [requestParams setObject:@"messagegroups" forKey:@"meta"];
    [requestParams setObject:[NSString stringWithFormat:@"%d",depth] forKey:@"mgdepth"];
    [requestParams setObject:@"tree" forKey:@"mgformat"];
    [requestParams setObject:@"id|label" forKey:@"mgprop"];
    
    return [self TWQueryRequest:requestParams][@"query"][@"messagegroups"];
}

//TODO add some more wrapper functionalities...

@end