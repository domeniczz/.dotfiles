# Doc: https://qutebrowser.org/doc/help/settings.html

config.load_autoconfig(False)

c.aliases = {
    'adblock-toggle': 'config-cycle -t content.blocking.enabled',
    'darkmode-toggle': 'spawn --userscript darkmode-toggle',
    'incognito': 'open --private',
    'firefox': 'spawn --detach firefox {url}',
    'mpv': 'spawn --detach mpv {url}',
    'w': 'session-save',
    'q': 'close',
    'qa': 'quit',
    'wq': 'quit --save',
    'wqa': 'quit --save',
}

c.bindings.key_mappings = {
    '<Ctrl-[>': '<Escape>',
    '<Ctrl-6>': '<Ctrl-^>',
    '<Ctrl-M>': '<Return>',
    '<Ctrl-J>': '<Return>',
    '<Ctrl-I>': '<Tab>',
    '<Shift-Return>': '<Return>',
    '<Enter>': '<Return>',
    '<Shift-Enter>': '<Return>',
    '<Ctrl-Enter>': '<Ctrl-Return>'
}

c.url.searchengines = {
    'DEFAULT': 'https://kagi.com/search?q={}',

    'k': 'https://kagi.com/search?q={}',
    'g': 'https://www.google.com/search?q={}',
    # 'bing': 'https://www.bing.com/search?q={}',
    # 'brave': 'https://search.brave.com/search?q={}',
    # 'ddg': 'https://duckduckgo.com/?q={}',
    # 'sp': 'https://www.startpage.com/sp/search?query={}',
    # 'disroot': 'https://search.disroot.org/?q={}',
    # 'mojeek': 'https://www.mojeek.com/search?q={}&theme=light&t=40&arc=us&newtab=1&hp=minimal&date=1&cdate=1&qsba=1&tn=0&qss=Bing,Google,Yandex',

    'gpt': 'https://kagi.com/fastgpt?query={}',

    'img': 'https://www.google.com/search?tbm=isch&q={}',
    'yt': 'http://www.youtube.com/results?search_query={}',

    'tr': 'https://translate.google.com/?sl=en&tl=zh-CN&text={}&op=translate',
    'dl': 'https://www.deepl.com/en/translator#en/zh/{}',
    'dict': 'https://dictionary.cambridge.org/dictionary/english-chinese-simplified/{}',

    'wp': 'https://en.wikipedia.org/wiki/{}',
    'ww': 'https://www.wikiwand.com/en/search?q={}',

    'aw': 'https://wiki.archlinux.org/index.php?title=Special:Search&search={}',
    'dw': 'https://wiki.debian.org/FrontPage?action=fullsearch&context=180&value={}',
    'ap': 'https://www.archlinux.org/packages/?sort=&q={}&maintainer=&flagged=',
    'dp': 'https://packages.debian.org/search?keywords={}&searchon=names&section=all',
    'man': 'https://man.archlinux.org/search?q={}',
    'debman': 'https://dyn.manpages.debian.org/jump?q={}',

    'sum': 'https://kagi.com/summarizer/?target_language=EN&summary=summary&url={}',
}
c.url.auto_search = 'naive'
c.url.default_page = 'https://www.google.com'
c.url.incdec_segments = ['path', 'query']
c.url.open_base_url = True
c.url.start_pages = ['https://www.google.com']
c.url.yank_ignored_parameters = ['ref', 'utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content', 'utm_name']

c.completion.cmd_history_max_items = 100
c.completion.delay = 0
c.completion.height = '70%'
c.completion.min_chars = 1
c.completion.open_categories = ['bookmarks', 'quickmarks', 'history', 'searchengines', 'filesystem']
c.completion.quick = True
c.completion.scrollbar.padding = 2
c.completion.scrollbar.width = 8
c.completion.show = 'always'
c.completion.shrink = True
c.completion.timestamp_format = '%m-%d-%Y %H:%M'
c.completion.use_best_match = True
c.completion.web_history.exclude = [
    '*://*/*signin*',
    '*://*/*login*',
    '*://*/*register*',
    '*://*/*__cf_chl_tk*',
]
c.completion.web_history.max_items = 10000

c.downloads.location.directory = '~/Downloads'
c.downloads.location.prompt = True
c.downloads.location.remember = True
c.downloads.location.suggestion = 'path'
c.downloads.open_dispatcher = None
c.downloads.position = 'top'
c.downloads.prevent_mixed_content = True
c.downloads.remove_finished = 4000

c.editor.command = ['alacritty', '-e', 'nvim', '{file}', "+call cursor({line}, {column})"]
c.editor.encoding = 'utf-8'
c.editor.remove_file = True

