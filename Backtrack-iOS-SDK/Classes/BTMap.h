//
//  BTMap.h
//  Pods
//
//  Created by Ahmet Özışık on 28.04.2015.
//
//
#import <Mapbox-iOS-SDK/Mapbox.h>
#import "BTDatabase.h"

@class BTMap;

@protocol BTMapDelegate
-(void)goToPointOfInterest:(NSString*)ID;
@end

@interface BTMap : NSObject <RMMapViewDelegate>
{
    NSMutableDictionary* loadedAnnotations;
    NSString* lastLoadedTrip;
    
    NSArray *waypoints;
}

@property(nonatomic, retain) RMMapView* mapView;
// define delegate property
@property (nonatomic, assign) id delegate;

-(id)initWithOfflineMap:(NSString*)mapFile onView:(UIView*)mapContainer;
-(void)loadInterestingPoints;
-(void)reloadMapAnnotations:(NSDictionary*)trip;

-(void)focusOnPointWithId:(NSString *)ID withZoomLevel:(int)zoom;
-(void)showTrip:(NSDictionary*)trip;

-(BOOL)focusOnPointIfPossible:(CLLocation*)location;
-(void)showUserLocation:(CLLocation*)location andFocus:(BOOL)focus;

@end