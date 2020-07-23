#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>
#import "SparkAppList.h"
#import "libpddokdo.h"
#import "MediaRemote.h"

HBPreferences* preferences;

extern BOOL enabled;

//other
BOOL hideLabels = NO;

// Date
NSString* dateFormatValue = @"MMMM";
NSDateFormatter* timeformat;

// Time
NSString* currentTime = nil;

// Weather
BOOL conditionSwitch = NO;
BOOL temperatureSwitch = NO;

// Now Playing
BOOL songTitleSwitch = NO;
BOOL artistNameSwitch = NO;
NSString* songTitle = nil;
NSString* artistName = nil;

@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
- (NSString *)displayName;
@end

@interface _UIStatusBarStringView : UILabel
@property(nonatomic, copy)NSString* originalText;
@end

@interface SBMediaController : NSObject
@property(nonatomic, readonly)SBApplication* nowPlayingApplication;
+ (id)sharedInstance;
- (BOOL)isPlaying;
@end