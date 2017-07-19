extends Node

var publisher_id = "YOUR HEYZAP PUBLISHER ID"

func _ready():
	if Heyzap:
		Heyzap.connect('initialized', self, '_on_initialized', [], CONNECT_ONESHOT)
		Heyzap.connect('network_event', self, '_on_network_event')
		Heyzap.init(publisher_id)

func _on_initialized():
	print('heyzap initialized')
	Heyzap.connect('ad_shown', self, '_on_ad_shown')
	Heyzap.connect('ad_hidden', self, '_on_ad_hidden')
	Heyzap.connect('ad_ready', self, '_on_ad_ready')
	Heyzap.connect('ad_clicked', self, '_on_ad_clicked')
	Heyzap.connect('ad_skipped', self, '_on_ad_skipped')
	Heyzap.connect('ad_finished', self, '_on_ad_finished')
	Heyzap.connect('ad_failed', self, '_on_ad_failed')

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
	if Heyzap: Heyzap.start_test_activity();

func _on_button1_pressed():
	if Heyzap: Heyzap.show_banner(false);

func _on_button2_pressed():
	if Heyzap: Heyzap.show_banner(true);

func _on_button3_pressed():
	if Heyzap: Heyzap.hide_banner();

func _on_button4_pressed():
	if Heyzap: Heyzap.show_interstitial();

func _on_button5_pressed():
	if Heyzap: Heyzap.show_video()

func _on_button6_pressed():
	if Heyzap: Heyzap.show_reward_video()

func _on_button7_pressed():
	if Heyzap: Heyzap.fetch_ad(Heyzap.AD_TYPE_VIDEO);

func _on_button8_pressed():
	if Heyzap: Heyzap.fetch_ad(Heyzap.AD_TYPE_REWARD_VIDEO);

func _on_button9_pressed():
	if Heyzap:
		print(Heyzap.is_ad_ready(Heyzap.AD_TYPE_INTERSTITIAL))
		print(Heyzap.is_ad_ready(Heyzap.AD_TYPE_VIDEO))
		print(Heyzap.is_ad_ready(Heyzap.AD_TYPE_REWARD_VIDEO))
