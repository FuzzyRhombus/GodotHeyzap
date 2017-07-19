package org.godotengine.godot;

import android.app.Activity;
import android.content.pm.ApplicationInfo;
import android.util.Log;
import android.view.ViewGroup.LayoutParams;
import android.view.View;
import android.view.Gravity;
import android.widget.FrameLayout;

import com.heyzap.sdk.ads.HeyzapAds;
import com.heyzap.sdk.ads.BannerAdView;
import com.heyzap.sdk.ads.InterstitialAd;
import com.heyzap.sdk.ads.VideoAd;
import com.heyzap.sdk.ads.IncentivizedAd;
import com.heyzap.sdk.ads.HeyzapAds.NetworkCallbackListener;

import com.heyzap.sdk.ads.HeyzapAds.BannerListener;
import com.heyzap.sdk.ads.HeyzapAds.BannerError;

import com.heyzap.sdk.ads.HeyzapAds.OnStatusListener;
import com.heyzap.sdk.ads.HeyzapAds.OnIncentiveResultListener;

public class Heyzap extends Godot.SingletonBase {

    public static final int AD_TYPE_NONE =                      0;
    public static final int AD_TYPE_BANNER =                    1;
    public static final int AD_TYPE_INTERSTITIAL =              2;
    public static final int AD_TYPE_VIDEO =                     4;
    public static final int AD_TYPE_REWARD_VIDEO =              8;

    public static final String CALLBACK_AD_READY =              "_on_ad_ready";
    public static final String CALLBACK_AD_SHOW =               "_on_ad_show";
    public static final String CALLBACK_AD_HIDE =               "_on_ad_hide";
    public static final String CALLBACK_AD_CLICK =              "_on_ad_click";
    public static final String CALLBACK_AD_SKIPPED =            "_on_ad_skipped";
    public static final String CALLBACK_AD_FINISHED =           "_on_ad_finished";
    public static final String CALLBACK_AD_FAILED =             "_on_ad_failed";
    public static final String CALLBACK_NETWORK_EVENT =         "_on_network_event";
    public static final String CALLBACK_INITIALIZED =           "_on_initialized";

    private static final String ERROR_MSG_SHOW =                "Failed to show ad";
    private static final String ERROR_MSG_FETCH =               "Failed to fetch ad";

    private Activity activity;
    private boolean initialized = false;
    private boolean isDebug = false;

	private BannerAdView bannerAdView = null;
	private FrameLayout bannerLayout = null;
    private FrameLayout.LayoutParams layoutParams = null;
    private int instanceId = 0;

    private static final String TAG = "Heyzap";

