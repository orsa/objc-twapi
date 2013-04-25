objc-twapi
==========

objective-C translatewiki API wrapper library
currently at a very early stage of development, but it doe's something... 

sorry for the lack of documentation at this stage.
A listing of the API wrapper methods and their contract/decription will be added here soon.

please give us your feedback.

Copyright 2013 Or Sagi, Tomer Tuchner

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

------------------
Usage examples :


// 1) login example
   
    NSString *nameString = self.userName;  //username parameter
    NSString *passwString = self.password; //password parameter

    self.ResultLabel.text = [TWapi TWLoginRequestForUser:nameString WithPassword:passwString]; //login via API wrapper


// 2) query example
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"users" forKey:@"list"];
    [parameters setObject:@"blockinfo|groups|implicitgroups|rights|editcount|registration|emailable|gender" forKey:@"usprop"];
    [parameters setObject:@"orsa" forKey:@"ususers"];
    // we prepared a Dictionary with "list","usprop" and "ususers" parameters
    responseData = [TWapi TWQueryRequest:parameters]; //call a query request via API wrapper

// for a detailed API specification rerefer to: https://translatewiki.net/w/api.php


