#import <Preferences/PSViewController.h>

#define identifier @"com.dgh0st.sctextsection"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.dgh0st.sctextsection.plist"
#define kSectionName @"Custom Text"

// make sure to place SwitcherControls.dylib into the lib folder and rename it to libSwitcherControls.dylib
@interface ControlCenterSectionView : UIView
@end

@interface SCCustomTextSection : ControlCenterSectionView {
	UILabel *customText;
}
@end

@interface SCPreferences : NSObject
@property (nonatomic, assign, readonly) UIBlurEffectStyle blurStyle;
+(SCPreferences *)sharedInstance;
@end

@interface SCCSectionsListController : PSViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *allSections;
@property (nonatomic, strong) NSMutableArray *hiddenSections;
-(void)updateArrays;
@end

// have to do this because SwitcherControls keeps two copies (portrait and landscape, yes I know it can be improved)
NSMutableArray *texts = [NSMutableArray array];

static void preferencesChanged() {
	CFPreferencesAppSynchronize(CFSTR("com.dgh0st.sctextsection"));

	NSDictionary *prefs = nil;
	if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) {
		CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)identifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		if (keyList) {
			prefs = (NSDictionary *)CFPreferencesCopyMultiple(keyList, (CFStringRef)identifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
			if (!prefs) {
				prefs = [NSDictionary new];
			}
			CFRelease(keyList);
		}
	} else {
		prefs = [[NSDictionary alloc] initWithContentsOfFile:kSettingsPath];
	}

	NSString *text = [prefs objectForKey:@"customText"] ?: @"Please change the text displayed here through the settings";
	for (UILabel *label in texts)
		label.text = text;

	[prefs release];
}

@implementation SCCustomTextSection
// height will always be 64
// width will be either same as width of screen (orientation dependent) or width of screen - 40
-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self != nil) {
		customText = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, frame.size.width - 40, frame.size.height)];
		customText.text = @"Please change the text displayed here through the settings";
		customText.font = [UIFont systemFontOfSize:16];
		customText.numberOfLines = 3;
		customText.baselineAdjustment = YES;
		customText.adjustsFontSizeToFitWidth = YES;
		customText.backgroundColor = [UIColor clearColor];
		customText.textColor = ([[SCPreferences sharedInstance] blurStyle] == UIBlurEffectStyleExtraLight) ? [UIColor blackColor] : [UIColor whiteColor];
		customText.textAlignment = NSTextAlignmentCenter;
		customText.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);

		[self addSubview:customText];
		[texts addObject:customText];

		preferencesChanged();
	}
	return self;
}

-(void)dealloc {
	[texts removeObject:customText];
	[customText release];
	[super dealloc];
}
@end

%group all
%hook SCPreferences
-(Class)classForSection:(NSString *)arg1 {
	// return our custom class for our section
	if ([arg1 isEqualToString:kSectionName])
		return [SCCustomTextSection class];
	return %orig(arg1);
}
%end
%end

%group preferences
%hook PSViewController
-(id)init {
	id result = %orig();
	// yes this is a weird way of doing it...
	if (result != nil && [[result class] isEqual:[%c(SCCSectionsListController) class]]) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 250), dispatch_get_main_queue(), ^{
			[((SCCSectionsListController *)result).allSections addObject:kSectionName];
			[((SCCSectionsListController *)result).hiddenSections addObject:kSectionName];
			[(SCCSectionsListController *)result updateArrays];
		});
	}
	return result;
}
%end
%end

%dtor {
	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, CFSTR("com.dgh0st.sctextsection/settingschanged"), NULL);
	
	[texts removeAllObjects];
}

%ctor {
	preferencesChanged();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)preferencesChanged, CFSTR("com.dgh0st.sctextsection/settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	dlopen("/Library/MobileSubstrate/DynamicLibraries/SwitcherControls.dylib", RTLD_LAZY);
	if (%c(SCPreferences))
		%init(all);

	NSString *currentIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	if (currentIdentifier != nil && [currentIdentifier isEqualToString:@"com.apple.Preferences"])
		%init(preferences);
}