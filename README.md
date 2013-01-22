objc-twapi
==========

objective-C translatewiki API wrapper library
currently at a very early stage of development, but it doe's something... 

sorry for the lack of documentation at this stage.
A listing of the API wrapper methods and their contract/decription will be added here soon.

please give us your feedback.

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