c.hints.auto_follow = 'unique-match'
c.hints.auto_follow_timeout = 0
c.hints.border = '1px solid #E3BE23'
c.hints.chars = 'asdfghjkl'
c.hints.hide_unmatched_rapid_hints = True
c.hints.leave_on_load = False
c.hints.min_chars = 1
c.hints.mode = 'letter'
c.hints.padding = {'top': 0, 'bottom': 0, 'left': 3, 'right': 3}
c.hints.radius = 5
c.hints.scatter = True
c.hints.uppercase = False

c.history_gap_interval = -1

c.input.insert_mode.auto_enter = True
c.input.insert_mode.auto_leave = False
c.input.insert_mode.auto_load = False
c.input.insert_mode.leave_on_load = False
c.input.insert_mode.plugins = False
c.input.links_included_in_focus_chain = True
c.input.escape_quits_reporter = True
c.input.mouse.back_forward_buttons = True
c.input.mouse.rocker_gestures = False
c.input.partial_timeout = 0
c.input.spatial_navigation = False

c.keyhint.delay = 100
c.keyhint.radius = 6

c.logging.level.console = 'info'
c.logging.level.ram = 'critical'

c.messages.timeout = 4000

c.new_instance_open_target = 'tab'
c.new_instance_open_target_window = 'last-focused'

c.prompt.filebrowser = True
c.prompt.radius = 8

# Be careful with this, you should know what you are doing
c.qt.args = [
    # 'use-gl=desktop',
    # 'use-gl=angle',
    'enable-gpu-rasterization',
]
c.qt.chromium.experimental_web_platform_features = 'auto'
c.qt.chromium.low_end_device_mode = 'auto'
c.qt.chromium.process_model = 'process-per-site-instance'
c.qt.chromium.sandboxing = 'enable-all'
c.qt.force_platform = "wayland"
c.qt.force_software_rendering = 'none'
c.qt.highdpi = True
c.qt.workarounds.disable_accelerated_2d_canvas = 'never'

c.scrolling.bar = 'overlay'
c.scrolling.smooth = False

c.search.ignore_case = 'smart'
c.search.incremental = True
c.search.wrap = True
c.search.wrap_messages = True

c.session.lazy_restore = True

c.window.hide_decoration = False
c.window.title_format = '{perc}{current_title}{title_sep}qutebrowser'
c.window.transparent = False

c.zoom.default = '100%'
c.zoom.levels = ['25%', '33%', '50%', '67%', '75%', '90%', '100%', '110%', '125%', '150%', '175%', '200%', '250%', '300%', '400%', '500%']
c.zoom.mouse_divider = 512

c.auto_save.interval = 15000
c.auto_save.session = True
c.confirm_quit = ['never']
c.backend = 'webengine'
c.changelog_after_upgrade = 'minor'

# -----------------------------------------------------------------------------
# Tab bar & Status bar
# -----------------------------------------------------------------------------

c.statusbar.padding = {'top': 1, 'bottom': 1, 'left': 0, 'right': 0}
c.statusbar.position = 'bottom'
c.statusbar.show = 'always'
c.statusbar.widgets = ['keypress', 'search_match', 'url', 'progress', 'scroll', 'history', 'tabs']

c.tabs.background = True
c.tabs.close_mouse_button = 'none'
c.tabs.close_mouse_button_on_bar = 'new-tab'
c.tabs.favicons.scale = 1.0
c.tabs.favicons.show = 'always'
c.tabs.focus_stack_size = 1
c.tabs.indicator.padding = {'top': 2, 'bottom': 2, 'left': 0, 'right': 4}
c.tabs.indicator.width = 3
c.tabs.last_close = 'startpage'
c.tabs.mode_on_change = 'normal'
c.tabs.mousewheel_switching = False
c.tabs.new_position.related = 'next'
c.tabs.new_position.stacking = True
c.tabs.new_position.unrelated = 'last'
c.tabs.padding = {'top': 0, 'bottom': 0, 'left': 5, 'right': 5}
c.tabs.pinned.frozen = True
c.tabs.pinned.shrink = True
c.tabs.position = 'top'
c.tabs.select_on_remove = 'last-used'
c.tabs.show = 'multiple'
c.tabs.show_switching_delay = 800
c.tabs.tabs_are_windows = False
c.tabs.title.alignment = 'left'
c.tabs.title.elide = 'right'
c.tabs.title.format = '{audio}{index}: {current_title}'
c.tabs.title.format_pinned = '{index}'
c.tabs.tooltips = True
c.tabs.undo_stack_size = 100
c.tabs.width = '10%'
c.tabs.wrap = True

# -----------------------------------------------------------------------------
# Content options
# -----------------------------------------------------------------------------

