objc-twapi
==========

objective-C translatewiki API library
currently at a very early stage of development, but it doe's something... 

sorry for the lack of documentation at this stage.
KNOWN BUG: no parameter encooding support (such as: "or sa" --> "or%20sa").

client code examles:

// 1) login example
   
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSDictionary * responseData;

    [parameters setObject:@"orsa" forKey:@"lgname"];          //add user-name field to prameters
    [parameters setObject:@"1234" forKey:@"lgpassword"];      //add password field to parameters
    responseData =  [TWapi TWLoginRequest:parameters];        //get the result parsed from a JSON response

// rerefer to: https://translatewiki.net/wiki/Special:ApiSandbox#action=login&format=json&lgname=orsa&lgpassword=1234


// 2) query example
    [parameters setObject:@"users" forKey:@"list"];
    [parameters setObject:@"blockinfo%7Cgroups%7Cimplicitgroups%7Crights%7Ceditcount%7Cregistration%7Cemailable%7Cgender" forKey:@"usprop"];
    [parameters setObject:@"orsa" forKey:@"ususers"];
    responseData = [TWapi TWQueryRequest:parameters];
