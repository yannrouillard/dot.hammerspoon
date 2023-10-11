-- Global configuration
config = {
    GITHUB_USERNAME = "yannrouillard",

    HYPER = {"cmd", "alt", "ctrl", "shift"},

    SPOONS_PERSONAL_REPOS = {
        url = "https://github.com/yannrouillard/iSpoons",
        branch = "main"
    },

    SOURCE_CODE_ROOT_FOLDERS = {
        work = os.getenv("HOME") .. "/dev/work/",
        personal = os.getenv("HOME") .. "/dev/personal/"
    }
}
-- allow local override
require("local_config")

-- The one spoon we install manually to help us install all the others

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
spoon.SpoonInstall.repos.default = config.SPOONS_PERSONAL_REPOS
SpoonInstall = spoon.SpoonInstall

-- Load some helpers spoons providing useful functions to other spoons

SpoonInstall:andUse("Iterm2")
SpoonInstall:andUse("VsCode", {
    config = {
        sourceCodeRootDirectories = {config.SOURCE_CODE_ROOT_FOLDERS.work, config.SOURCE_CODE_ROOT_FOLDERS.personal,
                                     os.getenv("HOME")}
    }
})

-- Automatic Keyboard Language switch depending on application

SpoonInstall:andUse("InputSourceAutoSwitch", {
    config = {
        inputSourcePerApplication = {
            ["Code"] = "US",
            ["Visual Studio Code"] = "US",
            ["iTerm2"] = "US",
            ["Firefox"] = "USInternational-PC",
            ["Slack"] = "USInternational-PC",
            ["\xE2\x80\x8EWhatsApp"] = "USInternational-PC",
            ["WhatsApp"] = "USInternational-PC",
            ["Signal"] = "USInternational-PC",
            ["Telegram"] = "USInternational-PC"
        }
    },
    start = true
})

-- Auto-switch full-screen mode for launched applications

SpoonInstall:andUse("AutoMaximize", {
    config = {
        exclusions = {"Hammerspoon", "coreautha", "calibre", "Wireshark", "Color Picker", "DBeaver"}
    },
    start = true
})

-- Keyboard shortcut to quickly move windows and focus between screens

SpoonInstall:andUse("MoveWindowsOnScreens", {
    hotkeys = {
        moveWindowLeft = {{"cmd", "shift"}, "h"},
        moveWindowRight = {{"cmd", "shift"}, "l"},
        focusWindowLeft = {{"cmd", "shift"}, "j"},
        focusWindowRight = {{"cmd", "shift"}, "k"},
        switchWindowLeftAndRight = {{"cmd", "shift"}, "s"},
        placeSelectedWindowOnTheRight = {{"cmd", "shift"}, "v"}
    }
})

-- Automatic Adjustement of sounds for Videoconference

SpoonInstall:andUse("VideoConfAutoSound", {
    config = {
        videoConferenceVolume = 85
    },
    start = true
})

-- Switch between application with one letter
-- and when possible activate the relevant window/tab in the target application

SpoonInstall:andUse("SmartAppSwitcher", {
    config = {
        modifiers = config.HYPER,
        helperSpoons = {
            ["iTerm"] = spoon.Iterm2,
            ["Visual Studio Code"] = spoon.VsCode
        }
    },
    hotkeys = {
        c = "Visual Studio Code",
        o = "Obsidian",
        f = "Firefox",
        k = "Slack",
        s = "Spotify",
        i = "iTerm"
    },
    loglevel = "debug"
})

-- Display Pull Requests waiting for review in my menubar
-- This spoon is custom private one

hs.loadSpoon("PullRequestsMenubar")
spoon.PullRequestsMenubar.githubUsername = config.GITHUB_USERNAME

-- Work On / Work Off quick functions
-- Must be loaded before Seal so its exported actions are automatically available in Seal

local closeWorkRelatedItermTabs = function()
    spoon.Iterm2.closeMatchingTabs(config.SOURCE_CODE_ROOT_FOLDERS.work)
end
local closeWorkRelatedVsCodeWindows = function()
    spoon.VsCode.closeMatchingWindows(config.SOURCE_CODE_ROOT_FOLDERS.personal)
end

SpoonInstall:andUse("WorkOnOff", {
    config = {
        applications = {
            startstop = {"Slack", "MeetingBar", "Clocker"},
            stop = {"Bitwarden", "Obsidian"}
        },
        urls = {"obsidian://advanced-uri?vault=Work&daily=true"},
        spoons = {spoon.PullRequestsMenubar},
        functions = {
            stop = {closeWorkRelatedItermTabs, closeWorkRelatedVsCodeWindows}
        }
    }
})

-- Useful quick toggle functions (dark mode, sidecar...)
-- Must be loaded before Seal so its exported actions are automatically available in Seal

SpoonInstall:andUse("Toggler")

-- Best Launcher ever!

local sealPlugins =
    {"apps", "useractions", "filesearch", "firefox", "devops_search", "spoons_actions", "quick_contacts"}

local sealUserActions = {
    ["daily note"] = {
        url = "obsidian://advanced-uri?vault=Work&commandname=Periodic Notes: Open daily note",
        icon = hs.image.imageFromPath(hs.configdir .. "/assets/obsidian.png")
    },
    ["new note"] = {
        url = "obsidian://advanced-uri?vault=Work&filepath=Inbox/New Note.md&mode=new",
        icon = hs.image.imageFromPath(hs.configdir .. "/assets/obsidian.png")
    },
    ["Reload Hammerspoon"] = {
        fn = hs.reload
    }
}

SpoonInstall:andUse("Seal", {
    hotkeys = {
        show = {{"cmd"}, "space"}
    },
    fn = function(seal)
        seal:loadPlugins(sealPlugins)
        seal.plugins.useractions.actions = sealUserActions
        seal.plugins.quick_contacts.contacts_file = hs.configdir .. "/contacts/contacts_list.json"
    end,
    start = true
})

-- Miscallaneous configuration

hs.hotkey.bind({"cmd", "alt"}, "V", function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)