c.content.blocking.adblock.lists = [
    # uBlock filters
    'https://ublockorigin.github.io/uAssetsCDN/filters/filters.min.txt',
    'https://cdn.jsdelivr.net/gh/uBlockOrigin/uAssetsCDN@main/filters/badware.min.txt',
    'https://ublockorigin.pages.dev/filters/privacy.min.txt',
    'https://ublockorigin.pages.dev/filters/quick-fixes.min.txt',
    'https://ublockorigin.github.io/uAssetsCDN/filters/unbreak.min.txt',
    # EasyList
    'https://cdn.statically.io/gh/uBlockOrigin/uAssetsCDN/main/thirdparties/easylist.txt',
    'https://cdn.statically.io/gh/uBlockOrigin/uAssetsCDN/main/thirdparties/easyprivacy.txt',
    'https://cdn.statically.io/gh/uBlockOrigin/uAssetsCDN/main/thirdparties/easylist-chat.txt',
    'https://cdn.statically.io/gh/uBlockOrigin/uAssetsCDN/main/thirdparties/easylist-newsletters.txt',
    'https://ublockorigin.pages.dev/thirdparties/easylist-notifications.txt',
    'https://ublockorigin.pages.dev/thirdparties/easylist-annoyances.txt',
    # Malicious URL
    'https://malware-filter.pages.dev/urlhaus-filter-ag-online.txt',
    # Peter Lowe's Ad and tracking server list
    'https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=1&mimetype=plaintext',
    # Cookie notices
    'https://ublockorigin.github.io/uAssetsCDN/thirdparties/easylist-cookies.txt',
    'https://filters.adtidy.org/extension/ublock/filters/18.txt',
    'https://cdn.jsdelivr.net/gh/uBlockOrigin/uAssetsCDN@main/filters/annoyances-cookies.txt',
    # Social widgets
    'https://cdn.jsdelivr.net/gh/uBlockOrigin/uAssetsCDN@main/thirdparties/easylist-social.txt',
    # Region, Languages
    'https://filters.adtidy.org/extension/ublock/filters/224.txt',
]
c.content.blocking.enabled = True
c.content.blocking.hosts.block_subdomains = True
c.content.blocking.hosts.lists = [
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts',
    'https://cdn.jsdelivr.net/gh/jerryn70/GoodbyeAds@master/Hosts/GoodbyeAds.txt',
]
c.content.blocking.method = 'both'
c.content.blocking.whitelist = []

c.content.cache.size = 2147483647
c.content.canvas_reading = True
c.content.cookies.accept = 'no-unknown-3rdparty'
c.content.cookies.store = True
c.content.default_encoding = 'utf-8'
c.content.desktop_capture = 'ask'
c.content.dns_prefetch = True
c.content.fullscreen.overlay_timeout = 4000
c.content.fullscreen.window = False
c.content.geolocation = False
c.content.headers.accept_language = 'en-US,en;q=0.9'
c.content.headers.do_not_track = False
c.content.headers.referer = 'same-domain'
c.content.headers.user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36'
c.content.hyperlink_auditing = False
c.content.images = True

c.content.javascript.alert = True
c.content.javascript.can_open_tabs_automatically = False
c.content.javascript.clipboard = 'access'
c.content.javascript.enabled = True
c.content.javascript.legacy_touch_events = 'never'
c.content.javascript.log = {'unknown': 'debug', 'info': 'debug', 'warning': 'debug', 'error': 'debug'}
c.content.javascript.log_message.excludes = {'userscript:_qute_stylesheet': ['*Refused to apply inline style because it violates the following Content Security Policy directive: *']}
c.content.javascript.log_message.levels = {'qute:*': ['error'], 'userscript:GM-*': [], 'userscript:*': ['error']}
c.content.javascript.modal_dialog = False
c.content.javascript.prompt = True

c.content.local_content_can_access_file_urls = True
c.content.local_content_can_access_remote_urls = False
c.content.local_storage = True
c.content.media.audio_capture = 'ask'
c.content.media.audio_video_capture = 'ask'
c.content.media.video_capture = 'ask'
c.content.mouse_lock = 'ask'
c.content.mute = False
c.content.autoplay = False

c.content.notifications.enabled = False
c.content.notifications.presenter = 'auto'
c.content.notifications.show_origin = True

c.content.pdfjs = False
c.content.persistent_storage = 'ask'
c.content.plugins = False
c.content.prefers_reduced_motion = True
c.content.print_element_backgrounds = True
c.content.private_browsing = False
c.content.proxy = 'system'
c.content.register_protocol_handler = 'ask'
c.content.site_specific_quirks.enabled = True
c.content.tls.certificate_errors = 'ask'
c.content.unknown_url_scheme_policy = 'allow-from-user-interaction'
c.content.webgl = True
c.content.webrtc_ip_handling_policy = 'default-public-interface-only'
c.content.xss_auditing = False

# -----------------------------------------------------------------------------
# Key bindings
# -----------------------------------------------------------------------------

config.unbind('<Ctrl+A>')
config.unbind('<Ctrl+X>')
config.unbind('pP')
config.unbind('PP')

