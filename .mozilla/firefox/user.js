/**
 * ATTENTION:
 *
 * THIS IS MY CUSTOMIZED use.js, HAVE DELETED SOMETHING FROM AND ADDED SOMETHING TO ARKENFOX
 *
 * MAINLY ADDED PARTS ARE:
 * "SAFE BROWSING", "CUSTOM (OPTIONAL) SETTINGS", "DISTRACTION FREE", "FASTFOX"
 */

/** GEOLOCATION **/
user_pref("geo.enabled", false);
user_pref("geo.wifi.uri", "");
user_pref("geo.provider.ms-windows-location", false); // [WINDOWS]
user_pref("geo.provider.use_corelocation", false); // [MAC]
user_pref("geo.provider.use_gpsd", false); // [LINUX] [HIDDEN PREF]
user_pref("geo.provider.use_geoclue", false); // [FF102+] [LINUX]

// Disable region updates
user_pref("browser.region.network.url", ""); // [FF78+] Defense-in-depth
// user_pref("browser.region.network.url", "https://location.services.mozilla.com/v1/country?key=%MOZILLA_API_KEY%"); // DEFAULT
user_pref("browser.region.update.enabled", false); // [FF79+]

/** RECOMMENDATIONS **/
user_pref("extensions.getAddons.showPane", false); // [HIDDEN PREF]
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.shopping.experience2023.enabled", false); // [DEFAULT: false]
user_pref("browser.shopping.experience2023.opted", 2);
user_pref("browser.shopping.experience2023.active", false);
user_pref("browser.shopping.experience2023.survey.enabled", false);
user_pref("extensions.webservice.discoverURL", "");

/** TELEMETRY ***/
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false); // see [NOTE]
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false); // [FF55+]
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false); // [FF55+]
user_pref("toolkit.telemetry.updatePing.enabled", false); // [FF56+]
user_pref("toolkit.telemetry.bhrPing.enabled", false); // [FF57+] Background Hang Reporter
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false); // [FF57+]
user_pref("toolkit.telemetry.cachedClientID", "");
user_pref("toolkit.telemetry.coverage.opt-out", true); // [HIDDEN PREF]
user_pref("toolkit.coverage.opt-out", true); // [FF64+] [HIDDEN PREF]
user_pref("toolkit.coverage.endpoint.base", "");
user_pref("browser.ping-centre.telemetry", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);

/** WEBVTT EVENTS **/
user_pref("media.webvtt.debug.logging", false);
user_pref("media.webvtt.testing.events", false);

user_pref("default-browser-agent.enabled", false); // [WINDOWS] // Disable Default Browser Agent

/** CONTENT BLOCKING REPORT **/
// Enable ETP Strict Mode [FF86+]
user_pref("browser.contentblocking.category", "strict"); // [HIDDEN PREF]

user_pref("browser.contentblocking.database.enabled", false); // Disable send content blocking log to about:protections
user_pref("browser.contentblocking.cfr-milestone.enabled", false); // Disable celebrating milestone toast when certain numbers of trackers are blocked
user_pref("browser.contentblocking.reportBreakage.url", "");
user_pref("browser.contentblocking.report.cookie.url", "");
user_pref("browser.contentblocking.report.cryptominer.url", "");
user_pref("browser.contentblocking.report.fingerprinter.url", "");
user_pref("browser.contentblocking.report.lockwise.enabled", false);
user_pref("browser.contentblocking.report.lockwise.how_it_works.url", "");
user_pref("browser.contentblocking.report.manage_devices.url", "");
user_pref("browser.contentblocking.report.monitor.enabled", false);
user_pref("browser.contentblocking.report.monitor.how_it_works.url", "");
user_pref("browser.contentblocking.report.monitor.sign_in_url", "");
user_pref("browser.contentblocking.report.monitor.url", "");
user_pref("browser.contentblocking.report.proxy.enabled", false);
user_pref("browser.contentblocking.report.proxy_extension.url", "");
user_pref("browser.contentblocking.report.social.url", "");
user_pref("browser.contentblocking.report.tracker.url", "");
user_pref("browser.contentblocking.report.endpoint_url", "");
user_pref("browser.contentblocking.report.monitor.home_page_url", "");
user_pref("browser.contentblocking.report.monitor.preferences_url", "");
user_pref("browser.contentblocking.report.vpn.enabled", false);
user_pref("browser.contentblocking.report.hide_vpn_banner", true);
user_pref("browser.contentblocking.report.show_mobile_app", false);
user_pref("browser.vpn_promo.enabled", false);
user_pref("browser.promo.focus.enabled", false);

