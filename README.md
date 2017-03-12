# php_fixer
Autoheal PHP
Usage: fixer_script.sh fix|silent|verbose

fix: Fixes a static file without looking at logs. Not implemented.

silent: Fixes files from cron without user intervention. This could be dangerous.
To implement silent mode, move the functions you want into the silent case.
This is not recommended for a production system. Test, test, test!

verbose: Looks at logs specified in the script variable logfile and fixes common PHP
programming errors. This has been designed for one specific use case. Make sure you back up and test before using this script!

In order for this script to work, a marker needs to be in the php file.
Save some time, use sed to add marker. Google sed substitution for examples
Markers are:

//DECLAREDVARS - This marker is where variable declarations go.
