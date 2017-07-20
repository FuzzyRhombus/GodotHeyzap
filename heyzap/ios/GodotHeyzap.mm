#include "GodotHeyzap.h"
#include "core/globals.h"
#include "core/variant.h"

#import "app_delegate.h"
#import <HeyzapAds/HeyzapAds.h>

static const char* const SIGNAL_INITIALIZED =					"initialized";
static const char* const SIGNAL_AD_SHOW =						"ad_shown";
static const char* const SIGNAL_AD_HIDE =						"ad_hidden";
static const char* const SIGNAL_AD_CLICK =						"ad_clicked";
static const char* const SIGNAL_AD_FAILED =						"ad_failed";
static const char* const SIGNAL_AD_READY =                      "ad_ready";
static const char* const SIGNAL_AD_SKIP =                       "ad_skipped";
static const char* const SIGNAL_AD_FINISH =                     "ad_finished";

static const char* const ERROR_MSG_SHOW =						"Failed to show ad";
static const char* const ERROR_MSG_FETCH =						"Failed to fetch ad";

@interface AdDelegate : NSObject <HZAdsDelegate>

@property int ad_type;

-(id)initWithType:(int)type;

@end

@interface RewardAdDelegate : AdDelegate <HZIncentivizedAdDelegate>
@end

@implementation AdDelegate

- (id)initWithType:(int)type {
	self = [super init];
	if (self) self.ad_type = type;
	return self;
}

- (void)didReceiveAdWithTag:(NSString *)tag {
	GodotHeyzap::get_singleton()->emit_signal(SIGNAL_AD_READY, self.ad_type, [tag UTF8String]);
}

- (void)didFailToReceiveAdWithTag:(NSString *)tag {
	GodotHeyzap::get_singleton()->emit_signal(SIGNAL_AD_FAILED, self.ad_type, ERROR_MSG_FETCH, [tag UTF8String]);
}

- (void)didShowAdWithTag:(NSString *)tag {
	GodotHeyzap::get_singleton()->emit_signal(SIGNAL_AD_SHOW, self.ad_type, [tag UTF8String]);
}

- (void)didFailToShowAdWithTag:(NSString *)tag andError:(NSError *)error {
	GodotHeyzap::get_singleton()->emit_signal(SIGNAL_AD_FAILED, self.ad_type, ERROR_MSG_SHOW, [tag UTF8String]);
}

- (void)didClickAdWithTag:(NSString *)tag {
	GodotHeyzap::get_singleton()->emit_signal(SIGNAL_AD_CLICK, self.ad_type, [tag UTF8String]);
}

- (void)didHideAdWithTag:(NSString *) tag {
	GodotHeyzap *singleton = GodotHeyzap::get_singleton();
	singleton->emit_signal(SIGNAL_AD_HIDE, self.ad_type, [tag UTF8String]);
	singleton->fetch_ad(self.ad_type);
}

@end

@implementation RewardAdDelegate

- (void)didCompleteAdWithTag:(NSString *)tag {
	GodotHeyzap::get_singleton()->emit_signal(SIGNAL_AD_FINISH, self.ad_type, [tag UTF8String]);

}

- (void)didFailToCompleteAdWithTag:(NSString *)tag {
	GodotHeyzap::get_singleton()->emit_signal(SIGNAL_AD_SKIP, self.ad_type, [tag UTF8String]);
}

@end

static AdDelegate*  interstitial_delegate = nil;
static AdDelegate*  video_delegate = nil;
static RewardAdDelegate*  reward_delegate = nil;

GodotHeyzap *GodotHeyzap::instance = NULL;

GodotHeyzap::GodotHeyzap() {
    ERR_FAIL_COND(instance != NULL);
    instance = this;
	interstitial_delegate = [[AdDelegate alloc] initWithType:AD_TYPE_INTERSTITIAL];
	video_delegate = [[AdDelegate alloc] initWithType:AD_TYPE_VIDEO];
	reward_delegate = [[RewardAdDelegate alloc] initWithType:AD_TYPE_REWARD_VIDEO];
	ViewController *root_controller = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
	HZShowOptions *options = [[HZShowOptions alloc] init];
	options.viewController = root_controller;
	show_options = (void *)options;
    initialized = false;
#ifdef DEBUG_ENABLED
	test_mode = true;
#else
	test_mode = false;
#endif
}

GodotHeyzap::~GodotHeyzap() {
    if (instance != this) return;
    instance = NULL;
    [interstitial_delegate release];
    [video_delegate release];
    [reward_delegate release];
	[(HZShowOptions *)show_options release];
    interstitial_delegate = nil;
    video_delegate = nil;
    reward_delegate = nil;
	show_options = NULL;
}

GodotHeyzap* GodotHeyzap::get_singleton() {
    return instance;
}

