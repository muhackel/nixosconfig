--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

import XMonad
import Data.Monoid
import System.Exit
import Data.Ratio ((%))
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Actions.CycleWS
import XMonad.Actions.CopyWindow
import XMonad.Actions.DynamicProjects
import XMonad.Actions.SpawnOn
import XMonad.Actions.WindowGo

import XMonad.Layout.Tabbed
import XMonad.Layout.PerWorkspace
import XMonad.Layout.IM
import XMonad.Layout.Reflect
import XMonad.Layout.NoBorders
import XMonad.Layout.Grid

import XMonad.Util.EZConfig
import XMonad.Util.Paste
import XMonad.Util.SpawnOnce
import XMonad.Util.NamedScratchpad

import XMonad.Prompt                        
import XMonad.Prompt.ConfirmPrompt          
import XMonad.Prompt.Input
import XMonad.Prompt.Shell

import XMonad.ManageHook
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.SetWMName
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.ManageHelpers



-- Command to launch the bar.
myBar = "dzen2 -xs 1 -fn 'Hack Nerd Font:size=9:normal' -dock -ta l -w 1760 -h 16 -e ''"

-- Custom PP, configure it as you like. It determines what is being written to the bar.
myPP = filterOutWsPP [scratchpadWorkspaceTag] $ def { ppCurrent  = dzenColor "red" "black" . pad
                   , ppVisible  = dzenColor "white" "black" . pad
                   , ppHidden   = dzenColor "white" "black" . pad
                   , ppHiddenNoWindows = dzenColor "#999999" "black" . pad -- . const ""
                   , ppUrgent   = dzenColor "yellow" "red" . pad
                   , ppWsSep    = "|"
                   , ppSep      = "||"
                   , ppLayout   = dzenColor "green" "black" .
                                  (\ x -> pad $ case x of
                                            "TilePrime Horizontal" -> "TTT"
                                            "TilePrime Vertical"   -> "[]="
                                            "Hinted Full"          -> "[ ]"
                                            _                      -> x
                                  )
                   , ppTitle    = ("^bg(#000000) " ++) . dzenEscape
                   }

-- Key binding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "alacritty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 1  

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    =  ["1:shell","2:emacs","3:office","4:graphics","5:remote","6:emulation","7:vm","8:web","9:com"] 


--projects :: [Project]
projects = 
  [ Project { projectName      = "1:shell"
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawnOn "1:shell" "alacritty"
            }
    
  , Project { projectName      = "2:emacs"
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawnOn "2:emacs" "emacsclient -c"
--                                           spawnOn "2:emacs" "code"
            }
    
  , Project { projectName      = "3:office"
            , projectDirectory = "~/Documents"
            , projectStartHook = Nothing
            }
    
  , Project { projectName      = "4:graphics"
            , projectDirectory = "~/Pictures"
            , projectStartHook = Nothing
            }
    
  , Project { projectName      = "7:vm"
            , projectDirectory = "~/VirtualBox VMs"
            , projectStartHook = Just $ do spawnOn "7:vm" "VirtualBox"
            }
    
  , Project { projectName      = "8:web"
            , projectDirectory = "~/Downloads"
            , projectStartHook = Just $ do spawnOn "8:web" "google-chrome-stable"
            }
    
  , Project { projectName      = "9:com"
            , projectDirectory = "~/Documents"
            , projectStartHook = Just $ do spawnOn "9:com" "evolution"
                                           spawnOn "9:com" "ferdium"
                                           spawnOn "9:com" "hexchat"
            }
 
  ]


