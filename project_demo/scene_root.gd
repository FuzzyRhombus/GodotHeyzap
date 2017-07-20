extends Node

var publisher_id = "YOUR HEYZAP PUBLISHER ID"
onready var heyzap = Globals.get_singleton('Heyzap') if Globals.has_singleton('Heyzap') else Heyzap

func _ready():
	if heyzap:
		heyzap.connect('initialized', self, '_on_initialized', [], CONNECT_ONESHOT)
		heyzap.connect('network_event', self, '_on_network_event')
		heyzap.init(publisher_id)

func _on_initialized():
	print('heyzap initialized')
	heyzap.connect('ad_shown', self, '_on_ad_shown')
	heyzap.connect('ad_hidden', self, '_on_ad_hidden')
	heyzap.connect('ad_ready', self, '_on_ad_ready')
	heyzap.connect('ad_clicked', self, '_on_ad_clicked')
	heyzap.connect('ad_skipped', self, '_on_ad_skipped')
	heyzap.connect('ad_finished', self, '_on_ad_finished')
	heyzap.connect('ad_failed', self, '_on_ad_failed')

func _on_network_event(network, event):
	print(network + " - " + event)

func _on_ad_shown(type, tag):
	print("ad shown ", type, tag)

func _on_ad_hidden(type, tag):
	print("ad hidden ", type, tag)

func _on_ad_ready(type, tag):
	print("ad ready ", type, tag)

func _on_ad_clicked(type, tag):
	print("ad clicked ", type, tag)

func _on_ad_skipped(type, tag):
	print("ad skipped ", type, tag)

func _on_ad_finished(type, tag):
	print("ad finished ", type, tag)

func _on_ad_failed(type, msg, tag):
	print('error: ', msg, type, tag)

func _on_button_pressed():
	if heyzap: heyzap.start_test();

func _on_button1_pressed():
	if heyzap: heyzap.show_banner(false);

func _on_button2_pressed():
	if heyzap: heyzap.show_banner(true);

func _on_button3_pressed():
	if heyzap: heyzap.hide_banner();

func _on_button4_pressed():
	if heyzap: heyzap.show_interstitial();

func _on_button5_pressed():
	if heyzap: heyzap.show_video()

func _on_button6_pressed():
	if heyzap: heyzap.show_reward_video()

func _on_button7_pressed():
	if heyzap: heyzap.fetch_ad(heyzap.AD_TYPE_VIDEO);

func _on_button8_pressed():
	if heyzap: heyzap.fetch_ad(heyzap.AD_TYPE_REWARD_VIDEO);

func _on_button9_pressed():
	if heyzap:
		print(heyzap.is_ad_ready(heyzap.AD_TYPE_INTERSTITIAL))
		print(heyzap.is_ad_ready(heyzap.AD_TYPE_VIDEO))
		print(heyzap.is_ad_ready(heyzap.AD_TYPE_REWARD_VIDEO))