## Bindings for normal mode
config.bind("'", 'mode-enter jump_mark')
config.bind('+', 'zoom-in')
config.bind('_', 'zoom-out')
config.bind('=', 'zoom')
config.bind('<Ctrl-=>', 'zoom-in')
config.bind('<Ctrl-->', 'zoom-out')
config.bind('<Ctrl-0>', 'zoom')
config.bind('.', 'cmd-repeat-last')
config.bind('/', 'cmd-set-text /')
config.bind(':', 'cmd-set-text :')
config.bind(';I', 'hint images tab')
config.bind(';O', 'hint links fill :open -t -r {hint-url}')
config.bind(';R', 'hint --rapid links window')
config.bind(';Y', 'hint links yank-primary')
config.bind(';b', 'hint all tab-bg')
config.bind(';d', 'hint links download')
config.bind(';f', 'hint all tab-fg')
config.bind(';h', 'hint all hover')
config.bind(';i', 'hint images')
config.bind(';o', 'hint links fill :open {hint-url}')
config.bind(';r', 'hint --rapid links tab-bg')
config.bind(';t', 'hint inputs')
config.bind(';y', 'hint links yank')
config.bind('<Alt-1>', 'tab-focus 1')
config.bind('<Alt-2>', 'tab-focus 2')
config.bind('<Alt-3>', 'tab-focus 3')
config.bind('<Alt-4>', 'tab-focus 4')
config.bind('<Alt-5>', 'tab-focus 5')
config.bind('<Alt-6>', 'tab-focus 6')
config.bind('<Alt-7>', 'tab-focus 7')
config.bind('<Alt-8>', 'tab-focus 8')
config.bind('<Alt-9>', 'tab-focus -1')
config.bind('<Alt-m>', 'tab-mute')
# config.bind('<Ctrl-A>', 'navigate increment')
config.bind('<Ctrl-Alt-p>', 'print')
config.bind('<Ctrl-B>', 'scroll-page 0 -1')
config.bind('<Ctrl-D>', 'scroll-page 0 0.5')
config.bind('<Ctrl-F5>', 'reload -f')
config.bind('<Ctrl-F>', 'scroll-page 0 1')
config.bind('<Ctrl-N>', 'open -w')
config.bind('<Ctrl-PgDown>', 'tab-next')
config.bind('<Ctrl-PgUp>', 'tab-prev')
config.bind('<Ctrl-Q>', 'quit')
config.bind('<Ctrl-Return>', 'selection-follow -t')
config.bind('<Ctrl-Shift-N>', 'open -p')
config.bind('<Ctrl-Shift-P>', 'open --private')
config.bind('<Ctrl-Shift-T>', 'undo')
config.bind('<Ctrl-Shift-Tab>', 'nop')
config.bind('<Ctrl-Shift-W>', 'close')
config.bind('<Ctrl-T>', 'open -t')
config.bind('<Ctrl-Tab>', 'tab-focus last')
config.bind('<Ctrl-U>', 'scroll-page 0 -0.5')
config.bind('<Ctrl-V>', 'mode-enter passthrough')
config.bind('<Ctrl-W>', 'tab-close')
# config.bind('<Ctrl-X>', 'navigate decrement')
config.bind('<Ctrl-^>', 'tab-focus last')
config.bind('<Ctrl-h>', 'home')
config.bind('<Ctrl-p>', 'tab-pin')
config.bind('<Ctrl-s>', 'stop')
config.bind('<Escape>', 'clear-keychain ;; search ;; fullscreen --leave')
config.bind('<F11>', 'fullscreen')
config.bind('<F5>', 'reload')
config.bind('<Return>', 'selection-follow')
config.bind('<back>', 'back')
config.bind('<forward>', 'forward')
config.bind('?', 'cmd-set-text ?')
config.bind('@', 'macro-run')
config.bind('B', 'cmd-set-text -s :quickmark-load -t')
config.bind('D', 'tab-close -o')
# config.bind('F', 'hint all tab')
config.bind('F', 'hint all tab-fg')
config.bind('G', 'scroll-to-perc')
config.bind('H', 'back')
config.bind('<Alt-Left>', 'back')
config.bind('J', 'tab-next')
config.bind('K', 'tab-prev')
config.bind('L', 'forward')
config.bind('<Alt-Right>', 'forward')
config.bind('M', 'bookmark-add')
config.bind('N', 'search-prev')
config.bind('O', 'cmd-set-text -s :open -t')
config.bind('W', 'cmd-set-text -s :open -w')
# config.bind('PP', 'open -t -- {primary}')
# config.bind('Pp', 'open -t -- {clipboard}')
config.bind('P', 'open -t -- {clipboard}')
config.bind('R', 'reload -f')
config.bind('Sb', 'bookmark-list --jump')
config.bind('Sh', 'open -t qute://history/')
config.bind('Sq', 'bookmark-list')
config.bind('Ss', 'set')
config.bind('T', 'cmd-set-text -sr :tab-focus')
config.bind('U', 'undo -w')
config.bind('V', 'mode-enter caret ;; selection-toggle --line')
config.bind('ZQ', 'quit')
config.bind('ZZ', 'quit --save')
config.bind('[[', 'navigate prev')
config.bind(']]', 'navigate next')
config.bind('`', 'mode-enter set_mark')
config.bind('ad', 'download-cancel')
config.bind('b', 'cmd-set-text -s :quickmark-load')
config.bind('cd', 'download-clear')
config.bind('co', 'tab-only')
config.bind('d', 'tab-close')
config.bind('Q', 'tab-close')
config.bind('f', 'hint')
config.bind(';f', 'hint')
config.bind('g$', 'tab-focus -1')
config.bind('g0', 'tab-focus 1')
config.bind('gB', 'cmd-set-text -s :bookmark-load -t')
config.bind('gC', 'tab-clone')
config.bind('gD', 'tab-give')
config.bind('gJ', 'tab-move +')
config.bind('gK', 'tab-move -')
config.bind('gO', 'cmd-set-text :open -t -r {url:pretty}')
config.bind('gU', 'navigate up -t')
config.bind('g^', 'tab-focus 1')
config.bind('ga', 'open -t')
config.bind('gb', 'cmd-set-text -s :bookmark-load')
config.bind('gd', 'download')
config.bind('gf', 'view-source')
config.bind('gg', 'scroll-to-perc 0')
config.bind('gi', 'hint inputs --first')
config.bind('gm', 'tab-move')
config.bind('go', 'cmd-set-text :open {url:pretty}')
config.bind('gt', 'cmd-set-text -s :tab-select')
config.bind('gu', 'navigate up')
config.bind('h', 'scroll left')
config.bind('i', 'mode-enter insert')
config.bind('j', 'scroll down')
config.bind('k', 'scroll up')
config.bind('l', 'scroll right')
config.bind('<Ctrl-J>', 'scroll-page 0 0.2')
config.bind('<Ctrl-K>', 'scroll-page 0 -0.2')
config.bind('m', 'quickmark-save')
config.bind('n', 'search-next')
config.bind('o', 'cmd-set-text -s :open')
# config.bind('pP', 'open -- {primary}')
# config.bind('pp', 'open -- {clipboard}')
config.bind('p', 'open -- {clipboard}')
config.bind('q', 'macro-record')
config.bind('r', 'reload')
config.bind('sf', 'save')
config.bind('sk', 'cmd-set-text -s :bind')
config.bind('sl', 'cmd-set-text -s :set -t')
config.bind('ss', 'cmd-set-text -s :set')
config.bind('tCH', 'config-cycle -p -u *://*.{url:host}/* content.cookies.accept all no-3rdparty never ;; reload')
config.bind('tCh', 'config-cycle -p -u *://{url:host}/* content.cookies.accept all no-3rdparty never ;; reload')
config.bind('tCu', 'config-cycle -p -u {url} content.cookies.accept all no-3rdparty never ;; reload')
config.bind('tIH', 'config-cycle -p -u *://*.{url:host}/* content.images ;; reload')
config.bind('tIh', 'config-cycle -p -u *://{url:host}/* content.images ;; reload')
config.bind('tIu', 'config-cycle -p -u {url} content.images ;; reload')
config.bind('tPH', 'config-cycle -p -u *://*.{url:host}/* content.plugins ;; reload')
config.bind('tPh', 'config-cycle -p -u *://{url:host}/* content.plugins ;; reload')
config.bind('tPu', 'config-cycle -p -u {url} content.plugins ;; reload')
config.bind('tSH', 'config-cycle -p -u *://*.{url:host}/* content.javascript.enabled ;; reload')
config.bind('tSh', 'config-cycle -p -u *://{url:host}/* content.javascript.enabled ;; reload')
config.bind('tSu', 'config-cycle -p -u {url} content.javascript.enabled ;; reload')
config.bind('tcH', 'config-cycle -p -t -u *://*.{url:host}/* content.cookies.accept all no-3rdparty never ;; reload')
config.bind('tch', 'config-cycle -p -t -u *://{url:host}/* content.cookies.accept all no-3rdparty never ;; reload')
config.bind('tcu', 'config-cycle -p -t -u {url} content.cookies.accept all no-3rdparty never ;; reload')
config.bind('th', 'back -t')
config.bind('tiH', 'config-cycle -p -t -u *://*.{url:host}/* content.images ;; reload')
config.bind('tih', 'config-cycle -p -t -u *://{url:host}/* content.images ;; reload')
config.bind('tiu', 'config-cycle -p -t -u {url} content.images ;; reload')
config.bind('tl', 'forward -t')
config.bind('tpH', 'config-cycle -p -t -u *://*.{url:host}/* content.plugins ;; reload')
config.bind('tph', 'config-cycle -p -t -u *://{url:host}/* content.plugins ;; reload')
config.bind('tpu', 'config-cycle -p -t -u {url} content.plugins ;; reload')
config.bind('tsH', 'config-cycle -p -t -u *://*.{url:host}/* content.javascript.enabled ;; reload')
config.bind('tsh', 'config-cycle -p -t -u *://{url:host}/* content.javascript.enabled ;; reload')
config.bind('tsu', 'config-cycle -p -t -u {url} content.javascript.enabled ;; reload')
config.bind('u', 'undo')
config.bind('v', 'mode-enter caret')
config.bind('wB', 'cmd-set-text -s :bookmark-load -w')
config.bind('wIf', 'devtools-focus')
config.bind('wIh', 'devtools left')
config.bind('wIj', 'devtools bottom')
config.bind('wIk', 'devtools top')
config.bind('wIl', 'devtools right')
config.bind('wIw', 'devtools window')
config.bind('wO', 'cmd-set-text :open -w {url:pretty}')
config.bind('wP', 'open -w -- {primary}')
config.bind('wb', 'cmd-set-text -s :quickmark-load -w')
config.bind('wf', 'hint all window')
config.bind('wh', 'back -w')
config.bind('wi', 'devtools')
config.bind('<F12>', 'devtools')
config.bind('wl', 'forward -w')
config.bind('wo', 'cmd-set-text -s :open -w')
config.bind('wp', 'open -w -- {clipboard}')
config.bind('xO', 'cmd-set-text :open -b -r {url:pretty}')
config.bind('xo', 'cmd-set-text -s :open -b')
config.bind('yD', 'yank domain -s')
config.bind('yM', 'yank inline [{title}]({url:yank}) -s')
config.bind('yP', 'yank pretty-url -s')
config.bind('yT', 'yank title -s')
config.bind('yY', 'yank -s')
config.bind('yd', 'yank domain')
config.bind('ym', 'yank inline [{title}]({url:yank})')
config.bind('yp', 'yank pretty-url')
config.bind('yt', 'yank title')
config.bind('yy', 'yank')
config.bind('{{', 'navigate prev -t')
config.bind('}}', 'navigate next -t')