scratchpads = [
-- run htop in xterm, find it by title, use default floating window placement
    NS "htop" "alacritty -e htop" (title =? "htop") (customFloating $ W.RationalRect (1/32) (1/32) (30/32) (30/32)),

--    NS "irssi" "urxvtc -T irssi -e screen -t irssi -S irssi -xR irssi" (title =? "irssi") (customFloating $ W.RationalRect (1/32) (1/32) (30/32) (30/32)),
--    NS "hexchat" "hexchat" (className =? "Hexchat") (customFloating $ W.RationalRect (1/32) (1/32) (30/32) (30/32)),
    
    NS "conky" "conky -c .conkyonewindow" (title =? "conky (HAL9000)") defaultFloating ,  

-- run stardict, find it by class name, place it in the floating window
-- 1/6 of screen width from the left, 1/6 of screen height
-- from the top, 2/3 of screen width by 2/3 of screen height
    NS "stardict" "stardict" (className =? "Stardict")
        (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)) ,

-- run gvim, find by role, don't float
    NS "notes" "gvim --role notes ~/notes.txt" (role =? "notes") nonFloating
    ] where role = stringProperty "WM_WINDOW_ROLE"


-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"

myKeys2 = \c -> mkKeymap c $
  [("M-q"        ,confirmPrompt hotPromptTheme "Restart XMonad" $ spawn "xmonad --recompile; killall dzen2; killall trayer; killall stalonetray; killall xmobar; xmonad --estart")
  ,("M-S-q"      ,confirmPrompt hotPromptTheme "Quit XMonad" $ io (exitWith ExitSuccess))
  ,("M-p", spawn "rofi -show run -theme dmenu")--shellPrompt hotPromptTheme)
  ,("M-S-p", spawn "rofi -show drun -show-icons")
  
  ] 

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modm .|. controlMask .|. mod1Mask, xK_space), namedScratchpadAction scratchpads "conky")
    , ((modm .|. controlMask .|. mod1Mask, xK_h), namedScratchpadAction scratchpads "htop")
    --, ((modm .|. controlMask .|. mod1Mask, xK_i), namedScratchpadAction scratchpads "hexchat")
    , ((modm,               xK_s     ), switchProjectPrompt warmPromptTheme)
    , ((modm .|. shiftMask, xK_s     ), shiftToProjectPrompt warmPromptTheme)
    -- launch rofi run
    , ((modm,               xK_p     ), spawn "rofi -show run -theme dmenu")--shellPrompt hotPromptTheme) --spawn "rofi -show run")
    -- launch rofi drun
    , ((modm .|. shiftMask, xK_p     ), spawn "rofi -show drun -show-icons")
    -- launch rofi ssh
 --   , ((modm,               xK_s     ), spawn "rofi -show ssh")
    -- launch rofi window
    , ((modm,               xK_a     ), spawn "rofi -show window") --lauch filemanager
    , ((modm,               xK_f     ), spawn "caja")
    , ((modm .|. shiftMask, xK_f     ), spawn "alacritty -e ranger")
    -- launch mpc menu
    , ((modm,               xK_n     ), spawn "rofi-mpc")
    , ((modm .|. shiftMask, xK_n     ), spawn "alacritty -e ncmpcpp")
    -- launch bt connect menu
    , ((modm .|. shiftMask, xK_b     ), spawn "btmenu")
    -- launch chrome
    , ((0,                 0x1008FF30), spawn "google-chrome-stable")

    -- launch irssi
    --, ((modm,              xK_i      ), spawn "urxvtc -title irssi -e screen -S irssi -xR irssi")

    -- launch emacs
    , ((modm,              xK_o      ), spawn "emacsclient -nc")

    -- launch mpsyt
    , ((modm .|. shiftMask, xK_y ), spawn "alacritty -e mpsyt")

    
    , ((modm,               xK_v ), windows copyToAll) -- @@ Make focused window always visible
    , ((modm .|. shiftMask, xK_v ), killAllOtherCopies) -- @@ Toggle window state back
    
    -- Brightness handling
    , ((0,                 0x1008FF02), spawn "xbacklight -inc 10")
    , ((0,                 0x1008FF03), spawn "xbacklight -dec 10")

    -- xrandr
    , ((0,                 0x1008FF59), spawn "rofi-autorandr && xmonad --recompile; killall dzen2; killall trayer; killall stalonetray; killall xmobar; xmonad --restart")

    -- Volume handling
    , ((0,                 0x1008FF13) ,spawn "pamixer -i 5")
    , ((0,                 0x1008FF11) ,spawn "pamixer -d 5")
    , ((0,                 0x1008FF12) ,spawn "pamixer -t")
    , ((0,                 0x1008FFB2) ,spawn "pamixer --default-source -t")
    
    -- Touchpad handling
    , ((0,                 0x1008ffa9) ,spawn "touchpadtoogle.sh") --synclient TouchpadOff=$(synclient -l | grep -c 'TouchpadOff.*=.*0')")
    -- close focused window 
    , ((modm .|. shiftMask, xK_c     ), kill1)
    , ((modm .|. shiftMask .|. controlMask , xK_c      ),kill)
    -- urgend keybindigs
    , ((modm              , xK_BackSpace), focusUrgent)
    , ((modm .|. shiftMask, xK_BackSpace), clearUrgents)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm .|. shiftMask, xK_m     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    --, ((modm .|. shiftMask, xK_b     ), sendMessage ToggleStruts)

    -- X-selection-paste buffer
    , ((modm, xK_Insert), pasteSelection)
    
    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), confirmPrompt hotPromptTheme "Quit XMonad" $ io (exitWith ExitSuccess)) --io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), confirmPrompt hotPromptTheme "Restart XMonad" $ spawn "xmonad --recompile; killall dzen2; killall trayer; killall stalonetray; killall xmobar; xmonad --restart")

    -- Lock session
    --, ((0                 , 0x1008ff2d ), spawn "i3lock") -- -fo -r 5 -s 3 -l")
    -- Poweroff
    , ((0                 , 0x1008ff2a ), confirmPrompt hotPromptTheme "Poweroff?" $ spawn "poweroff")
    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))

    , ((modm              , xK_Right ), nextWS)
    , ((modm              , xK_Left  ), prevWS)
    , ((modm.|.shiftMask  , xK_Right ), shiftToNext >> nextWS )
    , ((modm.|.shiftMask  , xK_Left  ), shiftToPrev >> prevWS )
    , ((modm              , xK_Up    ), nextScreen)
    , ((modm              , xK_Down  ), prevScreen)
    , ((modm.|.shiftMask  , xK_Up    ), shiftNextScreen)
    , ((modm.|.shiftMask  , xK_Down  ), shiftPrevScreen)
    , ((modm              , xK_z     ), toggleWS)
    ]
    ++

    -- mod-[1..9] @@ Switch to workspace N
    -- mod-shift-[1..9] @@ Move client to workspace N
    -- mod-control-shift-[1..9] @@ Copy client to workspace N
    [((m .|. modm, k), windows $ f i)
    | (i, k) <- zip (XMonad.workspaces conf) ([xK_1 .. xK_9] ++ [xK_0])
    , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask), (copy, shiftMask .|. controlMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))
    , ((modm, button4), (\_ -> prevWS))
    , ((modm, button5), (\_ -> nextWS))
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--  onWorkspace "im" (reflectHoriz (withIM (1%7) (Title "Buddy List")  simpleTabbed)) 
myLayout =  onWorkspaces ["2:emacs","3:office","4:graphics","5:remote","6:emulation","8:web","9:com"] (smartBorders simpleTabbed ||| smartBorders tiled ||| smartBorders Grid ||| smartBorders Full) $ onWorkspaces ["7:vm"] ( smartBorders Full) $ smartBorders tiled ||| smartBorders Grid ||| smartBorders simpleTabbed ||| smartBorders Full 
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 65/100

     -- Percent of screen to increment by when resizing panes
     delta   = 5/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook =  composeAll  . concat $
        [ [ resource  =? r --> doIgnore                    | r <- myIgnores ]
        , [ className =? c --> doShift (myWorkspaces !! 7) | c <- myWebS    ]
        , [ className =? c --> doShift (myWorkspaces !! 1) | c <- myCodeS   ]
        , [ className =? c --> doShift (myWorkspaces !! 2) | c <- myOfficeS ]
        , [ className =? n --> doShift (myWorkspaces !! 2) | n <- myOfficeN ]
        , [ name      =? n --> doShift (myWorkspaces !! 3) | n <- myGfxN    ]
        , [ className =? c --> doShift (myWorkspaces !! 3) | c <- myGfxS    ]
        , [ name      =? n --> doShift (myWorkspaces !! 8) | n <- myChatS   ]
        , [ className =? c --> doShift (myWorkspaces !! 6) | c <- myVMs     ]
        , [ className =? c --> doShift (myWorkspaces !! 5) | c <- myEmu     ]
        , [ className =? c --> doShift (myWorkspaces !! 4) | c <- myRemote  ]
        , [ className =? c --> doFloat                     | c <- myFloatCC ]
        , [ name      =? n --> doFloat                     | n <- myFloatCN ]
        , [ name      =? n --> doFloat                     | n <- myFloatSN ]
        , [ className =? c --> doF W.focusDown             | c <- myFocusDC ]
--      , [ W.currentTag =? (myWorkspaces !! 2) --> keepMaster "Chrome"        ]
        , [ isFullscreen   --> doFullFloat ]
        , [ namedScratchpadManageHook scratchpads ]
        ] where
                name      = stringProperty "WM_NAME"
                myIgnores = ["desktop", "desktop_window"]
                myWebS    = ["Chromium", "Firefox", "Opera", "qutebrowser", "Navigator", "firefox", "Google-chrome", "google-chrome"]
                myCodeS   = ["Emacs","Code","code"]
                myVMs     = ["Vmware","VirtualBox Machine","VirtualBox Manager"]
                myEmu     = ["Crossover"]
                myRemote  = ["org.remmina.Remmina"]
                myOfficeS = ["libreoffice-startcenter"]
                myOfficeN = ["LibreOffice"]
                myChatS   = ["Discord", "TeamSpeak 3", "WhatsApp", "threemawebqt", "Ferdium"]
                myGfxS    = ["Inkscape", "inkscape", "qcad-bin", "QCAD", "librecad", "LibreCAD", "freecad", "FreeCAD", "draw.io"]
                myGfxN    = ["Gimp", "gimp", "GIMP","GNU Image Manipulation Program", "yEd"]
                myFloatCC = ["MPlayer", "mplayer2", "vlc", "zsnes", "Gcalctool", "Exo-helper-1"
                            , "Gksu", "Galculator", "Nvidia-settings", "XFontSel", "XCalc", "XClock"
                            , "Ossxmix", "Xvidcap", "Main", "Pavucontrol", "mpv" , "Modem-manager-gui"
                            , "Nm-connection-editor", "Blueman-manager", "ConfigTool"
                            , "Blueman-services", "Blueman-applet", "Blueman-assistant", "AusweisApp2"]
                myFloatCN = ["Choose a file", "Open Image", "File Operation Progress", "Firefox Preferences"
                            , "Preferences", "Search Engines", "Set up sync", "Passwords and Exceptions"
                            , "Autofill Options", "Rename File", "Copying files", "Moving files"
                            , "File Properties", "Replace", "Quit GIMP", "Change Foreground Color"
                            , "Change Background Color", "Picture in picture"]
                myFloatSN = ["Event Tester"]
                myFocusDC = ["Event Tester", "Notify-osd"]
                keepMaster c = assertSlave <+> assertMaster where
                        assertSlave = fmap (/= c) className --> doF W.swapDown
                        assertMaster = className =? c --> doF W.swapMaster
                        
