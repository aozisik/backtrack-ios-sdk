//
//  BTMap.m
//  Pods
//
//  Created by Ahmet Özışık on 28.04.2015.
//
//
#import "BTMap.h"

@implementation BTMap
@synthesize mapView, delegate;

-(id)init {
    // no need for an access token, we are completely offline
    [[RMConfiguration sharedInstance] setAccessToken:@"<random string>"];
    loadedAnnotations = [[NSMutableDictionary alloc] init];
    
    return [super init];
}

-(id)initWithOfflineMap:(NSString*)mapFile onView:(UIView*)mapContainer {
    self = [self init];
    
    RMMBTilesSource* mapResource = [[RMMBTilesSource alloc] initWithTileSetResource:mapFile ofType:@"mbtiles"];
    
    mapView = [[RMMapView alloc] initWithFrame:mapContainer.frame andTilesource:mapResource];
    // support for retina displays
    mapView.adjustTilesForRetinaDisplay = YES;
    // show mapView on the container provided
    [mapContainer addSubview:mapView];
    // user tracking mode is none by default
    mapView.userTrackingMode = RMUserTrackingModeNone;
    // set auto-resizing mask
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    mapView.delegate = self;
    
    [self loadInterestingPoints];
    return self;
}

-(void)loadInterestingPoints {
    
    dispatch_async(dispatch_get_main_queue(), ^{

        NSArray* results = [[BTDatabase singleton] allPointsOfInterest];
        NSMutableDictionary* annotations = [[NSMutableDictionary alloc] init];
        
        for(NSDictionary *point in results) {
            
            CLLocationDegrees latitude = [point[@"latitude"] doubleValue];
            CLLocationDegrees longitude = [point[@"longitude"] doubleValue];
            
            RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:mapView coordinate:CLLocationCoordinate2DMake(latitude, longitude) andTitle:point[@"name"]];
            annotation.userInfo = point;
            
            [annotations setObject:annotation forKey:point[@"id"]];
            [mapView addAnnotation:annotation];
        }
        
        [loadedAnnotations addEntriesFromDictionary:annotations];
    });
}

- (RMMapLayer *)mapView:(RMMapView *)map_view layerForAnnotation:(RMAnnotation *)annotation {
    
    if([annotation.userInfo objectForKey:@"waypoints"] != nil) {

        RMShape *shape = [[RMShape alloc] initWithView:mapView];
        
        shape.lineColor = [UIColor redColor];
        shape.lineWidth = 5.0;
        
        for (CLLocation *location in annotation.userInfo[@"waypoints"])
            [shape addLineToCoordinate:location.coordinate];
        
        return shape;
    }
    
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"MakiBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *iconPath = [bundle pathForResource:(annotation.userInfo[@"icon"] != nil) ? annotation.userInfo[@"icon"] : @"circle" ofType:@"png"];
    UIImage *icon = [UIImage imageWithContentsOfFile:iconPath];

    RMMarker* marker = [[RMMarker alloc] initWithUIImage:icon];
    marker.canShowCallout = YES;

    UIButton* rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [rightButton setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    marker.rightCalloutAccessoryView = rightButton;
    
    return marker;
}

-(void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map {
    if([self.delegate respondsToSelector:@selector(goToPointOfInterest:)]) {
        [delegate goToPointOfInterest:annotation.userInfo[@"id"]];
    }
}

-(void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    NSLog(@"test");
}

-(void)test {
    NSLog(@"label");
}

#pragma mark public calls
-(void)focusOnPointWithId:(NSString *)ID withZoomLevel:(int)zoom {

    if(loadedAnnotations == nil || [loadedAnnotations objectForKey:ID] == nil) {
        return;
    }
    
    RMAnnotation* targetAnnotation = (RMAnnotation*)[loadedAnnotations objectForKey:ID];
    
    [self.mapView setZoom:zoom animated:NO];
    [self.mapView setCenterCoordinate:targetAnnotation.coordinate animated:NO];
    [self.mapView selectAnnotation:targetAnnotation animated:YES];

}

#pragma mark show trip
-(void)removeRoute {
    if([loadedAnnotations objectForKey:@"route"] != nil) {
        [mapView removeAnnotation:loadedAnnotations[@"route"]];
        [loadedAnnotations removeObjectForKey:@"route"];
    }
}

-(void)showTrip:(NSDictionary*)trip {
    
    if(trip == nil) {
        // remove everything off the map
        lastLoadedTrip = -1;
        [self removeRoute];
        return;
    } else if([trip[@"waypoints"] isEqualToArray:waypoints]) {
        // do nothing, already loaded
        return;
    }
    
    NSLog(@"loading new trip");

    lastLoadedTrip = [trip hash];
    
    [self removeRoute];
    
    waypoints = trip[@"waypoints"];
    RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.mapView coordinate:((CLLocation*)[waypoints objectAtIndex:0]).coordinate andTitle:@"Yol"];
    [annotation setUserInfo:trip];
    [annotation setBoundingBoxFromLocations:waypoints];
    
    [mapView addAnnotation:annotation];
    [loadedAnnotations  setObject:annotation forKey:@"route"];
}
@end
