#import <CoreLocation/CoreLocation.h>

%hook AMapLocationManager

- (void)locationManager:(id)arg1 didUpdateLocations:(id)arg2 { 

	CLLocation *location = [[CLLocation alloc] initWithLatitude:30.56874 longitude:104.063401];
	arg2 = @[location];

    // NSString *message = [NSString stringWithFormat:@"arg1 -- %@, arg2 -- %@", arg1, arg2];
    // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    // [alert show];

	%orig; 
}

%end

