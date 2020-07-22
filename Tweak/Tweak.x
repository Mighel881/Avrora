#import "Avrora.h"

BOOL enabled;

%group Avrora

// Set Display Names

%hook SBApplication

- (NSString *)displayName {

    if ([SparkAppList doesIdentifier:@"love.litten.avrorapreferences" andKey:@"dateApps" containBundleIdentifier:[self bundleIdentifier]]) {
        timeformat = [[NSDateFormatter alloc] init];
        [timeformat setDateFormat:dateFormatValue];
        return [timeformat stringFromDate:[NSDate date]];
    } else if ([SparkAppList doesIdentifier:@"love.litten.avrorapreferences" andKey:@"weatherApps" containBundleIdentifier:[self bundleIdentifier]]) {
        [[PDDokdo sharedInstance] refreshWeatherData];
        if (conditionSwitch && !temperatureSwitch)
            return [NSString stringWithFormat:@"%@", [[PDDokdo sharedInstance] currentConditions]];
        else if (!conditionSwitch && temperatureSwitch)
            return [NSString stringWithFormat:@"%@", [[PDDokdo sharedInstance] currentTemperature]];
        else
            return %orig;
    } else if ([SparkAppList doesIdentifier:@"love.litten.avrorapreferences" andKey:@"clockApps" containBundleIdentifier:[self bundleIdentifier]]) {
        return currentTime;
    } else if ([SparkAppList doesIdentifier:@"love.litten.avrorapreferences" andKey:@"nowPlayingApps" containBundleIdentifier:[self bundleIdentifier]]) {
        if ([[%c(SBMediaController) sharedInstance] isPlaying]) {
            if (songTitleSwitch)
                return songTitle;
            else if (artistNameSwitch)
                return artistName;
            else
                return %orig;
        } else {
            return %orig;
        }
    } else {
        return %orig;
    }
    
}

%end

// Get Current Time

%hook _UIStatusBarStringView

- (void)setText:(id)arg1 { // for some reason it doesn't work to create a new NSDateFormatter for the time so i get it this way

    %orig;
    if ([[self originalText] containsString:@":"]) {
        currentTime = [self originalText];
    }

}

%end

// Get Current Song And Artist Name

%hook SBMediaController

- (void)setNowPlayingInfo:(id)arg1 {

    %orig;

    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary* dict = (__bridge NSDictionary *)information;
        if (dict) {
            if (songTitleSwitch) {
                if (dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle]) {
                    songTitle = [dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoTitle];
                }
            } else if (artistNameSwitch) {
                if (dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist]) {
                    artistName = [dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtist];
                }
            }
        }
    });
    
}

%end

%end

%ctor {

	preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.avrorapreferences"];

    [preferences registerBool:&enabled default:nil forKey:@"Enabled"];

    // Date
    [preferences registerObject:&dateFormatValue default:@"MMMM" forKey:@"dateFormat"];

    // Weather
    [preferences registerBool:&conditionSwitch default:NO forKey:@"condition"];
    [preferences registerBool:&temperatureSwitch default:NO forKey:@"temperature"];

    // Now Playing
    [preferences registerBool:&songTitleSwitch default:NO forKey:@"songTitle"];
    [preferences registerBool:&artistNameSwitch default:NO forKey:@"artistName"];

	if (enabled) {
		%init(Avrora);
        return;
    }

}