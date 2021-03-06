//
//  BacktrackSDK.h
//  Backtrack-Test
//
//  Created by Ahmet Özışık on 19.04.2015.
//  Copyright (c) 2015 Sailbright. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VERSION @"0.1.0"
#define CLIENT_ID_KEY @"backtrackClientID"
#define CLIENT_SECRET_KEY @"backtrackClientSecret"
#define API_BASE_URL_KEY @"apiBaseURl"
#define BOUNDARIES_KEY @"bt_boundaries"

@interface BacktrackSDK : NSObject

+ (void) setClientID:(NSString*)clientId clientSecret:(NSString*)clientSecret;
+ (void) setBaseURL: (NSString*)baseURL;
+ (void) setMapBoundaries:(CGVector)northSouth westEast:(CGVector)westEast;

+ (NSURL *) baseURL;
+ (NSString *) clientID;
+ (NSString *) clientSecret;
+ (NSString *) errorDomain;
+ (NSInteger) errorCode;
+ (NSString*) language;
+ (NSError *)authenticationErrorForResponse:(NSDictionary *)response;
+ (NSError *)serverErrorForResponse:(NSDictionary *)response;
// Map Boundaries
+ (CGVector)getNorthSouthEnds;
+ (CGVector)getWestEastEnds;
@end
