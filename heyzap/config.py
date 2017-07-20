def can_build(plat):
	return plat == 'android' or plat == 'iphone'

def configure(env):
	if (env['platform'] == 'android'):
		env.android_add_java_dir("android/src")
		env.android_add_to_manifest("android/AndroidManifestChunk.xml")
		env.android_add_to_permissions("android/AndroidPermissionsChunk.xml")
		env.android_add_to_attributes("android/AndroidAttributesChunk.xml")
		env.android_add_dependency("compile 'com.google.android.gms:play-services-ads:8.+'")
		env.android_add_dependency("compile 'com.google.android.gms:play-services-location:8.+'")
		env.android_add_dependency("compile fileTree(dir: '../../../modules/heyzap/android/libs', include: '*.jar')")
		env.android_add_dependency("compile(name:'AudienceNetwork-4.20.0', ext:'aar')")
		env.android_add_dependency("compile(name:'unity-ads-2.0.5', ext:'aar')")
		#env.android_add_flat_dir_repository("../../../modules/heyzap/android/libs")
	elif env['platform'] == 'iphone':
		env.Append(FRAMEWORKPATH=['modules/heyzap/ios/lib'])
		# link any additional mediated frameworks below (e.g. -framework UnityAds)
		env.Append(LINKFLAGS=['-ObjC', '-framework', 'AdSupport', '-framework', 'CoreTelephony', '-framework', 'CoreVideo', '-framework', 'MediaPlayer', '-framework', 'MessageUI', '-framework', 'MobileCoreServices', '-framework', 'HeyzapAds',  '-lsqlite3', '-lxml2'])
