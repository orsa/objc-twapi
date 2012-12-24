//
//  TWapi.m
//  TWapi
//
//  Created by Or Sagi on 21/12/12 (end of the world).
//  Copyright (c) 2012 Or Sagi. All rights reserved.
//

#import "TWapi.h"

@implementation TWapi

+(NSDictionary *)TWRequest:(NSDictionary *)params
{
    NSString *URLPath = @"http://translatewiki.net/w/api.php";
    NSString *URLComplete = @"";
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithDictionary:params];
    [requestParams setObject:@"json" forKey:@"format"];
    URLComplete = [URLComplete stringByAppendingString:URLPath];
    URLComplete = [URLComplete stringByAppendingString:@"?"];
   
    for( NSString *aKey in requestParams )
    {
        //TODO: add encoding check
        URLComplete = [URLComplete stringByAppendingString:aKey];
        URLComplete = [URLComplete stringByAppendingString:@"="];
        URLComplete = [URLComplete stringByAppendingString:[requestParams valueForKey:aKey]];
        URLComplete = [URLComplete stringByAppendingString:@"&"];
    };
    URLComplete = [URLComplete stringByPaddingToLength:[URLComplete length]-1 withString:0 startingAtIndex:0];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLComplete]];

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


+(NSDictionary *)TWQueryRequest:(NSDictionary *)params
{
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithDictionary:params];
    [requestParams setObject:@"query" forKey:@"action"];
    return [self TWRequest:requestParams];
}

+(NSDictionary *)TWLoginRequest:(NSDictionary *)params
{
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithDictionary:params];
    [requestParams setObject:@"login" forKey:@"action"];
    return [self TWRequest:requestParams];
}

+(NSDictionary *)TWLogoutRequest:(NSDictionary *)params
{
    NSMutableDictionary *requestParams = [NSMutableDictionary alloc];
    requestParams = [requestParams initWithDictionary:params];
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



@end