/** STUDIES **/
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");

/** CRASH REPORTS **/
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false); // [FF44+]
user_pref("browser.crashReports.unsubmittedCheck.enabled", false); // [FF51+] [DEFAULT: false]
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false); // [DEFAULT: false]

/** PREFETCH **/
user_pref("network.prefetch-next", false);
// -------------------------------------
// Disable DNS prefetching
user_pref("network.dns.disablePrefetch", true);
user_pref("network.dns.disablePrefetchFromHTTPS", true); // [DEFAULT: true]
// -------------------------------------
// Disable predictor / prefetching
user_pref("network.predictor.enabled", false);
user_pref("network.predictor.enable-prefetch", false); // [FF48+] [DEFAULT: false]
// -------------------------------------
// Disable link-mouseover opening connection to linked server
user_pref("network.http.speculative-parallel-limit", 0);
// -------------------------------------
// Disable mousedown speculative connections on bookmarks and history [FF98+]
user_pref("browser.places.speculativeConnect.enabled", false);

/** DNS / DoH / PROXY / SOCKS **/
// Set the proxy server to do any DNS lookups when using SOCKS
user_pref("network.proxy.socks_remote_dns", true);
// Disable using UNC (Uniform Naming Convention) paths [FF61+]
user_pref("network.file.disable_unc_paths", true); // [HIDDEN PREF]
// Disable GIO as a potential proxy bypass vector
user_pref("network.gio.supported-protocols", ""); // [HIDDEN PREF] [DEFAULT: "" FF118+]
user_pref("browser.urlbar.speculativeConnect.enabled", false);
// Disable location bar unnecessary contextual suggestions
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false); // [FF95+]
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false); // [FF92+]
user_pref("browser.urlbar.suggest.pocket", false);
// Disable urlbar trending search suggestions [FF118+]
user_pref("browser.urlbar.trending.featureGate", false);
user_pref("browser.urlbar.addons.featureGate", false); // [FF115+]
user_pref("browser.urlbar.mdn.featureGate", false); // [FF117+] [HIDDEN PREF]
user_pref("browser.urlbar.pocket.featureGate", false); // [FF116+] [DEFAULT: false]
user_pref("browser.urlbar.weather.featureGate", false); // [FF108+] [DEFAULT: false]
// Disable search and form history
user_pref("browser.formfill.enable", false);
user_pref("browser.search.separatePrivateDefault", true); // [FF70+]
user_pref("browser.search.separatePrivateDefault.ui.enabled", true); // [FF71+]

user_pref("browser.urlbar.update2.engineAliasRefresh", true);
user_pref("security.insecure_connection_text.enabled", true);
user_pref("security.insecure_connection_text.pbmode.enabled", true);

/** PASSWORDS **/
// Disable auto-filling username & password form fields
user_pref("signon.autofillForms", false);
// -------------------------------------
// Disable formless login capture for Password Manager [FF51+]
user_pref("signon.formlessCapture.enabled", false);
user_pref("signon.privateBrowsingCapture.enabled", false);
user_pref("network.auth.subresource-http-auth-allow", 1);

