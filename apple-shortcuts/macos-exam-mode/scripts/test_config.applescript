
-- Resolve project directory
set projectDirectory to POSIX path of (path to me)
set projectDirectory to do shell script "dirname " & quoted form of projectDirectory

-- Construct configuration path
set configPath to projectDirectory & "/../config/apps.plist"

-- Read configuration
tell application "System Events"
	set configFile to property list file configPath
	
	set configMode to value of property list item "mode" of configFile
	set whitelist to value of property list item "whitelist" of configFile
	set blacklist to value of property list item "blacklist" of configFile
	set preserveSystemApps to value of property list item "preserve_system_apps" of configFile
end tell

-- Display results
return "Mode: " & configMode & return & �
	"Whitelist: " & (whitelist as text) & return & �
	"Blacklist: " & (blacklist as text) & return & �
	"Preserve system apps: " & preserveSystemApps