## Bindings for caret mode
config.bind('$', 'move-to-end-of-line', mode='caret')
config.bind('0', 'move-to-start-of-line', mode='caret')
config.bind('<Ctrl-Space>', 'selection-drop', mode='caret')
config.bind('<Escape>', 'mode-leave', mode='caret')
config.bind('<Return>', 'yank selection', mode='caret')
config.bind('<Space>', 'selection-toggle', mode='caret')
config.bind('G', 'move-to-end-of-document', mode='caret')
config.bind('H', 'scroll left', mode='caret')
config.bind('J', 'scroll down', mode='caret')
config.bind('K', 'scroll up', mode='caret')
config.bind('L', 'scroll right', mode='caret')
config.bind('V', 'selection-toggle --line', mode='caret')
config.bind('Y', 'yank selection -s', mode='caret')
config.bind('[', 'move-to-start-of-prev-block', mode='caret')
config.bind(']', 'move-to-start-of-next-block', mode='caret')
config.bind('b', 'move-to-prev-word', mode='caret')
config.bind('c', 'mode-enter normal', mode='caret')
config.bind('e', 'move-to-end-of-word', mode='caret')
config.bind('gg', 'move-to-start-of-document', mode='caret')
config.bind('h', 'move-to-prev-char', mode='caret')
config.bind('j', 'move-to-next-line', mode='caret')
config.bind('k', 'move-to-prev-line', mode='caret')
config.bind('l', 'move-to-next-char', mode='caret')
config.bind('o', 'selection-reverse', mode='caret')
config.bind('v', 'selection-toggle', mode='caret')
config.bind('w', 'move-to-next-word', mode='caret')
config.bind('y', 'yank selection', mode='caret')
config.bind('{', 'move-to-end-of-prev-block', mode='caret')
config.bind('}', 'move-to-end-of-next-block', mode='caret')

