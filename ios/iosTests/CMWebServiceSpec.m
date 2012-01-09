//
//  CMWebServiceSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

#import "NSMutableData+RandomData.h"

#import "CMBlockValidationMessageSpy.h"
#import "CMWebService.h"
#import "CMUserCredentials.h"
#import "CMServerFunction.h"

SPEC_BEGIN(CMWebServiceSpec)

describe(@"CMWebService", ^{
    __block NSString *appId = @"appId123";
    __block NSString *appSecret = @"appSecret123";
    __block CMWebService *service = nil;
    
    beforeEach(^{
        service = [[CMWebService alloc] initWithAPIKey:appSecret appKey:appId];
        service.networkQueue = [ASINetworkQueue mock];
    });
    
    context(@"should construct GET request", ^{
        it(@"JSON URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text", appId]];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"GET"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service getValuesForKeys:nil
                   serverSideFunction:nil
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];
        });
        
        it(@"binary data URLs at the app level correctly", ^{
            NSString *binaryKey = @"filename";
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/binary/%@", appId, binaryKey]];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"GET"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service getBinaryDataNamed:binaryKey
                         successHandler:^(NSData *data) {}
                           errorHandler:^(NSError *error) {}
             ];
        });
        
        it(@"JSON URLs at the app level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text?keys=k1,k2", appId]];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"GET"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service getValuesForKeys:[NSArray arrayWithObjects:@"k1", @"k2", nil]
                   serverSideFunction:nil
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];    
        });
        
        it(@"JSON URLs at the app level with keys and a server-side function call correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text?keys=k1,k2&f=my_func", appId]];
            CMServerFunction *function = [CMServerFunction serverFunctionWithName:@"my_func"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"GET"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service getValuesForKeys:[NSArray arrayWithObjects:@"k1", @"k2", nil]
                   serverSideFunction:function
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];    
        });
        
        it(@"JSON URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text", appId]];
            CMUserCredentials *creds = [[CMUserCredentials alloc] initWithUserId:@"user" andPassword:@"pass"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.username should] equal:@"user"];
                [[request.password should] equal:@"pass"];
                [[request.requestMethod should] equal:@"GET"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service getValuesForKeys:nil
                   serverSideFunction:nil
                  withUserCredentials:creds
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];    
        });
        
        it(@"binary data URLs at the user level correctly", ^{
            NSString *binaryKey = @"filename";
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/binary/%@", appId, binaryKey]];
            CMUserCredentials *creds = [[CMUserCredentials alloc] initWithUserId:@"user" andPassword:@"pass"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.username should] equal:@"user"];
                [[request.password should] equal:@"pass"];
                [[request.requestMethod should] equal:@"GET"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service getBinaryDataNamed:binaryKey
                    withUserCredentials:creds
                         successHandler:^(NSData *data) {}
                           errorHandler:^(NSError *error) {}
             ];
        });
        
        it(@"JSON URLs at the user level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text?keys=k1,k2", appId]];
            CMUserCredentials *creds = [[CMUserCredentials alloc] initWithUserId:@"user" andPassword:@"pass"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.username should] equal:@"user"];
                [[request.password should] equal:@"pass"];
                [[request.requestMethod should] equal:@"GET"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service getValuesForKeys:[NSArray arrayWithObjects:@"k1", @"k2", nil]
                   serverSideFunction:nil
                  withUserCredentials:creds
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];    
        }); 
    });
    
    context(@"should construct POST request", ^{
        it(@"JSON URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"POST"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
                [[[request.postBody yajl_JSON] should] equal:dataToPost];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service updateValuesFromDictionary:dataToPost 
                             serverSideFunction:nil
                                 successHandler:^(NSDictionary *results, NSDictionary *errors) {
                                 } errorHandler:^(NSError *error) {
                                 }
             ];    
        });
        
        it(@"binary data URLs at the app level correctly", ^{
            NSString *binaryKey = @"filename";
            NSData *data = [NSMutableData randomDataWithLength:100];
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/binary/%@", appId, binaryKey]];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"POST"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
                [[[[request requestHeaders] objectForKey:@"Content-Type"] should] equal:@"application/cloudmine"];
                [[request.postBody should] equal:data];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service uploadBinaryData:data
                                named:binaryKey
                           ofMimeType:@"application/cloudmine"
                       successHandler:^(CMFileUploadResult result) {
                       } errorHandler:^(NSError *error) {
                       }
             ];
        });
        
        it(@"JSON URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];
            CMUserCredentials *creds = [[CMUserCredentials alloc] initWithUserId:@"user" andPassword:@"pass"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.username should] equal:@"user"];
                [[request.password should] equal:@"pass"];
                [[request.requestMethod should] equal:@"POST"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
                [[[request.postBody yajl_JSON] should] equal:dataToPost];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service updateValuesFromDictionary:dataToPost
                             serverSideFunction:nil
                            withUserCredentials:creds
                                 successHandler:^(NSDictionary *results, NSDictionary *errors) {
                                 } errorHandler:^(NSError *error) {
                                 }
             ];    
        });
    });
    
    it(@"binary data URLs at the user level correctly", ^{
        NSString *binaryKey = @"filename";
        NSData *data = [NSMutableData randomDataWithLength:100];
        CMUserCredentials *creds = [[CMUserCredentials alloc] initWithUserId:@"user" andPassword:@"pass"];
        NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/binary/%@", appId, binaryKey]];
        
        id spy = [[CMBlockValidationMessageSpy alloc] init];
        [spy addValidationBlock:^(NSInvocation *invocation) {
            ASIHTTPRequest *request = nil;
            [invocation getArgument:&request atIndex:2]; // only arg is the request
            [[request.url should] equal:expectedUrl];
            [[request.requestMethod should] equal:@"POST"];
            [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            [[[[request requestHeaders] objectForKey:@"Content-Type"] should] equal:@"application/cloudmine"];
            [[request.postBody should] equal:data];
            [[request.username should] equal:@"user"];
            [[request.password should] equal:@"pass"];
        } forSelector:@selector(addOperation:)];
        
        // Validate the request when it's pushed onto the network queue so
        // we don't interfere with the construction and use of the request
        // otherwise throughout the production code.
        [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
        
        [[service.networkQueue should] receive:@selector(addOperation:)];
        [[service.networkQueue should] receive:@selector(go)];
        
        [service uploadBinaryData:data
                            named:binaryKey
                       ofMimeType:@"application/cloudmine"
              withUserCredentials:creds
                   successHandler:^(CMFileUploadResult result) {
                   } errorHandler:^(NSError *error) {
                   }
         ];
    });
    
    context(@"should construct PUT request", ^{
        it(@"JSON URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"PUT"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
                [[[request.postBody yajl_JSON] should] equal:dataToPost];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service setValuesFromDictionary:dataToPost 
                          serverSideFunction:nil
                                 successHandler:^(NSDictionary *results, NSDictionary *errors) {
                                 } errorHandler:^(NSError *error) {
                                 }
             ];    
        });
        
        it(@"JSON URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];
            CMUserCredentials *creds = [[CMUserCredentials alloc] initWithUserId:@"user" andPassword:@"pass"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.username should] equal:@"user"];
                [[request.password should] equal:@"pass"];
                [[request.requestMethod should] equal:@"PUT"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
                [[[request.postBody yajl_JSON] should] equal:dataToPost];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service setValuesFromDictionary:dataToPost
                          serverSideFunction:nil
                            withUserCredentials:creds
                                 successHandler:^(NSDictionary *results, NSDictionary *errors) {
                                 } errorHandler:^(NSError *error) {
                                 }
             ];    
        });
    });
    
    context(@"should construct DELETE request", ^{
        it(@"JSON URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/data", appId]];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"DELETE"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service deleteValuesForKeys:nil
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];
        });
        
        it(@"JSON URLs at the app level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/data?keys=k1,k2", appId]];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"DELETE"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service deleteValuesForKeys:[NSArray arrayWithObjects:@"k1", @"k2", nil]
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];    
        });
        
        it(@"JSON URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/data", appId]];
            CMUserCredentials *creds = [[CMUserCredentials alloc] initWithUserId:@"user" andPassword:@"pass"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.username should] equal:@"user"];
                [[request.password should] equal:@"pass"];
                [[request.requestMethod should] equal:@"DELETE"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service deleteValuesForKeys:nil
                  withUserCredentials:creds
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];    
        });
        
        it(@"JSON URLs at the user level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/data?keys=k1,k2", appId]];
            CMUserCredentials *creds = [[CMUserCredentials alloc] initWithUserId:@"user" andPassword:@"pass"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.username should] equal:@"user"];
                [[request.password should] equal:@"pass"];
                [[request.requestMethod should] equal:@"DELETE"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service deleteValuesForKeys:[NSArray arrayWithObjects:@"k1", @"k2", nil]
                  withUserCredentials:creds
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];    
        }); 
    });

});

SPEC_END