    public void init(final int newInstanceId, final String publisherID) {

        if (!initialized) {
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    instanceId = newInstanceId;
                    HeyzapAds.start(publisherID, activity, HeyzapAds.DISABLE_AUTOMATIC_FETCH);
                    bannerLayout = ((Godot) activity).layout;
                    bannerAdView = new BannerAdView(activity);
                    bannerLayout.addView(bannerAdView);
                    bannerAdView.setVisibility(View.GONE);
                    setupCallbacks();
                    InterstitialAd.fetch();
                    VideoAd.fetch();
                    IncentivizedAd.fetch();
                    Log.d("godot", TAG + " Init");
                }
            });
        }
    }

    protected void loadBanner(final int gravity) {
        layoutParams = new FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    gravity
        );
        bannerAdView.setLayoutParams(layoutParams);
        bannerLayout.bringToFront();
        bannerAdView.load();
        Log.d("godot", TAG + " Load Banner");
    }

    public void show_banner(final boolean isOnTop) {
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                boolean visible = bannerAdView != null && bannerAdView.getVisibility() == View.VISIBLE;
                int gravity = isOnTop ? Gravity.TOP : Gravity.BOTTOM;
                if (visible || (layoutParams != null && layoutParams.gravity == gravity)) return;
                Log.d("godot", TAG + " Show Banner");
                loadBanner(gravity);
            }
        });
    }

	public void hide_banner() {
		activity.runOnUiThread(new Runnable() {
			@Override
            public void run() {
				if (bannerAdView.getVisibility() == View.GONE) return;
				bannerAdView.setVisibility(View.GONE);
                GodotLib.calldeferred(instanceId, CALLBACK_AD_HIDE, new Object[]{AD_TYPE_BANNER, ""});
				Log.d("godot", TAG + " Hide Banner");
			}
		});
    }

    public boolean is_ad_ready(final int type) {
        switch (type) {
            case AD_TYPE_VIDEO: return VideoAd.isAvailable();
            case AD_TYPE_REWARD_VIDEO: return IncentivizedAd.isAvailable();
            default: return true;
        }
    }

    public void fetch_ad(final int type) {
        Log.d("godot", TAG + " Fetch Ad (type)");
        switch(type) {
            case AD_TYPE_INTERSTITIAL:
                InterstitialAd.fetch();
                break;
            case AD_TYPE_VIDEO:
                VideoAd.fetch();
                break;
            case AD_TYPE_REWARD_VIDEO:
                IncentivizedAd.fetch();
        }
    }

    public void show_interstitial() {
    	activity.runOnUiThread(new Runnable() {
			@Override
            public void run() {
                InterstitialAd.display(activity);
				Log.d("godot", TAG + " Display Interstitial");
			}
		});
    }

    public void show_video() {
    	activity.runOnUiThread(new Runnable() {
			@Override
            public void run() {
                if (is_ad_ready(AD_TYPE_VIDEO)) VideoAd.display(activity);
				Log.d("godot", TAG + " Display VideoAd");
			}
		});
    }

    public void show_reward_video() {
    	activity.runOnUiThread(new Runnable() {
			@Override
            public void run() {
                if (is_ad_ready(AD_TYPE_REWARD_VIDEO)) IncentivizedAd.display(activity);
				Log.d("godot", TAG + " Display IncentivizedAd");
			}
		});
    }

    public void startTestActivity() {
        if (isDebug) HeyzapAds.startTestActivity(activity);
    }

    @Override
    protected void onMainPause() {
        if (initialized) {
            //;
        }
    }

    @Override
    protected void onMainResume() {
        if (initialized) {
            //;
        }
    }

    @Override
    protected void onMainDestroy() {
        if (initialized) {
            bannerAdView.destroy();
            super.onMainDestroy();
        }
    }

    //-- callbacks

    protected void setupCallbacks() {
        final Heyzap self = this;

        HeyzapAds.setNetworkCallbackListener(new NetworkCallbackListener() {
            @Override
            public void onNetworkCallback(String network, String event) {
                if (event == "initialized" && !self.initialized) {
                    self.initialized = true;
                    GodotLib.calldeferred(instanceId, CALLBACK_INITIALIZED, new Object[]{});
                }
                GodotLib.calldeferred(instanceId, CALLBACK_NETWORK_EVENT, new Object[]{ network, event });
            }
        });

        bannerAdView.setBannerListener(new BannerListener() {
            @Override
            public void onAdClicked(BannerAdView b) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_CLICK, new Object[]{AD_TYPE_BANNER, ""});
            }

            @Override
            public void onAdLoaded(BannerAdView b) {
                bannerAdView.setVisibility(View.VISIBLE);
                GodotLib.calldeferred(instanceId, CALLBACK_AD_READY, new Object[]{AD_TYPE_BANNER, ""});
                GodotLib.calldeferred(instanceId, CALLBACK_AD_SHOW, new Object[]{AD_TYPE_BANNER, ""});
            }

            @Override
            public void onAdError(BannerAdView b, BannerError bannerError) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_FAILED, new Object[]{AD_TYPE_BANNER, bannerError, ""});
            }
        });

        InterstitialAd.setOnStatusListener(new OnStatusListener() {
            @Override
            public void onShow(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_SHOW, new Object[]{AD_TYPE_INTERSTITIAL, tag});
            }

            @Override
            public void onClick(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_CLICK, new Object[]{AD_TYPE_INTERSTITIAL, tag});
            }

            @Override
            public void onHide(String tag) {
                fetch_ad(AD_TYPE_INTERSTITIAL);
                GodotLib.calldeferred(instanceId, CALLBACK_AD_HIDE, new Object[]{AD_TYPE_INTERSTITIAL, tag});
            }

            @Override
            public void onFailedToShow(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_FAILED, new Object[]{AD_TYPE_INTERSTITIAL, ERROR_MSG_SHOW, tag});
            }

            @Override
            public void onAvailable(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_READY, new Object[]{AD_TYPE_INTERSTITIAL, tag});
            }

            @Override
            public void onFailedToFetch(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_FAILED, new Object[]{AD_TYPE_INTERSTITIAL, ERROR_MSG_FETCH, tag});
            }

            @Override
            public void onAudioStarted() {
                // The ad about to be shown will require audio. Any background audio should be muted.
            }

            @Override
            public void onAudioFinished() {
                // The ad being shown no longer requires audio. Any background audio can be resumed.
            }
        });

        VideoAd.setOnStatusListener(new OnStatusListener() {
            @Override
            public void onShow(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_SHOW, new Object[]{AD_TYPE_VIDEO, tag});
            }

            @Override
            public void onClick(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_CLICK, new Object[]{AD_TYPE_VIDEO, tag});
            }

            @Override
            public void onHide(String tag) {
                fetch_ad(AD_TYPE_VIDEO);
                GodotLib.calldeferred(instanceId, CALLBACK_AD_HIDE, new Object[]{AD_TYPE_VIDEO, tag});
            }

            @Override
            public void onFailedToShow(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_FAILED, new Object[]{AD_TYPE_VIDEO, ERROR_MSG_SHOW, tag});
            }

            @Override
            public void onAvailable(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_READY, new Object[]{AD_TYPE_VIDEO, tag});
            }

            @Override
            public void onFailedToFetch(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_FAILED, new Object[]{AD_TYPE_VIDEO, ERROR_MSG_FETCH, tag});
            }

            @Override
            public void onAudioStarted() {
                // The ad about to be shown will require audio. Any background audio should be muted.
            }

            @Override
            public void onAudioFinished() {
                // The ad being shown no longer requires audio. Any background audio can be resumed.
            }
        });

        IncentivizedAd.setOnStatusListener(new OnStatusListener() {

            @Override
            public void onShow(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_SHOW, new Object[]{AD_TYPE_REWARD_VIDEO, tag});
            }

            @Override
            public void onClick(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_CLICK, new Object[]{AD_TYPE_REWARD_VIDEO, tag});
            }

            @Override
            public void onHide(String tag) {
                fetch_ad(AD_TYPE_REWARD_VIDEO);
                GodotLib.calldeferred(instanceId, CALLBACK_AD_HIDE, new Object[]{AD_TYPE_REWARD_VIDEO, tag});
            }

            @Override
            public void onFailedToShow(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_FAILED, new Object[]{AD_TYPE_REWARD_VIDEO, ERROR_MSG_SHOW, tag});
            }

            @Override
            public void onAvailable(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_READY, new Object[]{AD_TYPE_REWARD_VIDEO, tag});
            }

            @Override
            public void onFailedToFetch(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_FAILED, new Object[]{AD_TYPE_REWARD_VIDEO, ERROR_MSG_FETCH, tag});
            }

            @Override
            public void onAudioStarted() {
                // The ad about to be shown will require audio. Any background audio should be muted.
            }

            @Override
            public void onAudioFinished() {
                // The ad being shown no longer requires audio. Any background audio can be resumed.
            }
        });


        IncentivizedAd.setOnIncentiveResultListener(new OnIncentiveResultListener() {
            @Override
            public void onComplete(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_FINISHED, new Object[]{AD_TYPE_REWARD_VIDEO, tag});
            }

            @Override
            public void onIncomplete(String tag) {
                GodotLib.calldeferred(instanceId, CALLBACK_AD_SKIPPED, new Object[]{AD_TYPE_REWARD_VIDEO, tag});
            }
        });

    }

    static public Godot.SingletonBase initialize(Activity p_activity) {
        return new Heyzap(p_activity);
    }

    public Heyzap(Activity activity) {
        isDebug = (activity.getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;
        registerClass("GodotHeyzap", new String[]{
            "init",
            "startTestActivity",
            "show_banner",
            "hide_banner",
            "is_ad_ready",
            "fetch_ad",
            "show_interstitial",
            "show_video",
            "show_reward_video"
        });
        this.activity = activity;
    }
}
