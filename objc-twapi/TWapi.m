//
//  TWapi.m
//  TWapi
//
//  Created by Or Sagi on 21/12/12 (end of the world).
//  Copyright (c) 2012 Or Sagi. All rights reserved.
//

#import "TWapi.h"

#define SERV_PATH @"https://translatewiki.net/w/api.php"

@implementation TWapi
/*
+(NSMutableDictionary *)TWRequest:(NSDictionary *)params
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: SERV_PATH]];
    
    [request setHTTPMethod:@"POST"];
    [request    addValue:@"json" forHTTPHeaderField:@"format"];
    
    //build URL line with query parameters - taken from requestParams dictionary.
    for( NSString *aKey in params )
    {
        [request addValue:[[params valueForKey:aKey] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forHTTPHeaderField:aKey];

    };
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request
                                                                   delegate:self];
    
    NSLog(@"%@",[request allHTTPHeaderFields]);
    //send request
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
     
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", SERV_PATH, [responseCode statusCode]);
        return 0;
    }
    //parse JSON response
    NSError *jsonParsingError = nil;
    NSMutableDictionary *Data = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonParsingError];
    NSLog(@"%@",Data);
    return Data;
}
 */

+(NSMutableDictionary *)TWRequest:(NSDictionary *)params
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
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: SERV_PATH]];
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval: 15];
    
    NSLog(@"%@\n",request);
    NSLog(@"%@\n",[request allHTTPHeaderFields]);
    //send request
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", post, [responseCode statusCode]);
        return 0;
    }
    //parse JSON response
    NSError *jsonParsingError = nil;
    NSMutableDictionary *Data = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonParsingError];
    NSLog(@"%@\n",Data);
    NSLog(@"%@\n",[responseCode allHeaderFields]);
    
    [[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@", obj);
    }];
    return Data;
}


+(NSMutableDictionary *)TWQueryRequest:(NSDictionary *)params //general query - additional wrap is needed
{
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithDictionary:params];
    [requestParams setObject:@"query" forKey:@"action"];
    return [self TWRequest:requestParams];
}


+(NSString *)TWLoginRequestForUser:(NSString*)username WithPassword:(NSString*) passw
{
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] init];
    //add the login parameters
    [requestParams setObject:username forKey:@"lgname"];
    [requestParams setObject:passw forKey:@"lgpassword"];
    [requestParams setObject:@"login" forKey:@"action"];
    
    NSDictionary * responseData;
    responseData =  [TWapi TWRequest:requestParams]; //get response
    
    id lgid = [responseData objectForKey:@"login"];
    NSString *result = [[NSString alloc] initWithFormat:@"%@",[lgid valueForKey:@"result"]];
    
    if ([result isEqualToString:@"NeedToken"])  //now we have a first response, we need to make a second request with a 'token'
    {
        [requestParams setObject:[lgid valueForKey:@"token"] forKey:@"lgtoken"]; //add the token parameter
        responseData =  [TWapi TWRequest:requestParams];  //second request
        lgid = [responseData objectForKey:@"login"];
        result = [lgid valueForKey:@"result"];
    }
    
    return (result); //return the login result [Success, NotExists, WrongPass...]
}

+(NSDictionary *)TWLogoutRequest
{
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithObjectsAndKeys:nil];
    [requestParams setObject:@"logout" forKey:@"action"];
    return [self TWRequest:requestParams];
}

+(NSDictionary *)TWEditRequest:(NSDictionary *)params
{
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithDictionary:params];
    [requestParams setObject:@"edit" forKey:@"action"];
    return [self TWRequest:requestParams];
}

+(NSMutableDictionary *)TWMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset ByUserId:(NSString *)userId
{
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:nil];
    [requestParams setObject:@"messagecollection" forKey:@"list"];
    [requestParams setObject:proj forKey:@"mcgroup"];
    [requestParams setObject:lang forKey:@"mclanguage"];
    [requestParams setObject:[NSString stringWithFormat:@"%d",limit] forKey:@"mclimit"];
    [requestParams setObject:[NSString stringWithFormat:@"%d",offset] forKey:@"mcoffset"];
    [requestParams setObject:@"definition|translation|revision" forKey:@"mcprop"];
    [requestParams setObject:[NSString stringWithFormat:@"!last-translator:%@|!reviewer:%@|!ignored|translated",userId, userId] forKey:@"mcfilter"];
    
    return [self TWQueryRequest:requestParams];
}


+ (bool)TWTranslationReviewRequest:(NSString *)revision  //accept action
{
    //request for a token
    NSMutableDictionary *tokRequestParams = [NSMutableDictionary alloc];
    tokRequestParams = [tokRequestParams initWithObjectsAndKeys:nil];
    [tokRequestParams setObject:@"tokens" forKey:@"action"];
    [tokRequestParams setObject:@"translationreview" forKey:@"type"];
    NSDictionary * responseData;
    responseData =  [TWapi TWRequest:tokRequestParams];
    
    //here should be verification
    NSMutableString * token = [[NSMutableString alloc] initWithFormat:@"%@",[[responseData objectForKey:@"tokens"] valueForKey:@"translationreviewtoken"]]; //get the token string itself
    //[token appendString:(@"\\")];
   // [token substringToIndex:(token.)]
    //request for the review itself
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithObjectsAndKeys:nil];
    [requestParams setObject:@"translationreview" forKey:@"action"];
    [requestParams setObject:revision forKey:@"revision"];
    [requestParams setObject:token forKey:@"token"];
    
    responseData =  [TWapi TWRequest:requestParams];
    return true;
}

+ (NSString*) TWUserIdRequestOfUserName:(NSString*)userName
{
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:nil];
    [requestParams setObject:@"users" forKey:@"list"];
    [requestParams setObject:userName forKey:@"ususers"];
   
    NSDictionary* result = [self TWQueryRequest:requestParams];
    NSString* resUser;
    if (result)
    {
        
        resUser = [[NSString alloc] initWithString:[[[[result objectForKey:@"query"] objectForKey:@"users"] objectAtIndex:0] objectForKey:@"name"]];
        if ([[resUser lowercaseString] isEqualToString:[userName lowercaseString]])
            return [[result objectForKey:@"users"] objectForKey:@"userid"];
        
    }
    return nil;
}

//TODO add some more wrapper functionalities...

@end