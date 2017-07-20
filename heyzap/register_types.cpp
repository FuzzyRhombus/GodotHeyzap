#include "register_types.h"
#include "object_type_db.h"
#include "core/globals.h"
#include "ios/GodotHeyzap.h"

void register_heyzap_types() {
    Globals::get_singleton()->add_singleton(Globals::Singleton("Heyzap", memnew(GodotHeyzap)));
}

void unregister_heyzap_types() {
}