/** DISK AVOIDANCE **/
// Disable media cache from writing to disk in Private Browsing
user_pref("browser.privatebrowsing.forceMediaMemoryCache", true); // [FF75+]
user_pref("media.memory_cache_max_size", 65536);
// define on which sites to save extra session data such as form content, cookies and POST data
// 0=everywhere, 1=unencrypted sites, 2=nowhere
user_pref("browser.sessionstore.privacy_level", 2);
// Disable automatic Firefox start and session restore after reboot [FF62+] [WINDOWS]
user_pref("toolkit.winRegisterApplicationRestart", false);
// Disable favicons in shortcuts [WINDOWS] NO! I WANT FAVICONS！
// user_pref("browser.shell.shortcutFavicons", false);

/** ONLINE SECURITY **/
user_pref("security.ssl.require_safe_negotiation", true);
user_pref("security.tls.enable_0rtt_data", false);
// disable OCSP for privacy
user_pref("security.OCSP.enabled", 0); // [DEFAULT: 1] disabled for privacy concern
user_pref("security.OCSP.require", false);
// user_pref("security.ssl.enable_ocsp_must_staple", false);
user_pref("security.cert_pinning.enforcement_level", 2);
user_pref("security.remote_settings.crlite_filters.enabled", true);
user_pref("security.pki.crlite_mode", 2);
user_pref("dom.security.https_only_mode", true);
user_pref("dom.security.https_only_mode_send_http_background_request", false);
user_pref("dom.security.https_first", true);
user_pref("dom.security.https_only_mode_error_page_user_suggestions", true);
// PREF: block insecure passive content (images) on HTTPS pages
// Using HTTPS First Policy, Firefox will still make a HTTP connection
// if it can't find a secure connection, so this isn't redundant.
// There's the small chance that someone does a MITM on the images
// and deploys a malicious image. (They're rare, but possible).
user_pref("security.mixed_content.block_display_content", true); // [NOTE] You can remove if using HTTPS-Only Mode.
// PREF: upgrade passive content to use HTTPS on secure pages
// [NOTE] You can remove if using HTTPS-Only Mode.
user_pref("security.mixed_content.upgrade_display_content", true);
user_pref("security.mixed_content.upgrade_display_content.image", true);

/** Developer feature, won't affect daily usage, but might impair user privacy **/
// PREF: Disable DOM timing API
// https://wiki.mozilla.org/Security/Reviews/Firefox/NavigationTimingAPI
user_pref("dom.enable_performance", false);
// PREF: Disable resource timing API
// https://www.w3.org/TR/resource-timing/#privacy-security
// NOTICE: Disabling resource timing API breaks some DDoS protection pages (Cloudflare)
// user_pref("dom.enable_resource_timing", false);
// PREF: Make sure the User Timing API does not provide a new high resolution timestamp
// https://trac.torproject.org/projects/tor/ticket/16336
user_pref("dom.enable_user_timing", false);

/** UI (User Interface) **/
// user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true);
user_pref("browser.xul.error_pages.expert_bad_cert", true);
user_pref("app.feedback.baseURL", "");
user_pref("app.support.baseURL", "");
// disable UITour backend so there is no chance that a remote page can use it
user_pref("browser.uitour.enabled", false);
user_pref("browser.uitour.url", "");

/** REFERERS **/
/*
 * referer spoofing negative impacts:
 * 1. will cause sites like 'moviesjoy.is' fail to load videos in an iframe
 * 2. will also break Bilibili video playing
 * 3. will broke Internet Archive (Wayback Machine), getting "Fail with status: 498 No Reason Phrase"
 */
// user_pref("network.http.sendRefererHeader", 0);
// user_pref("network.http.sendSecureXSiteReferrer", false);
// 0=always send, 1=send if base domains match, 2=send if hosts match
// user_pref("network.http.referer.XOriginPolicy", 1);  // DEFAULT 0
// enforce no referer spoofing, because spoofing can affect CSRF (Cross-Site Request Forgery) protections
// user_pref("network.http.referer.spoofSource", true);

// 0=always send, 1=send if base domains match, 2=send if hosts match
user_pref("network.http.referer.XOriginTrimmingPolicy", 2); // DEFAULT 0

/** CONTAINERS **/
user_pref("privacy.userContext.enabled", true);
user_pref("privacy.userContext.ui.enabled", true);

