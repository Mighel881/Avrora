#include "AVARootListController.h"
#import <Cephei/HBRespringController.h>
#import "../Tweak/Avrora.h"
#import <spawn.h>
#import "SparkAppListTableViewController.h"

BOOL enabled = NO;

@implementation AVARootListController

- (instancetype)init {

    self = [super init];

    if (self) {
        AVAAppearanceSettings *appearanceSettings = [[AVAAppearanceSettings alloc] init];
        self.hb_appearanceSettings = appearanceSettings;
        self.enableSwitch = [[UISwitch alloc] init];
        self.enableSwitch.onTintColor = [UIColor colorWithRed: 0.64 green: 0.49 blue: 1.00 alpha: 1.00];
        [self.enableSwitch addTarget:self action:@selector(toggleState) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* switchy = [[UIBarButtonItem alloc] initWithCustomView: self.enableSwitch];
        self.navigationItem.rightBarButtonItem = switchy;

        self.navigationItem.titleView = [UIView new];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = @"1.1";
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.navigationItem.titleView addSubview:self.titleLabel];

        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AvroraPrefs.bundle/icon@2x.png"];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconView.alpha = 0.0;
        [self.navigationItem.titleView addSubview:self.iconView];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
            [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
        ]];
    }

    return self;

}

-(NSArray *)specifiers {

	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
    
}

- (void)viewDidLoad {

    [super viewDidLoad];

    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerImageView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AvroraPrefs.bundle/Banner.png"];
    self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.headerView addSubview:self.headerImageView];
    [NSLayoutConstraint activateConstraints:@[
        [self.headerImageView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
        [self.headerImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
        [self.headerImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
        [self.headerImageView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
    ]];

    _table.tableHeaderView = self.headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tableHeaderView = self.headerView;
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    CGRect frame = self.table.bounds;
    frame.origin.y = -frame.size.height;

    self.navigationController.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 0.76 green: 0.67 blue: 1.00 alpha: 1.00];
    [self.navigationController.navigationController.navigationBar setShadowImage: [UIImage new]];
    self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationController.navigationBar.translucent = YES;

}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    [self setEnableSwitchState];

    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Avrora.disabled"])
        [self disabledAlert];

}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat offsetY = scrollView.contentOffset.y;

    if (offsetY > 200) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
            self.titleLabel.alpha = 1.0;
        }];
    }
    
    if (offsetY > 0) offsetY = 0;
    self.headerImageView.frame = CGRectMake(0, offsetY, self.headerView.frame.size.width, 200 - offsetY);

}

- (void)selectDateApp {

    SparkAppListTableViewController* dateController = [[SparkAppListTableViewController alloc] initWithIdentifier:@"love.litten.avrorapreferences" andKey:@"dateApps"];

    [[self navigationController] pushViewController:dateController animated:YES];
    [[self navigationItem] setHidesBackButton:NO];

}

- (void)selectClockApp {

    SparkAppListTableViewController* weatherController = [[SparkAppListTableViewController alloc] initWithIdentifier:@"love.litten.avrorapreferences" andKey:@"clockApps"];

    [[self navigationController] pushViewController:weatherController animated:YES];
    [[self navigationItem] setHidesBackButton:NO];

}

- (void)selectWeatherApp {

    SparkAppListTableViewController* weatherController = [[SparkAppListTableViewController alloc] initWithIdentifier:@"love.litten.avrorapreferences" andKey:@"weatherApps"];

    [[self navigationController] pushViewController:weatherController animated:YES];
    [[self navigationItem] setHidesBackButton:NO];

}

- (void)selectNowPlayingApp {

    SparkAppListTableViewController* weatherController = [[SparkAppListTableViewController alloc] initWithIdentifier:@"love.litten.avrorapreferences" andKey:@"nowPlayingApps"];

    [[self navigationController] pushViewController:weatherController animated:YES];
    [[self navigationItem] setHidesBackButton:NO];

}

- (void)toggleState {

    [[self enableSwitch] setEnabled:NO];

    NSString* path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/love.litten.avrorapreferences.plist"];
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSSet* allKeys = [NSSet setWithArray:[dictionary allKeys]];
    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier: @"love.litten.avrorapreferences"];
    
    if (!([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/love.litten.avrorapreferences.plist"])) {
        enabled = YES;
        [preferences setBool:enabled forKey:@"Enabled"];
        [self respringUtil];
    } else if (!([allKeys containsObject:@"Enabled"])) {
        enabled = YES;
        [preferences setBool:enabled forKey:@"Enabled"];
        [self respringUtil];
    } else if ([[preferences objectForKey:@"Enabled"] isEqual:@(NO)]) {
        enabled = YES;
        [preferences setBool:enabled forKey:@"Enabled"];
        [self respringUtil];
    } else if ([[preferences objectForKey:@"Enabled"] isEqual:@(YES)]) {
        enabled = NO;
        [preferences setBool:enabled forKey:@"Enabled"];
        [self respringUtil];
    }

}

- (void)setEnableSwitchState {

    NSString* path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/love.litten.avrorapreferences.plist"];
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSSet* allKeys = [NSSet setWithArray:[dictionary allKeys]];
    HBPreferences* preferences = [[HBPreferences alloc] initWithIdentifier: @"love.litten.avrorapreferences"];
    
    if (!([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/love.litten.avrorapreferences.plist"]))
        [[self enableSwitch] setOn:NO animated:YES];
    else if (!([allKeys containsObject:@"Enabled"]))
        [[self enableSwitch] setOn:NO animated:YES];
    else if ([[preferences objectForKey:@"Enabled"] isEqual:@(YES)])
        [[self enableSwitch] setOn:YES animated:YES];
    else if ([[preferences objectForKey:@"Enabled"] isEqual:@(NO)])
        [[self enableSwitch] setOn:NO animated:YES];

}

- (void)resetPrompt {

    UIAlertController *resetAlert = [UIAlertController alertControllerWithTitle:@"Avrora"
	message:@"Do You Really Want To Reset Your Preferences?"
	preferredStyle:UIAlertControllerStyleActionSheet];
	
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Yep" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
			
        [self resetPreferences];

	}];

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Nope" style:UIAlertActionStyleCancel handler:nil];

	[resetAlert addAction:confirmAction];
	[resetAlert addAction:cancelAction];

	[self presentViewController:resetAlert animated:YES completion:nil];

}

- (void)disabledAlert {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Avrora"
	message:@"It Looks Like You Disabled Avrora In iCleaner Pro, Avrora Won't Work In This State"
	preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *resetAction = [UIAlertAction actionWithTitle:@"Reset Preferences" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {

        [self resetPreferences];

	}];

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {

        exit(0);

	}];

	[alertController addAction:resetAction];
    [alertController addAction:cancelAction];

	[self presentViewController:alertController animated:YES completion:nil];

}

- (void)resetPreferences {

    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier: @"love.litten.avrorapreferences"];
    for (NSString *key in [preferences dictionaryRepresentation]) {
        [preferences removeObjectForKey:key];

    }
    
    [self.enableSwitch setOn:NO animated: YES];
    [self respringUtil];

}

- (void)respringUtil {

    pid_t pid;
    const char *args[] = {"killall", "backboardd", NULL};

    [HBRespringController respringAndReturnTo:[NSURL URLWithString:@"prefs:root=Avrora"]];

    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)args, NULL);

}

@end