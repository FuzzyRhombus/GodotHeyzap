# GodotHeyzap
[Heyzap](https://www.heyzap.com/) Module for [Godot Game Engine](https://godotengine.org/) **v2.1.x NOT TESTED ON v3.0**

### Supports Android & iOS (no banners as of yet)

![Screenshot](/images/screenshot.png)


Compiling
-------------

Copy the `heyzap` folder from the root of this repository and its contents and put inside of the modules folder inside of godot source code

### Android

> You may need to enable multi dex support, especially if you are using other modules. Please see [https://developer.android.com/studio/build/multidex.html](this link) for details

2. on your godot source code, edit the file `godot/platform/android/build.gradle.template`, search the code snippet

        allprojects {
            repositories {
                mavenCentral()
                $$GRADLE_REPOSITORY_URLS$$

            }
        }

    and chage it to:

        allprojects {
            repositories {
                mavenCentral()
                $$GRADLE_REPOSITORY_URLS$$
                flatDir {
                    dirs "../../../modules/heyzap/android/libs"
                }
            }
        }

3. [compile the godot source for android](http://docs.godotengine.org/en/stable/reference/compiling_for_android.html)

4. Copy the `Heyzap.gd` script from the `project_demo` into your project and set it to [autoload](http://docs.godotengine.org/en/stable/learning/step_by_step/singletons_autoload.html) as `Heyzap`

### iOS

1. Copy the latest `HeyzapAds.framework` to `modules/heyzap/ios/lib`. Copy any additional mediated frameworks to there as well (i.e. UnityAds, Chartboost, etc..)

2. Modify the `config.py` to link any additional mediated frameworks you are using. See the file for details.

3. [compile for iOS](http://docs.godotengine.org/en/stable/development/compiling/compiling_for_ios.html)

# Usage

See the `project_demo` for usage. If your project supports iOS & Android, you can reference the singleton as seen in the `project_demo`. Don't forget to include `Heyzap.gd`!

### Constants
    AD_TYPE_NONE
    AD_TYPE_BANNER
    AD_TYPE_INTERSTITIAL
    AD_TYPE_VIDEO
    AD_TYPE_REWARD_VIDEO

### Functions

- `init(publisher_id)`
> initializes Heyzap with your Heyzap publisher id. Must be called before anything else
- `start_test()`
> launches the Heyzap mediation test suite. Available only in debug builds
- `show_banner(on_top=false)`
> show banner on top or bottom. Does nothing on iOS
- `hide_banner()`
> does nothing on iOS
- `is_ad_ready(ad_type)`
> Check if the given ad type is ready to be displayed
- `is_initialized()`
- `fetch_ad(ad_type)`
- `show_interstitial()`
- `show_video()`
- `show_reward_video()`

### Signals

- `network_event(network, event)`
> Android only.
    - String network => Network name, eg: "heyzap", "facebook", "unityads", "applovin", "vungle", "chartboost", "adcolony", "admob", "hyprmx"
    - String event => Event name, eg: "initialized", "show", "available", "hide", "fetch_failed", "click", "dismiss", "incentivized_result_complete", "incentivized_result_incomplete", "audio_starting", "audio_finished", "banner-loaded", "banner-click", "banner-hide", "banner-dismiss", "banner-fetch_failed", "leave_application", "display_failed"
- `initialized`
> fired once on successful initialization
- `ad_ready(ad_type, tag)`
- `ad_shown(ad_type, tag)`
- `ad_hidden(ad_type, tag)`
- `ad_clicked(ad_type, tag)`
- `ad_skipped(ad_type, tag)`
> if a reward/incentivized video is skipped -> should never fire
- `ad_finished(ad_type, tag)`
> if a reward/incentivized video is completed -> use this to give rewards
- `ad_failed(ad_type, msg, tag)`


----

Please don't forget to check the demo project to see how the things works on the GDScript side.
You can find a quick tutorial [here](https://shinnil.blogspot.com.br/2017/03/tutorial-using-heyzap-godot-module.html).