/** MISCELLANEOUS **/
user_pref("browser.download.start_downloads_in_tmp_dir", true); // [FF102+]
user_pref("browser.helperApps.deleteTempFileOnExit", true);
// reset remote debugging to disabled
// user_pref("devtools.debugger.remote-enabled", false); // [DEFAULT: false]
// disable websites overriding Firefox's keyboard shortcuts
user_pref("permissions.manager.defaultsUrl", "");
user_pref("webchannel.allowObject.urlWhitelist", "");
// use Punycode in Internationalized Domain Names to eliminate possible spoofing
user_pref("network.IDN_show_punycode", true);

user_pref("pdfjs.disabled", false); // [DEFAULT: false]
user_pref("pdfjs.enableScripting", false); // [FF86+]

user_pref("privacy.trackingprotection.enabled", true); // will affect bilibili log-in
user_pref("privacy.trackingprotection.emailtracking.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
user_pref("services.sync.prefs.sync-seen.privacy.trackingprotection.enabled", true);

user_pref("privacy.resistFingerprinting.randomization.daily_reset.enabled", true);
user_pref("privacy.resistFingerprinting.randomization.daily_reset.private.enabled", true);

// disable beacon api will cause ChatGPT not streaming display the response text
// user_pref("beacon.enabled", false);

user_pref("plugins.enumerable_names", "");
user_pref("dom.disable_window_move_resize", true);
// user_pref("dom.event.clipboardevents.enabled", false); // if "false", will break deepl.com paste, casuing unknown line breaks
user_pref("dom.event.contextmenu.enabled", false);
// user_pref("layout.frame_rate.precise", true);

user_pref("media.peerconnection.ice.proxy_only_if_behind_proxy", true);
user_pref("media.peerconnection.ice.default_address_only", true);
user_pref("media.navigator.enabled", false);

user_pref("privacy.resistFingerprinting.block_mozAddonManager", true);
user_pref("widget.non-native-theme.enabled", true);
user_pref("browser.display.use_system_colors", false);
user_pref("browser.link.open_newwindow", 3);
user_pref("browser.link.open_newwindow.restriction", 0);

/** 9001: disable welcome notices **/
user_pref("browser.startup.homepage_override.mstone", "ignore"); // [HIDDEN PREF]
/* 9002: disable General>Browsing>Recommend extensions/features as you browse [FF67+] ***/
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
/* 9003: disable What's New toolbar icon [FF69+] ***/
user_pref("browser.messaging-system.whatsNewPanel.enabled", false);
/* 9004: disable search terms [FF110+]
 * [SETTING] Search>Search Bar>Use the address bar for search and navigation>Show search terms instead of URL... ***/
user_pref("browser.urlbar.showSearchTerms.enabled", false);

user_pref("extensions.blocklist.enabled", true); // [DEFAULT: true]

/* 6004: enforce a security delay on some confirmation dialogs such as install, open/save
 * [1] https://www.squarefree.com/2004/07/01/race-conditions-in-security-dialogs/ ***/
user_pref("security.dialog_enable_delay", 1000); // [DEFAULT: 1000]
/* 6008: enforce no First Party Isolation [FF51+]
 * [WARNING] Replaced with network partitioning (FF85+) and TCP (2701), and enabling FPI
 * disables those. FPI is no longer maintained except at Tor Project for Tor Browser's config ***/
user_pref("privacy.firstparty.isolate", false); // [DEFAULT: false]
/* 6009: enforce SmartBlock shims (about:compat) [FF81+]
 * [1] https://blog.mozilla.org/security/2021/03/23/introducing-smartblock/ ***/
user_pref("extensions.webcompat.enable_shims", true); // [HIDDEN PREF] [DEFAULT: true]
/* 6010: enforce no TLS 1.0/1.1 downgrades
 * [TEST] https://tls-v1-1.badssl.com:1010/ ***/
user_pref("security.tls.version.enable-deprecated", false); // [DEFAULT: false]
/* 6011: enforce disabling of Web Compatibility Reporter [FF56+]
 * Web Compatibility Reporter adds a "Report Site Issue" button to send data to Mozilla
 * [WHY] To prevent wasting Mozilla's time with a custom setup ***/
user_pref("extensions.webcompat-reporter.enabled", false); // [DEFAULT: false]
/* 6012: enforce Quarantined Domains [FF115+]
 * [WHY] https://support.mozilla.org/kb/quarantined-domains */
user_pref("extensions.quarantinedDomains.enabled", true); // [DEFAULT: true]

// Enable Site Isolation
// user_pref("fission.autostart", true);

/**
 * ==========================================================================
 * ==========================================================================
 * ==========================================================================
 * ==========================================================================
 */

/** SAFE BROWSING **/
// Disable SB (Safe Browsing)
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.phishing.enabled", false);
user_pref("browser.safebrowsing.passwords.enabled", false);
user_pref("browser.safebrowsing.allowOverride", false);
// Disable SB checks for downloads (both local lookups + remote)
user_pref("browser.safebrowsing.downloads.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.block_potentially_unwanted", false);
user_pref("browser.safebrowsing.downloads.remote.block_uncommon", false);
// Google connections
user_pref("browser.safebrowsing.downloads.remote.block_dangerous", false);
user_pref("browser.safebrowsing.downloads.remote.block_dangerous_host", false);
user_pref("browser.safebrowsing.provider.google.updateURL", "");
user_pref("browser.safebrowsing.provider.google.gethashURL", "");
user_pref("browser.safebrowsing.provider.google4.updateURL", "");
user_pref("browser.safebrowsing.provider.google4.gethashURL", "");
user_pref("browser.safebrowsing.provider.google.reportURL", "");
user_pref("browser.safebrowsing.reportPhishURL", "");
user_pref("browser.safebrowsing.provider.google4.reportURL", "");
user_pref("browser.safebrowsing.provider.google.reportMalwareMistakeURL", "");
user_pref("browser.safebrowsing.provider.google.reportPhishMistakeURL", "");
user_pref("browser.safebrowsing.provider.google4.reportMalwareMistakeURL", "");
user_pref("browser.safebrowsing.provider.google4.reportPhishMistakeURL", "");
user_pref("browser.safebrowsing.provider.google4.dataSharing.enabled", false);
user_pref("browser.safebrowsing.provider.google4.dataSharingURL", "");
user_pref("browser.safebrowsing.provider.google.advisory", "");
user_pref("browser.safebrowsing.provider.google.advisoryURL", "");
user_pref("browser.safebrowsing.provider.google.gethashURL", "");
user_pref("browser.safebrowsing.provider.google4.advisoryURL", "");
user_pref("browser.safebrowsing.blockedURIs.enabled", false);
user_pref("browser.safebrowsing.provider.mozilla.gethashURL", "");
user_pref("browser.safebrowsing.provider.mozilla.updateURL", "");

/** CUSTOM (OPTIONAL) SETTINGS **/ // From Betterfox & Narsil user.js & Other sources
/*
 * Determine how gif image animation plays
 * 3 options:
 * normal: default
 * once: gif animation only play once
 * none: do not play gif animation
 */
// user_pref("image.animation_mode", "once");

user_pref("layout.css.devPixelsPerPx", 1.8);
user_pref("browser.uidensity", 1);
user_pref("browser.autofocus", false);

user_pref("browser.startup.page", 3);
user_pref("browser.tabs.closeWindowWithLastTab", false);
user_pref("browser.quitShortcut.disabled", true);
user_pref("general.smoothScroll", true);
/*
 * 0: Dark
 * 1: Light
 * 2: System
 * 3: Browser
 */
user_pref("layout.css.prefers-color-scheme.content-override", 2); // [default] use Auto theme
user_pref("widget.disable-swipe-tracker", true); // disable back/forward page navigation when scrolling sideways
user_pref("browser.preferences.moreFromMozilla", false);
user_pref("ui.prefersReducedMotion", 1); // 0 for full animation; 1 for reduced motion
/*
 * Action:
 * 0: Nothing happens
 * 1: Scrolling contents
 * 2: Go back or go forward, in your history
 * 3: Zoom in or out (reflowing zoom)
 * 4: Treat vertical wheel as horizontal scroll
 * 5: Zoom in or out (pinch zoom)
 */
user_pref("mousewheel.with_alt.action", 4);
user_pref("ui.key.menuAccessKeyFocuses", false);
user_pref("ui.key.menuAccessKey", -1); // disable Alt toggle menu bar
user_pref("ui.key.chromeAccess", 0);

user_pref("general.autoScroll", false); // disable auto scrolling, which allows you to scroll the page by clicking the middle mouse button (usually the scroll wheel)

// Open bookmark in new tab
user_pref("browser.tabs.loadBookmarksInTabs", true);
// user_pref("browser.tabs.loadBookmarksInBackground", true); // load bookmark in background

// Disable video/audio autoplay entirely
// The disable autoplay feature in Firefox has an escape hatch for media that is played after someone interacts with the page, since it tries to ensure that people don’t think the page or browser is broken
user_pref("media.autoplay.blocking_policy", 2);

user_pref("browser.tabs.opentabfor.middleclick", false);
// user_pref("privacy.resistFingerprinting", true); // Site can't get the theme mode of operating system
// user_pref("privacy.resistFingerprinting.letterboxing", true); // [HIDDEN PREF]
// Disable WebGL (Web Graphics Library)
user_pref("webgl.disabled", true);
// user_pref("gfx.canvas.accelerated", true); // might cause issue on Windows with intergrated gpus
// user_pref("gfx.webrender.all", true); // Might improve graphic rendering experience with decent graphic card. But can possibly cause unknown issues. Worth testing.
user_pref("browser.warnOnQuit", false);
// user_pref("browser.tabs.firefox-view", false); // disable Firefox View [FF106+]
// user_pref("browser.tabs.tabmanager.enabled", false); // disable Firefox list of all tabs (the down-arrow icon on the tab toolbar)
// user_pref("browser.backspace_action", 0);
// remove the additional 3-dot menu on the URL bar suggestions
user_pref("browser.urlbar.resultMenu.keyboardAccessible", false);
// use Mozilla geolocation service instead of Google when geolocation is enabled
// user_pref("geo.provider.network.url", "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%");
user_pref("geo.provider.network.url", "");
user_pref("network.protocol-handler.external.mailto", false);
// Set default permissions
// 0=always ask (default), 1=allow, 2=block
user_pref("permissions.default.geo", 2);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.xr", 2); // Virtual Reality
user_pref("privacy.donottrackheader.enabled", false);
// Disable WebRTC (Web Real-Time Communication)
user_pref("media.peerconnection.enabled", false);
user_pref("extensions.pocket.enabled", false); // Pocket Account [FF46+]
user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.creditCards.enabled", false);
// Disable Push Notifications [FF44+]
user_pref("dom.push.enabled", false);
user_pref("dom.push.connection.enabled", false);
user_pref("dom.push.serverURL", "");
user_pref("dom.push.userAgentID", "");
user_pref("dom.battery.enabled", false);
user_pref("privacy.history.custom", true);
user_pref("browser.newtabpage.activity-stream.default.sites", "");
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

// Do not always make private winodw's theme dark
user_pref("browser.theme.dark-private-windows", false);
// Set firefox to use the default theme
user_pref("extensions.activeThemeID", "default-theme@mozilla.org");

// 2: reject banners if it is a one-click option; otherwise, fall back to the accept button to remove banner
// 1: reject banners if it is a one-click option; otherwise, keep banners on screen
// 0: disable all cookie banner handling
user_pref("cookiebanners.service.mode", 0);
user_pref("cookiebanners.service.mode.privateBrowsing", 0);
user_pref("cookiebanners.service.enableGlobalRules", true);
user_pref("urlclassifier.trackingSkipURLs", "*.reddit.com, *.twitter.com, *.twimg.com, *.tiktok.com"); // MANUAL
user_pref("urlclassifier.features.socialtracking.skipURLs", "*.instagram.com, *.twitter.com, *.twimg.com"); // MANUAL
user_pref("signon.rememberSignons", false);

// Disable Captive Portal detection
user_pref("captivedetect.canonicalURL", "");
user_pref("network.captive-portal-service.enabled", false); // [FF52+]

// Max suggestion number in URL bar
user_pref("browser.urlbar.maxRichResults", 12);

/** DISTRACTION FREE **/ // From Betterfox
user_pref("browser.privatebrowsing.vpnpromourl", "");
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.aboutwelcome.enabled", false); // disable Intro screens
// prevent private windows being separate from normal windows in taskbar [WINDOWS] [FF106+]
user_pref("browser.privateWindowSeparation.enabled", false);
// user_pref("browser.newtabpage.activity-stream.feeds.topsites", false); // Shortcuts
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false); // Recommended by Pocket
user_pref("browser.newtabpage.activity-stream.section.highlights.includePocket", false);
// GREAT FEATURE!
user_pref("browser.urlbar.suggest.calculator", true);
user_pref("browser.urlbar.unitConversion.enabled", true);
user_pref("browser.urlbar.suggest.trending", false);
user_pref("browser.urlbar.suggest.recentsearches", false);
user_pref("browser.download.open_pdf_attachments_inline", true); // open PDFs inline (FF103+)
user_pref("findbar.highlightAll", true); // show all matches in Findbar
user_pref("browser.menu.showViewImageInfo", true); // restore "View image info" on right-click
user_pref("browser.bookmarks.openInTabClosesMenu", false); // leave Bookmarks Menu open when selecting a site
user_pref("layout.word_select.eat_space_to_next_word", false); // do not select the space next to a word when selecting a word

