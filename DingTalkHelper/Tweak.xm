#import "MenuWindow/WBAssistantManager.h"
#import "WIFI/WBWifiStore.h"
#import "WIFI/WBWifiModel.h"
#import <SystemConfiguration/CaptiveNetwork.h>

%hook DTAppDelegate 

- (void)applicationDidBecomeActive:(id)arg1 {
	%orig;

	[[WBAssistantManager sharedManager] showMenu];
}

%end

CFArrayRef (*oldCNCopySupportedInterfaces)();
CFDictionaryRef (*oldCNCopyCurrentNetworkInfo)(CFStringRef interfaceName);
Boolean (*oldSCNetworkReachabilityGetFlags)(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags *flags);

CFArrayRef newCNCopySupportedInterfaces() {
	CFArrayRef result = NULL;

	WBWifiModel *wifi = [[WBWifiStore sharedStore] wifiHooked];

	if(wifi && wifi.interfaceName) {
		NSArray *array = [NSArray arrayWithObject:wifi.interfaceName];
		result = (CFArrayRef)CFRetain((__bridge CFArrayRef)(array));
	}

	if(!result) {
		result = oldCNCopySupportedInterfaces();
	}

	return result;
}

CFDictionaryRef newCNCopyCurrentNetworkInfo(CFStringRef interfaceName) {
	CFDictionaryRef result = NULL;

	WBWifiModel *wifi = [[WBWifiStore sharedStore] wifiHooked];
	if(wifi) {
		NSDictionary *dictionary = @{
		   @"BSSID": (wifi.BSSID ? wifi.BSSID : @""),
			@"SSID": (wifi.SSID ? wifi.SSID : @""),
		@"SSIDDATA": (wifi.SSIDData ? wifi.SSIDData : @"")
		};
		result = (CFDictionaryRef)CFRetain((__bridge CFDictionaryRef)(dictionary));
	}

	if(!result) {
		result = oldCNCopyCurrentNetworkInfo(interfaceName);
	}

	return result;
}

Boolean newSCNetworkReachabilityGetFlags(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags *flags) {
	Boolean result = false;

	WBWifiModel *wifi = [[WBWifiStore sharedStore] wifiHooked];
	if(wifi && wifi.flags > 0) {
		result = true;
		*flags = wifi.flags;
	}

	if(!result) {
		result = oldSCNetworkReachabilityGetFlags(target, flags);
	}

	return result;
}

%ctor {
	%init;

	MSHookFunction(&CNCopySupportedInterfaces, &newCNCopySupportedInterfaces, &oldCNCopySupportedInterfaces);
	MSHookFunction(&CNCopyCurrentNetworkInfo, &newCNCopyCurrentNetworkInfo, &oldCNCopyCurrentNetworkInfo);
	MSHookFunction(&SCNetworkReachabilityGetFlags, &newSCNetworkReachabilityGetFlags, &oldSCNetworkReachabilityGetFlags);
}