--    [ className =? "MPlayer"        --> doFloat
--    , className =? "Gimp"           --> doFloat
--    , className =? "mpv"            --> doFloat
--    , resource  =? "desktop_window" --> doIgnore
--    , resource  =? "kdesktop"       --> doIgnore ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
--myEventHook = mempty
--myEventHook = ewmhDesktopsEventHook
------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  setWMName "LG3D"
  --spawnOnce "xrandr --auto"
  spawn "autorandr -c"
  --spawnOnce "urxvtd -q -o -f && sleep 1 && urxvtc"
  spawnOnce "alacritty"
  spawnOnce "dunst"
  spawnOnce "pactl upload-sample /usr/share/sounds/freedesktop/stereo/bell.oga x11-bell"
  spawnOnce "pactl load-module module-x11-bell sample=x11-bell display=$DISPLAY"
  --spawnOnce "xss-lock i3lock"
  spawn "feh --bg-scale /home/muhackel/background.png"
--  spawn "trayer --edge top --align right --SetDockType true --SetPartialStrut true  --transparent true --monitor primary --alpha 0  --tint 0 --widthtype request --height 16"
  spawn "stalonetray"
--  spawn "gnome-panel"
--  spawn "setxkbmap de"
  spawn "conky | dzen2 -xs 1 -fn 'Hack Nerd Font:size=8' -y -12 -dock -ta r -xs 1 -h 12 -e ''"
--  spawn "conky -c .conkyrcbackground"
--  spawn "conky -c .conkyrcbackground2"
--  spawn "conky -c .conkyrcbackground3"
  spawnOnce "sleep 3 && pasystray -N sink -N source"
  spawnOnce "picom"
--  spawnOnce "modem-manager-gui -i"
  spawnOnce "nm-applet"
  spawnOnce "blueman-applet"
  spawn "aplay ~/imsorry.wav"
  spawnOnce "AusweisApp2"
  spawnOnce "syncthing-gtk"
  spawnOnce "solaar -w hide"
  spawnOnce "optimus-manager-qt"
  spawnOnce "caffeine"
  spawnOnce "redshift-gtk -l 48.775845:9.182932"
--  spawnOnce "vmware-tray"
  spawnOnce "sudo rfcomm bind rfcomm0 20:19:05:06:22:99"
  spawn "xinput --map-to-output 'Raydium Corporation Raydium Touch System' eDP1"
  spawn "xinput --map-to-output 'ILITEK Multi-Touch-V5100' HDMI2"
--  spawn "xinput set-prop 15 374 0"

  
------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
  bar <- statusBar myBar  myPP toggleStrutsKey defaults
  xmonad
    . ewmh
    . ewmhFullscreen
    . dynamicProjects projects
    . withUrgencyHook NoUrgencyHook $ bar
    

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        XMonad.workspaces  = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = avoidStruts $ myLayout,
        manageHook         = manageSpawn <+> myManageHook <+> manageDocks,
        --handleEventHook    = myEventHook <+> fullscreenEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]

