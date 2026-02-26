# ruff: noqa: F821
# pyright: reportUndefinedVariable=false
# `config` and `c` are globals injected by qutebrowser

config.load_autoconfig(False)
config.source('theme.py')

# Font configuration
c.fonts.default_family = 'GeistMono Nerd Font'
c.fonts.default_size = '13pt'

# Tab padding
c.tabs.padding = {'top': 6, 'bottom': 6, 'left': 16, 'right': 10}
c.tabs.indicator.width = 3
c.tabs.indicator.padding = {'top': 4, 'bottom': 4, 'left': 2, 'right': 6}

# Dark mode
c.colors.webpage.darkmode.enabled = False
c.colors.webpage.preferred_color_scheme = 'auto'

# Ctrl+j/k to navigate completion lists
config.bind('<Ctrl-j>', 'completion-item-focus next', mode='command')
config.bind('<Ctrl-k>', 'completion-item-focus prev', mode='command')

# Completion settings
c.completion.shrink = True  # Shrink to fit content
c.completion.timestamp_format = '%Y-%m-%d'  # Shorter date format
c.completion.use_best_match = True

# Tab navigation with Ctrl+h/l
config.bind('<Ctrl-h>', 'tab-prev')
config.bind('<Ctrl-l>', 'tab-next')

# Move tabs left/right with Ctrl+Shift+h/l
config.bind('<Ctrl-Shift-h>', 'tab-move -')
config.bind('<Ctrl-Shift-l>', 'tab-move +')

# Break out tab to new window / join tab to another window
config.bind('<Ctrl-Shift-k>', 'tab-give')
config.bind('<Ctrl-Shift-j>', 'tab-give 0')

# Restore tabs from last session on startup
c.auto_save.session = True

# Uncap frame rate (workaround for QTBUG-76006 - WebEngine assumes 60Hz)
c.qt.args = ['disable-frame-rate-limit']

# Smooth scrolling for keyboard navigation
c.scrolling.smooth = True

# Bitwarden password fill using rbw
# Ctrl-b: fill both username and password
# Ctrl-Shift-b: fill username only
# Ctrl-Shift-p: fill password only
config.bind('<Ctrl-b>', 'spawn --userscript qute-rbw')
config.bind('<Ctrl-Shift-b>', 'spawn --userscript qute-rbw --username-only')
config.bind('<Ctrl-Shift-p>', 'spawn --userscript qute-rbw --password-only')
config.bind('<Ctrl-b>', 'spawn --userscript qute-rbw', mode='insert')
config.bind('<Ctrl-Shift-b>', 'spawn --userscript qute-rbw --username-only', mode='insert')
config.bind('<Ctrl-Shift-p>', 'spawn --userscript qute-rbw --password-only', mode='insert')

# Ad blocking
c.content.blocking.method = 'both'
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/annoyances-cookies.txt",
]
