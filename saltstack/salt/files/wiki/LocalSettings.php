<?php
# This file is managed by SALT

# Protect against web entry
if ( !defined( 'MEDIAWIKI' ) ) {
    exit;
}


## Uncomment this to disable output compression
# $wgDisableOutputCompression = true;

$wgSitename = "Kopf WIKI";

## The URL base path to the directory containing the wiki;
## defaults for all runtime URL paths are based off of this.
## For more information on customizing the URLs
## (like /w/index.php/Page_title to /wiki/Page_title) please see:
## https://www.mediawiki.org/wiki/Manual:Short_URL
$wgScriptPath = "";

## The protocol and server name to use in fully-qualified URLs
$wgServer = "https://wiki.petro.ws";

## The URL path to static resources (images, scripts, etc.)
$wgResourceBasePath = $wgScriptPath;

## The URL path to the logo.  Make sure you change this from the default,
## or else you'll overwrite your logo when you upgrade!
$wgLogo = "$wgResourceBasePath/resources/assets/wiki.png";

## UPO means: this is also a user preference option

$wgEnableEmail = true;
$wgEnableUserEmail = true; # UPO

$wgEmergencyContact = "{{ salt['pillar.get']('pws_secrets:wiki:system_email', '') }}";
$wgPasswordSender = "{{ salt['pillar.get']('pws_secrets:wiki:system_email', '') }}";

$wgEnotifUserTalk = true; # UPO
$wgEnotifWatchlist = true; # UPO
$wgEmailAuthentication = true;

## Database settings
$wgDBtype = "mysql";
$wgDBserver = "db";
$wgDBname = "wiki";
$wgDBuser = "wiki";
$wgDBpassword = "{{ salt['pillar.get']('pws_secrets:db_password') }}";

# MySQL specific settings
$wgDBprefix = "";

# MySQL table options to use during installation or update
$wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";

## Shared memory settings
$wgMainCacheType = CACHE_ACCEL;
$wgMemCachedServers = [];

## To enable image uploads, make sure the 'images' directory
## is writable, then set this to true:
$wgEnableUploads = true;
$wgUseImageMagick = true;
$wgImageMagickConvertCommand = "/usr/bin/convert";

# InstantCommons allows wiki to use images from https://commons.wikimedia.org
$wgUseInstantCommons = false;

# Periodically send a pingback to https://www.mediawiki.org/ with basic data
# about this MediaWiki instance. The Wikimedia Foundation shares this data
# with MediaWiki developers to help guide future development efforts.
$wgPingback = true;

## If you use ImageMagick (or any other shell command) on a
## Linux server, this will need to be set to the name of an
## available UTF-8 locale
$wgShellLocale = "C.UTF-8";

## Set $wgCacheDirectory to a writable directory on the web server
## to make your wiki go slightly faster. The directory should not
## be publicly accessible from the web.
#$wgCacheDirectory = "$IP/cache";

# Site language code, should be one of the list in ./languages/data/Names.php
$wgLanguageCode = "ru";

$wgSecretKey = "{{ salt['pillar.get']('pws_secrets:wiki:secret') }}";

# Changing this will log out all existing sessions.
$wgAuthenticationTokenVersion = "1";

# Site upgrade key. Must be set to a string (default provided) to turn on the
# web installer while LocalSettings.php is in place
$wgUpgradeKey = "{{ salt['pillar.get']('pws_secrets:wiki:upgrade_key') }}";

## For attaching licensing metadata to pages, and displaying an
## appropriate copyright notice / icon. GNU Free Documentation
## License and Creative Commons licenses are supported so far.
$wgRightsPage = ""; # Set to the title of a wiki page that describes your license/copyright
$wgRightsUrl = "";
$wgRightsText = "";
$wgRightsIcon = "";

# Path to the GNU diff3 utility. Used for conflict resolution.
$wgDiff3 = "/usr/bin/diff3";

# The following permissions were set based on your choice in the installer
$wgGroupPermissions['*']['createaccount'] = false;
$wgGroupPermissions['*']['edit'] = false;
$wgGroupPermissions['*']['read'] = false;

# Mail config
$wgSMTP = [
    'host'     => "{{ salt['pillar.get']('pws_secrets:mail_relay:ssl_host') }}",
    'IDHost'   => 'wiki.petro.ws',
    'port'     => "{{ salt['pillar.get']('pws_secrets:mail_relay:ssl_port') }}",
    'username' => "{{ salt['pillar.get']('pws_secrets:mail_relay:username') }}",
    'password' => "{{ salt['pillar.get']('pws_secrets:mail_relay:password') }}",
    'auth'     => true,
];

# Skins config
wfLoadSkin( 'Vector' );

# Vector 2022 as the default skin
$wgDefaultSkin = 'vector-2022';

# Ignore per-user skin preference — everyone gets the default skin
# $wgHiddenPrefs[] = 'skin';

# Enable night mode (needed on MW 1.42–1.45; removed in 1.46 where it's always available)
$wgVectorNightMode['beta'] = true;
$wgVectorNightMode['logged_out'] = true;
$wgVectorNightMode['logged_in'] = true;

# Default color mode: 'os' = follow system dark/light preference
$wgDefaultUserOptions['vector-theme'] = 'os';

# Enabled extensions. Most of the extensions are enabled by adding
# wfLoadExtensions('ExtensionName');
# to LocalSettings.php. Check specific extension documentation for more details.
# The following extensions were automatically enabled:
wfLoadExtension( 'CodeEditor' );
wfLoadExtension( 'MultimediaViewer' );
wfLoadExtension( 'PdfHandler' );
wfLoadExtension( 'WikiEditor' );

# wfLoadExtension( 'TinyMCE' );

# End of automatically generated settings.
# Add more configuration options below.
error_reporting( -1 );
ini_set( 'display_errors', 1 );

$wgShowExceptionDetails = true;

# Add new types to the existing list from DefaultSettings.php
$wgFileExtensions[] = 'docx';
$wgFileExtensions[] = 'xls';
$wgFileExtensions[] = 'pdf';
$wgFileExtensions[] = 'mpp';
$wgFileExtensions[] = 'odt';
$wgFileExtensions[] = 'ods';