## Bindings for command mode
config.bind('<Alt-B>', 'rl-backward-word', mode='command')
config.bind('<Alt-Backspace>', 'rl-backward-kill-word', mode='command')
config.bind('<Alt-D>', 'rl-kill-word', mode='command')
config.bind('<Alt-F>', 'rl-forward-word', mode='command')
config.bind('<Ctrl-?>', 'rl-delete-char', mode='command')
config.bind('<Ctrl-A>', 'rl-beginning-of-line', mode='command')
config.bind('<Ctrl-B>', 'rl-backward-char', mode='command')
config.bind('<Ctrl-C>', 'completion-item-yank', mode='command')
config.bind('<Ctrl-D>', 'completion-item-del', mode='command')
config.bind('<Shift-Delete>', 'completion-item-del', mode='command')
config.bind('<Ctrl-E>', 'rl-end-of-line', mode='command')
config.bind('<Ctrl-F>', 'rl-forward-char', mode='command')
config.bind('<Ctrl-H>', 'rl-backward-delete-char', mode='command')
config.bind('<Ctrl-K>', 'rl-kill-line', mode='command')
config.bind('<Ctrl-N>', 'command-history-next', mode='command')
config.bind('<Ctrl-P>', 'command-history-prev', mode='command')
config.bind('<Ctrl-Return>', 'command-accept --rapid', mode='command')
config.bind('<Ctrl-Shift-C>', 'completion-item-yank --sel', mode='command')
config.bind('<Ctrl-Shift-Tab>', 'completion-item-focus prev-category', mode='command')
config.bind('<Ctrl-Shift-P>', 'completion-item-focus prev-category', mode='command')
config.bind('<Ctrl-Tab>', 'completion-item-focus next-category', mode='command')
config.bind('<Ctrl-Shift-N>', 'completion-item-focus next-category', mode='command')
config.bind('<Ctrl-Shift-W>', 'rl-filename-rubout', mode='command')
config.bind('<Ctrl-U>', 'rl-unix-line-discard', mode='command')
config.bind('<Ctrl-W>', 'rl-rubout " "', mode='command')
config.bind('<Ctrl-Y>', 'rl-yank', mode='command')
config.bind('<Escape>', 'mode-leave', mode='command')
config.bind('<PgDown>', 'completion-item-focus next-page', mode='command')
config.bind('<PgUp>', 'completion-item-focus prev-page', mode='command')
config.bind('<Return>', 'command-accept', mode='command')
config.bind('<Ctrl-P>', 'completion-item-focus prev', mode='command')
config.bind('<Ctrl-N>', 'completion-item-focus next', mode='command')
config.bind('<Shift-Tab>', 'completion-item-focus prev', mode='command')
config.bind('<Tab>', 'completion-item-focus next', mode='command')
config.bind('<Up>', 'completion-item-focus --history prev', mode='command')
config.bind('<Down>', 'completion-item-focus --history next', mode='command')

