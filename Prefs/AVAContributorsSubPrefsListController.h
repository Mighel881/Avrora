#import <Preferences/PSListController.h>
#import <Preferences/PSListItemsController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>

@interface AVAAppearanceSettings : HBAppearanceSettings
@end

@interface AVAContributorsSubPrefsListController : HBListController
@property(nonatomic, retain)UILabel* titleLabel;
@end