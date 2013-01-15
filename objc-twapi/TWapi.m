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

+(NSDictionary *)TWRequest:(NSDictionary *)params
{
    NSString *URLPath = SERV_PATH;
    NSString *URLComplete = @"";
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithDictionary:params];
    [requestParams setObject:@"json" forKey:@"format"];
    URLComplete = [URLComplete stringByAppendingString:URLPath];
    URLComplete = [URLComplete stringByAppendingString:@"?"];
    
    //build URL line with query parameters - taken from requestParams dictionary.
    for( NSString *aKey in requestParams )
    {
        URLComplete = [URLComplete stringByAppendingString:aKey];
        URLComplete = [URLComplete stringByAppendingString:@"="];
        URLComplete = [URLComplete stringByAppendingString:[[requestParams valueForKey:aKey] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        URLComplete = [URLComplete stringByAppendingString:@"&"];
    };
    
    URLComplete = [URLComplete stringByPaddingToLength:[URLComplete length]-1 withString:0 startingAtIndex:0]; //ommit last '&'
    
    //NSString * escapedURLComplete = [URLComplete stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]; //url encoding
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: URLComplete]];
    
    [request setHTTPMethod:@"POST"];
    
    //send request
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", URLComplete, [responseCode statusCode]);
        return 0;
    }
    
    //parse JSON response
    NSError *jsonParsingError = nil;
    NSDictionary *Data = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonParsingError];
    
    return Data;
}


+(NSDictionary *)TWQueryRequest:(NSDictionary *)params //general query - additional wrap is needed
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

+(NSDictionary *)TWMessagesListRequestForLanguage:(NSString*)lang Project:(NSString*)proj Limitfor:(NSInteger)limit OffsetToStart:(NSInteger)offset ByUserId:(NSString *)userId
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

//TODO add some more wrapper functionalities...

@end