//
//  TWUser.m
//  TWapi
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
// TWUser - contains information about the logged in user
//*********************************************************************************

#import "TWUser.h"

@implementation TWUser

@synthesize userName, userId, isLoggedin;

-(id) init{
    self = [super init];
    if (self) {
        userName=@"";
        isLoggedin=NO;
        if (!userId)
            userId=@"";
        return self;
    }
    return nil;
}

@end
