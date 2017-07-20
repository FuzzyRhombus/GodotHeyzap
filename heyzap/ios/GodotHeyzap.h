#ifndef __GODOT_HEYZAP_H__
#define __GODOT_HEYZAP_H__

#include "reference.h"

class GodotHeyzap : public Reference {
    OBJ_TYPE(GodotHeyzap, Reference);

    static GodotHeyzap* instance;
    static void _bind_methods();

protected:

	String publisher_id;

    bool initialized;
    bool test_mode;

	void *show_options;
	
public:

    enum AdType {
        AD_TYPE_NONE =                  0,
        AD_TYPE_BANNER =                1,
        AD_TYPE_INTERSTITIAL =          2,
        AD_TYPE_VIDEO =                 4,
        AD_TYPE_REWARD_VIDEO =          8
    };

    bool is_initialized() const;
    bool is_test_mode() const;
    bool is_ad_ready(const int type=AD_TYPE_NONE) const;

	void init(const String publisher_id);
    void start_test() const;

	void fetch_ad(const int type=AD_TYPE_NONE) const;
	void show_banner(const bool top=false);
    void hide_banner();
    void show_interstitial();
	void show_video();
    void show_reward_video();

    GodotHeyzap();
    ~GodotHeyzap();

    static GodotHeyzap* get_singleton();

};

#endif