user_pref("privacy.query_stripping.strip_list", "__hsfp __hssc __hstc __s _hsenc _openstat dclid fbclid gbraid gclid hsCtaTracking igshid mc_eid ml_subscriber ml_subscriber_hash msclkid oft_c oft_ck oft_d oft_id oft_ids oft_k oft_lk oft_sk oly_anon_id oly_enc_id rb_clickid s_cid twclid vero_conv vero_id wbraid wickedid yclid");

/** FASTFOX (https://github.com/yokoffing/Betterfox/blob/main/Fastfox.js) **/
user_pref("content.notify.interval", 100000);
user_pref("gfx.canvas.accelerated.cache-items", 4096);
user_pref("gfx.canvas.accelerated.cache-size", 512);
user_pref("gfx.content.skia-font-cache-size", 20);
user_pref("browser.cache.jsbc_compression_level", 3);
user_pref("media.memory_cache_max_size", 65536);
user_pref("media.cache_readahead_limit", 7200);
user_pref("media.cache_resume_threshold", 3600);
user_pref("image.mem.decode_bytes_at_a_time", 32768);
user_pref("network.buffer.cache.size", 262144);
user_pref("network.buffer.cache.count", 128);
user_pref("network.http.max-connections", 1800);
user_pref("network.http.max-persistent-connections-per-server", 10);
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 5);
user_pref("network.http.pacing.requests.enabled", false);
user_pref("network.dnsCacheExpiration", 3600);
// user_pref("network.dns.max_high_priority_threads", 40);
// user_pref("network.dns.max_any_priority_threads", 24);
user_pref("network.ssl_tokens_cache_capacity", 10240);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.dns.disablePrefetchFromHTTPS", true);
user_pref("network.prefetch-next", false);
user_pref("network.predictor.enabled", false);
user_pref("layout.css.grid-template-masonry-value.enabled", true);
user_pref("dom.enable_web_task_scheduling", true);
user_pref("layout.css.has-selector.enabled", true);
user_pref("dom.security.sanitizer.enabled", true);

user_pref("gfx.webrender.compositor.force-enabled", true);

// user_pref("layers.acceleration.force-enabled", true);
// user_pref("layers.async-video.enabled", true);
