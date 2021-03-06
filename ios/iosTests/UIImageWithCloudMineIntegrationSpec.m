//
//  UIImageWithCloudMineIntegrationSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/11/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "CMStore.h"
#import "CMAPICredentials.h"
#import "UIImageView+CloudMine.h"
#import "CMWebService.h"

SPEC_BEGIN(UIImageWithCloudMineIntegrationSpec)

describe(@"UIImageWithCloudMineIntegrationSpec", ^{
    
    __block CMStore *store = nil;
    __block NSString *key = nil;
    __block UIImage *image = nil;
    
    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppIdentifier:@"9977f87e6ae54815b32a663902c3ca65"
                                                     apiKey:@"c701d73554594315948c8d3cc0711ac1"
                                                 andBaseURL:nil];
        
        [[CMStore defaultStore] setWebService:[[CMWebService alloc] init]];
        store = [CMStore store];
        
        //send image to CloudMine
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"cloudmine" ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:path];
        
        __block CMFileUploadResponse *resp = nil;
        [store saveFileWithData:UIImagePNGRepresentation(image) additionalOptions:nil callback:^(CMFileUploadResponse *response) {
            resp = response;
            key = resp.key;
            NSLog(@"Key? %@", key);
        }];
        
        [[expectFutureValue(resp) shouldEventually] beNonNil];
        [[expectFutureValue(theValue(resp.result)) shouldEventually] equal:theValue(CMFileCreated)];
        [[expectFutureValue(key) shouldEventually] beNonNil];
        
        __block CMFileUploadResponse *resp2 = nil;
        [store saveFileWithData:UIImagePNGRepresentation(image) named:@"second" additionalOptions:nil callback:^(CMFileUploadResponse *response) {
            resp2 = response;
        }];
        [[expectFutureValue(resp2) shouldEventually] beNonNil];
    });
    
    it(@"should be able to set the image to a UIImageView with just the key", ^{
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [imageView setImageWithFileKey:key];
        [[expectFutureValue(UIImagePNGRepresentation(imageView.image)) shouldEventually] equal:UIImagePNGRepresentation(image)];
    });
    
    it(@"should immediatly set a placeholder iamge", ^{
        //send image to CloudMine
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"mobile" ofType:@"png"];
        UIImage *placeholder = [UIImage imageWithContentsOfFile:path];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [imageView setImageWithFileKey:@"second" placeholderImage:placeholder];
        [[imageView.image shouldNot] beNil];
        [[UIImagePNGRepresentation(imageView.image) should] equal:UIImagePNGRepresentation(placeholder)];
        [[expectFutureValue(UIImagePNGRepresentation(imageView.image)) shouldEventually] equal:UIImagePNGRepresentation(image)];
    });
    
    it(@"should cache the image we retrived and use it immediatly", ^{
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [imageView setImageWithFileKey:key];
        [[UIImagePNGRepresentation(imageView.image) should] equal:UIImagePNGRepresentation(image)];
    });
    
    it(@"should search a user's files if passed a user", ^{
        
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"cloudmine" ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:path];
        
        __block CMFileUploadResponse *resp = nil;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        
        CMUser *user = [[CMUser alloc] initWithEmail:@"testUserImage@test.com" andPassword:@"testing"];
        [user createAccountAndLoginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
            
            [[CMStore defaultStore] setUser:user];
            [[CMStore defaultStore] saveUserFileWithData:UIImagePNGRepresentation(image) additionalOptions:nil callback:^(CMFileUploadResponse *response) {
                resp = response;
                key = resp.key;
                [imageView setImageWithFileKey:key placeholderImage:nil user:user];
            }];
        }];
        
        [[expectFutureValue(UIImagePNGRepresentation(imageView.image)) shouldEventuallyBeforeTimingOutAfter(5.0)] equal:UIImagePNGRepresentation(image)];
    });
    
});

SPEC_END