## Bindings for hint mode
config.bind('<Ctrl-B>', 'hint all tab-bg', mode='hint')
config.bind('<Ctrl-F>', 'hint links', mode='hint')
config.bind('<Ctrl-R>', 'hint --rapid links tab-bg', mode='hint')
config.bind('<Escape>', 'mode-leave', mode='hint')
config.bind('<Return>', 'hint-follow', mode='hint')

## Bindings for insert mode
config.bind('<Ctrl-E>', 'edit-text', mode='insert')
config.bind('<Escape>', 'mode-leave ;; jseval -q document.activeElement.blur()', mode='insert')
config.bind('<Shift-Escape>', 'fake-key <Escape>', mode='insert')
config.bind('<Shift-Ins>', 'insert-text -- {primary}', mode='insert')
config.bind('<Ctrl-T>', 'open -t', mode='insert')
config.bind('<Ctrl-W>', 'tab-close', mode='insert')
config.bind('<Alt-Left>', 'back', mode='insert')
config.bind('<Alt-Right>', 'forward', mode='insert')
config.bind('<F5>', 'reload', mode='insert')
config.bind('<F11>', 'fullscreen', mode='insert')

## Bindings for passthrough mode
config.bind('<Shift-Escape>', 'mode-leave', mode='passthrough')
config.bind('<Ctrl-T>', 'open -t', mode='passthrough')
config.bind('<Ctrl-W>', 'tab-close', mode='passthrough')
config.bind('<Alt-Left>', 'back', mode='passthrough')
config.bind('<Alt-Right>', 'forward', mode='passthrough')
config.bind('<F5>', 'reload', mode='passthrough')
config.bind('<F11>', 'fullscreen', mode='passthrough')