void GodotHeyzap::_bind_methods() {
    ObjectTypeDB::bind_method(_MD("init"), &GodotHeyzap::init);
    ObjectTypeDB::bind_method(_MD("is_initialized"), &GodotHeyzap::is_initialized);
    ObjectTypeDB::bind_method(_MD("is_test_mode"), &GodotHeyzap::is_test_mode);
    ObjectTypeDB::bind_method(_MD("start_test"), &GodotHeyzap::start_test);
	ObjectTypeDB::bind_method(_MD("is_ad_ready", "ad_type"), &GodotHeyzap::is_ad_ready, AD_TYPE_NONE);
	ObjectTypeDB::bind_method(_MD("fetch_ad", "ad_type"), &GodotHeyzap::fetch_ad, AD_TYPE_NONE);
	ObjectTypeDB::bind_method(_MD("show_banner", "on_top"), &GodotHeyzap::show_banner, false);
	ObjectTypeDB::bind_method(_MD("hide_banner"), &GodotHeyzap::hide_banner);
	ObjectTypeDB::bind_method(_MD("show_interstitial"), &GodotHeyzap::show_interstitial);
	ObjectTypeDB::bind_method(_MD("show_video"), &GodotHeyzap::show_video);
	ObjectTypeDB::bind_method(_MD("show_reward_video"), &GodotHeyzap::show_reward_video);

    BIND_CONSTANT(AD_TYPE_NONE);
	BIND_CONSTANT(AD_TYPE_BANNER);
	BIND_CONSTANT(AD_TYPE_INTERSTITIAL);
	BIND_CONSTANT(AD_TYPE_VIDEO);
	BIND_CONSTANT(AD_TYPE_REWARD_VIDEO);
	
	ADD_SIGNAL(MethodInfo(SIGNAL_INITIALIZED));
	ADD_SIGNAL(MethodInfo(SIGNAL_AD_SHOW, PropertyInfo(Variant::INT, "ad_type"), PropertyInfo(Variant::STRING, "tag")));
	ADD_SIGNAL(MethodInfo(SIGNAL_AD_HIDE, PropertyInfo(Variant::INT, "ad_type"), PropertyInfo(Variant::STRING, "tag")));
	ADD_SIGNAL(MethodInfo(SIGNAL_AD_READY, PropertyInfo(Variant::INT, "ad_type"), PropertyInfo(Variant::STRING, "tag")));
	ADD_SIGNAL(MethodInfo(SIGNAL_AD_CLICK, PropertyInfo(Variant::INT, "ad_type"), PropertyInfo(Variant::STRING, "tag")));
	ADD_SIGNAL(MethodInfo(SIGNAL_AD_SKIP, PropertyInfo(Variant::INT, "ad_type"), PropertyInfo(Variant::STRING, "tag")));
	ADD_SIGNAL(MethodInfo(SIGNAL_AD_FINISH, PropertyInfo(Variant::INT, "ad_type"), PropertyInfo(Variant::STRING, "tag")));
	ADD_SIGNAL(MethodInfo(SIGNAL_AD_FAILED, PropertyInfo(Variant::INT, "ad_type"), PropertyInfo(Variant::STRING, "message"), PropertyInfo(Variant::STRING, "tag")));
}

void GodotHeyzap::init(const String publisher_id) {
    if (initialized) return;
    this->publisher_id = publisher_id;
    [HeyzapAds startWithPublisherID: [NSString stringWithCString:publisher_id.utf8().get_data() encoding:NSUTF8StringEncoding] andOptions: HZAdOptionsDisableAutoPrefetching];
	[HZInterstitialAd setDelegate: interstitial_delegate];
	[HZVideoAd setDelegate: video_delegate];
	[HZIncentivizedAd setDelegate: reward_delegate];
    initialized = true;
	fetch_ad(AD_TYPE_INTERSTITIAL);
	fetch_ad(AD_TYPE_VIDEO);
	fetch_ad(AD_TYPE_REWARD_VIDEO);
    emit_signal(SIGNAL_INITIALIZED);
}

void GodotHeyzap::start_test() const {
    if (initialized && test_mode) [HeyzapAds presentMediationDebugViewController];
}

bool GodotHeyzap::is_initialized() const {
    return initialized;
}

bool GodotHeyzap::is_test_mode() const {
    return test_mode;
}

bool GodotHeyzap::is_ad_ready(const int type) const {
    if (!initialized) return false;
	switch (type) {
		case AD_TYPE_INTERSTITIAL: return [HZInterstitialAd isAvailable];
		case AD_TYPE_VIDEO: return [HZVideoAd isAvailable];
		case AD_TYPE_REWARD_VIDEO: return [HZIncentivizedAd isAvailable];
		default: return true;
	}
}

void GodotHeyzap::fetch_ad(const int type) const {
	if (!initialized)  return;
	switch (type) {
		case AD_TYPE_INTERSTITIAL:
			[HZInterstitialAd fetch];
			break;
		case AD_TYPE_VIDEO:
			[HZVideoAd fetch];
			break;
		case AD_TYPE_REWARD_VIDEO:
			[HZIncentivizedAd fetch];
	}
}

void GodotHeyzap::show_banner(const bool top) {
	// TODO: implement banners and allow show
}

void GodotHeyzap::hide_banner() {
	// TODO: implement banners and allow hide
}

void GodotHeyzap::show_interstitial() {
	if (is_ad_ready(AD_TYPE_INTERSTITIAL)) [HZInterstitialAd showWithOptions:(HZShowOptions *)show_options];
}

void GodotHeyzap::show_video() {
	if (is_ad_ready(AD_TYPE_VIDEO)) [HZVideoAd showWithOptions:(HZShowOptions *)show_options];
}

void GodotHeyzap::show_reward_video() {
	if (is_ad_ready(AD_TYPE_REWARD_VIDEO)) [HZIncentivizedAd showWithOptions:(HZShowOptions *)show_options];
}
