# Heyzap.gd

extends Node

enum AdType { AD_TYPE_NONE, AD_TYPE_BANNER, AD_TYPE_INTERSTITIAL, AD_TYPE_VIDEO, AD_TYPE_REWARD_VIDEO }

const SINGLETON_BASE_NAME = 'GodotHeyzap'

onready var GodotHeyzap = Globals.get_singleton(SINGLETON_BASE_NAME)

var initialized = false

signal initialized
signal ad_ready(type, tag)
signal ad_shown(type, tag)
signal ad_hidden(type, tag)
signal ad_clicked(type, tag)
signal ad_skipped(type, tag)
signal ad_finished(type, tag)
signal ad_failed(type, msg, tag)
signal network_event(network, event)

func init(publisher_id):
    if GodotHeyzap: GodotHeyzap.init(get_instance_ID(), publisher_id)

func start_test():
    if GodotHeyzap: GodotHeyzap.start_test()

func is_initialized():
    return initialized

func is_ad_ready(type):
    return GodotHeyzap && GodotHeyzap.is_ad_ready(type)

func fetch_ad(type):
    if GodotHeyzap: GodotHeyzap.fetch_ad(type)

func show_banner(top=false):
    if GodotHeyzap: GodotHeyzap.show_banner(top)

func hide_banner():
    if GodotHeyzap: GodotHeyzap.hide_banner()

func show_interstitial():
    if GodotHeyzap: GodotHeyzap.show_interstitial()

func show_video():
    if GodotHeyzap: GodotHeyzap.show_video()

func show_reward_video():
    if GodotHeyzap: GodotHeyzap.show_reward_video()

func setup():
    GodotHeyzap = Globals.get_singleton(SINGLETON_BASE_NAME)
    set_process(false)

func _ready():
    if OS.get_name().to_lower() == 'android':
        set_process(true)
        if GodotHeyzap: setup()
    else: queue_free()

func _process(delta):
    if !GodotHeyzap && Globals.has_singleton(SINGLETON_BASE_NAME): setup()

func _on_initialized():
    initialized = true
    emit_signal('initialized')

func _on_network_event(network, event):
    pass
    # emit_signal('network_event', network, event)

func _on_ad_show(type, tag):
    emit_signal('ad_shown', type, tag)

func _on_ad_hide(type, tag):
    emit_signal('ad_hidden', type, tag)

func _on_ad_click(type, tag):
    emit_signal('ad_clicked', type, tag)

func _on_ad_failed(type, message, tag):
    emit_signal('ad_failed', type, message, tag)

func _on_ad_ready(type=0, tag=''):
    print('ready ', type)
    emit_signal('ad_ready', type, tag)

func _on_ad_skipped(type, tag):
    emit_signal('ad_skipped', type, tag)

func _on_ad_finished(type, tag):
    emit_signal('ad_finished', type, tag)