base03  = "#898989"
base02  = "#CCCCCC"
base01  = "#111111"
base00  = "#000000"
-- base03  = "#555555"
-- base02  = "#333333"
-- base01  = "#111111"
-- base00  = "#000000"
hisBase03  = "#002b36"
hisBase02  = "#073642"
hisBase01  = "#586e75"
hisBase00  = "#657b83"
base0   = "#839496"
base1   = "#93a1a1"
base2   = "#eee8d5"
base3   = "#fdf6e3"
yellow  = "#b58900"
orange  = "#cb4b16"
red     = "#dc322f"
magenta = "#d33682"
violet  = "#6c71c4"
blue    = "#268bd2"
cyan    = "#2aa198"
green   = "#859900"


warmPromptTheme = myPromptTheme
    { bgColor               = yellow
    , fgColor               = base3
    , fgHLight              = base3
    , bgHLight              = red
    , position              = Top
    }

hotPromptTheme = myPromptTheme
    { bgColor               = red
    , fgColor               = base3
    , position              = Top
    }

myPromptTheme = def
    { bgColor               = base03
    , fgColor               = base3
    , fgHLight              = base03
    , bgHLight              = blue
    , borderColor           = base03
    , promptBorderWidth     = 0
    , height                = 16
    , position              = Top
    , font                  = "xft:Hack:pixelsize=14"
    }