## Bindings for prompt mode
config.bind('<Alt-B>', 'rl-backward-word', mode='prompt')
config.bind('<Alt-Backspace>', 'rl-backward-kill-word', mode='prompt')
config.bind('<Alt-D>', 'rl-kill-word', mode='prompt')
config.bind('<Alt-E>', 'prompt-fileselect-external', mode='prompt')
config.bind('<Alt-F>', 'rl-forward-word', mode='prompt')
config.bind('<Alt-Shift-Y>', 'prompt-yank --sel', mode='prompt')
config.bind('<Alt-Y>', 'prompt-yank', mode='prompt')
config.bind('<Ctrl-?>', 'rl-delete-char', mode='prompt')
config.bind('<Ctrl-A>', 'rl-beginning-of-line', mode='prompt')
config.bind('<Ctrl-B>', 'rl-backward-char', mode='prompt')
config.bind('<Ctrl-E>', 'rl-end-of-line', mode='prompt')
config.bind('<Ctrl-F>', 'rl-forward-char', mode='prompt')
config.bind('<Ctrl-H>', 'rl-backward-delete-char', mode='prompt')
config.bind('<Ctrl-K>', 'rl-kill-line', mode='prompt')
config.bind('<Ctrl-P>', 'prompt-open-download --pdfjs', mode='prompt')
config.bind('<Ctrl-Shift-W>', 'rl-filename-rubout', mode='prompt')
config.bind('<Ctrl-U>', 'rl-unix-line-discard', mode='prompt')
config.bind('<Ctrl-W>', 'rl-rubout " "', mode='prompt')
config.bind('<Ctrl-X>', 'prompt-open-download', mode='prompt')
config.bind('<Ctrl-Y>', 'rl-yank', mode='prompt')
config.bind('<Down>', 'prompt-item-focus next', mode='prompt')
config.bind('<Escape>', 'mode-leave', mode='prompt')
config.bind('<Return>', 'prompt-accept', mode='prompt')
config.bind('<Shift-Tab>', 'prompt-item-focus prev', mode='prompt')
config.bind('<Tab>', 'prompt-item-focus next', mode='prompt')
config.bind('<Up>', 'prompt-item-focus prev', mode='prompt')

## Bindings for register mode
config.bind('<Escape>', 'mode-leave', mode='register')

## Bindings for yesno mode
config.bind('<Alt-Shift-Y>', 'prompt-yank --sel', mode='yesno')
config.bind('<Alt-Y>', 'prompt-yank', mode='yesno')
config.bind('<Escape>', 'mode-leave', mode='yesno')
config.bind('<Return>', 'prompt-accept', mode='yesno')
config.bind('N', 'prompt-accept --save no', mode='yesno')
config.bind('Y', 'prompt-accept --save yes', mode='yesno')
config.bind('n', 'prompt-accept no', mode='yesno')
config.bind('y', 'prompt-accept yes', mode='yesno')

config.bind('<Alt-Shift-D>', 'spawn --userscript darkmode-toggle')
config.bind('<Alt-Shift-D>', 'spawn --userscript darkmode-toggle', mode='insert')
config.bind('<Alt-Shift-D>', 'spawn --userscript darkmode-toggle', mode='passthrough')
config.bind('<Alt-Shift-D>', 'spawn --userscript darkmode-toggle', mode='caret')

config.bind('<Alt-T>', 'spawn --userscript translate-selection')
config.bind('<Alt-T>', 'spawn --userscript translate-selection', mode='insert')
config.bind('<Alt-T>', 'spawn --userscript translate-selection', mode='passthrough')
config.bind('<Alt-T>', 'spawn --userscript translate-selection', mode='caret')

# -----------------------------------------------------------------------------
# Colors
# -----------------------------------------------------------------------------

c.colors.tabs.even.bg = '#444444'
c.colors.tabs.even.fg = 'white'
c.colors.tabs.odd.bg = '#5e5e5e'
c.colors.tabs.odd.fg = 'white'
c.colors.tabs.pinned.selected.even.bg = 'black'
c.colors.tabs.pinned.selected.even.fg = 'white'
c.colors.tabs.pinned.selected.odd.bg = 'black'
c.colors.tabs.pinned.selected.odd.fg = 'white'
c.colors.tabs.selected.even.bg = 'black'
c.colors.tabs.selected.even.fg = 'white'
c.colors.tabs.selected.odd.bg = 'black'
c.colors.tabs.selected.odd.fg = 'white'

c.colors.webpage.darkmode.algorithm = 'lightness-cielab'
c.colors.webpage.darkmode.enabled = False
c.colors.webpage.darkmode.policy.images = 'never'
c.colors.webpage.darkmode.policy.page = 'smart'
c.colors.webpage.darkmode.threshold.background = 0
c.colors.webpage.darkmode.threshold.foreground = 256
c.colors.webpage.preferred_color_scheme = 'auto'

# -----------------------------------------------------------------------------
# Fonts
# -----------------------------------------------------------------------------

c.fonts.default_family = ['NotoSerif', 'Hack Nerd Font', 'Noto Color Emoji']
c.fonts.default_size = '10pt'

# -----------------------------------------------------------------------------
# Site specific settings
# -----------------------------------------------------------------------------

with config.pattern('*://challenges.cloudflare.com/*') as p:
    p.content.headers.user_agent = 'Mozilla/5.0 ({os_info}) AppleWebKit/{webkit_version} (KHTML, like Gecko) {qt_key}/{qt_version} {upstream_browser_key}/{upstream_browser_version} Safari/{webkit_version}vi'
