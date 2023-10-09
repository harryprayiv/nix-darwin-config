import           Control.Monad                         ( replicateM_
                                                       , filterM
                                                       , liftM
                                                       , join
                                                       , unless
                                                       )
import           Data.IORef      
import           Data.Char
import           Data.List                                                 
import           Data.Foldable                         ( traverse_ )
import           Data.Monoid
import           Graphics.X11.ExtraTypes.XF86
import           System.Exit
import           System.Directory                      ( doesFileExist )
import           System.IO                             ( hPutStr
                                                       , hClose
                                                       , writeFile
                                                       )
import           XMonad
import           XMonad.Actions.CycleWS                ( Direction1D(..)
                                                       , WSType(..)
                                                       , anyWS
                                                       , findWorkspace
                                                       )
import           XMonad.Actions.DynamicProjects        ( Project(..)
                                                       , dynamicProjects
                                                       , switchProjectPrompt
                                                       )
import           XMonad.Actions.DynamicWorkspaces      ( removeWorkspace )
import           XMonad.Actions.FloatKeys              ( keysAbsResizeWindow
                                                       , keysResizeWindow
                                                       )
import           XMonad.Actions.RotSlaves              ( rotSlavesUp )
import           XMonad.Actions.SpawnOn                ( manageSpawn
                                                       , spawnOn
                                                       )
import           XMonad.Actions.WithAll                ( killAll )
import           XMonad.Actions.CopyWindow             ( killAllOtherCopies
                                                       , copy
                                                       , copyToAll
                                                       , kill1
                                                       )
import           XMonad.Hooks.EwmhDesktops             ( ewmh
                                                       , ewmhFullscreen
                                                       )
import           XMonad.Hooks.FadeInactive             
import           XMonad.Hooks.InsertPosition           ( Focus(..)
                                                       , Position(..)
                                                       --, Position(Above)
                                                       , insertPosition
                                                       )
import           XMonad.Hooks.ManageDocks              ( Direction2D(..)
                                                       , ToggleStruts(..)
                                                       , avoidStruts
                                                       , docks
                                                       )
import           XMonad.Hooks.ManageHelpers            ( (-?>)
                                                       , composeOne
                                                       , doCenterFloat
                                                       , doFullFloat
                                                       , isDialog
                                                       , isFullscreen
                                                       , isInProperty
                                                       )
import           XMonad.Hooks.UrgencyHook              ( UrgencyHook(..)
                                                       , withUrgencyHook
                                                       )
import           XMonad.Layout.Gaps                    ( GapSpec(..)
                                                       , GapMessage (IncGap, DecGap)
                                                       , weakModifyGaps
                                                       , gaps 
                                                       , setGaps 
                                                       )
import           XMonad.Layout.MultiToggle             ( Toggle(..)
                                                       , mkToggle
                                                       , single
                                                       )
import           XMonad.Layout.MultiToggle.Instances   ( StdTransformers(NBFULL) )
import           XMonad.Layout.NoBorders               ( smartBorders )
import           XMonad.Layout.PerWorkspace            ( onWorkspace )
import           XMonad.Layout.Spacing                 ( SpacingModifier(..)
                                                       , spacing
                                                       , incScreenWindowSpacing
                                                       , decScreenWindowSpacing
                                                       )
import           XMonad.Layout.HintedGrid
import           XMonad.Layout.ThreeColumns            ( ThreeCol(..) )
import           XMonad.Layout.Spiral
import           XMonad.Layout.Fullscreen
import           XMonad.Layout.OneBig
import           XMonad.Layout.Tabbed
import           XMonad.Layout.Reflect                 ( reflectHoriz )
import           XMonad.Layout.ResizableTile
import           XMonad.Prompt                         ( XPConfig(..)
                                                       , amberXPConfig
                                                       , XPPosition(CenteredAt)
                                                       )
import           XMonad.Util.EZConfig                  ( mkNamedKeymap
                                                       , additionalKeys
                                                       , removeKeys                                                      
                                                       )
import           XMonad.Util.NamedActions              ( (^++^)
                                                       , NamedAction (..)
                                                       , addDescrKeys'
                                                       , addName
                                                       , showKm
                                                       , subtitle
                                                       )
import           XMonad.Util.NamedScratchpad           ( NamedScratchpad(..)
                                                       , customFloating
                                                       , defaultFloating
                                                       , namedScratchpadAction
                                                       , namedScratchpadManageHook
                                                       )
import           XMonad.Util.Run                       ( safeSpawn
                                                       , spawnPipe
                                                       )
import           XMonad.Util.SpawnOnce                 ( spawnOnce )
import           XMonad.Util.WorkspaceCompare          ( getSortByIndex )
import           XMonad.Util.XSelection                ( safePromptSelection )

import qualified Control.Exception                     as E
import qualified Data.Map                              as M
import qualified XMonad.StackSet                       as W
import qualified XMonad.Util.NamedWindows              as W
import qualified XMonad.Util.ExtensibleState           as XS  -- Custom State

-- Imports for Polybar --
import qualified Codec.Binary.UTF8.String              as UTF8
import qualified Data.Set                              as S
import qualified DBus                                  as D
import qualified DBus.Client                           as D
import           XMonad.Hooks.DynamicLog
import           HueLighting

main :: IO ()
main = mkDbusClient >>= main'

main' :: D.Client -> IO ()
main' dbus = xmonad . docks . ewmh . ewmhFullscreen . dynProjects . keybindings . urgencyHook $ def
  { terminal           = myTerminal
  , focusFollowsMouse  = False
  , clickJustFocuses   = False
  , borderWidth        = 2
  , modMask            = myModMask
  , workspaces         = myWS
  , normalBorderColor  = "#32343d" -- #neutral gray
  , focusedBorderColor = "#6C99B8" -- nice blue
  , mouseBindings      = myMouseBindings
  , layoutHook         = myLayout
  , manageHook         = myManageHook
  , logHook            = myPolybarLogHook dbus
  , startupHook        = myStartupHook
  }
 where
  myModMask   = mod4Mask -- super as the mod key
  dynProjects = dynamicProjects projects
  keybindings = addDescrKeys' ((myModMask, xK_F1), showKeybindings) myKeys
  urgencyHook = withUrgencyHook LibNotifyUrgencyHook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
myStartupHook = startupHook def

-- original idea: https://pbrisbin.com/posts/using_notify_osd_for_xmonad_notifications/
data LibNotifyUrgencyHook = LibNotifyUrgencyHook deriving (Read, Show)

instance UrgencyHook LibNotifyUrgencyHook where
  urgencyHook LibNotifyUrgencyHook w = do
    name     <- W.getName w
    maybeIdx <- W.findTag w <$> gets windowset
    traverse_ (\i -> safeSpawn "notify-send" [show name, "workspace " ++ i]) maybeIdx

------------------------------------------------------------------------
-- Polybar settings (needs DBus client).
--
mkDbusClient :: IO D.Client
mkDbusClient = do
  dbus <- D.connectSession
  D.requestName dbus (D.busName_ "org.xmonad.log") opts
  return dbus
 where
  opts = [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]

-- Emit a DBus signal on log updates
dbusOutput :: D.Client -> String -> IO ()
dbusOutput dbus str =
  let opath  = D.objectPath_ "/org/xmonad/Log"
      iname  = D.interfaceName_ "org.xmonad.Log"
      mname  = D.memberName_ "Update"
      signal = D.signal opath iname mname
      body   = [D.toVariant $ UTF8.decodeString str]
  in  D.emit dbus $ signal { D.signalBody = body }

polybarHook :: D.Client -> PP
polybarHook dbus =
  let wrapper c s | s /= "NSP" = wrap ("%{F" <> c <> "} ") " %{F-}" s
                  | otherwise  = mempty
      blue   = "#619DEC"
      gray   = "#8D868F"
      white  = "#FFFFFF"
      orange = "#CF6A4C"
      yellow = "#F9F4CD"
      green  = "#8F9D6A"
      darkgray    = "#5F5A60"
  in  def { ppOutput          = dbusOutput dbus
          , ppCurrent         = wrapper blue
          , ppVisible         = wrapper white
          , ppUrgent          = wrapper orange
          , ppHidden          = wrapper gray
          , ppHiddenNoWindows = wrapper darkgray
          , ppTitle           = wrapper yellow . shorten 120
          }

myPolybarLogHook dbus = myLogHook <+> dynamicLogWithPP (polybarHook dbus)

--- Dynamic Gaps implementation

-- Gaps between windows
gapSize = 10

newtype GapState = GapIndex Int deriving Show
instance ExtensionClass GapState where
  initialValue = GapIndex 0

myGaps :: [GapSpec]
myGaps = [ [(R,10),(L,10),(U,10),(D,10)] -- you do have to specify all directions
         , [(R,5),(L,5),(U,5),(D,5)]
         , [(R,2),(L,2),(U,2),(D,2)]
         , [(R,15),(L,15),(U,15),(D,15)]
         , [(R,20),(L,20),(U,20),(D,20)]
         , [(R,25),(L,25),(U,25),(D,25)]
         , [(R,30),(L,30),(U,30),(D,30)]
         , [(R,40),(L,40),(U,40),(D,40)] 
         , [(R,0),(L,0),(U,120),(D,120)]
         , [(R,700),(L,0),(U,0),(D,0)] 
         , [(R,0),(L,700),(U,0),(D,0)] 
         , [(R,0),(L,0),(U,100),(D,0)] 
         , [(R,0),(L,0),(U,0),(D,100)] 
         , [(R,0),(L,0),(U,0),(D,0)]         
         ]

cycleGaps :: X()
cycleGaps = do
  (GapIndex idx) <- XS.gets $ \(GapIndex i) -> 
    let n = if i >= length myGaps - 1 then 0 else i+1 in GapIndex n
  sendMessage (setGaps $ myGaps !! idx)
  XS.put $ GapIndex idx

myTerminal     = "alacritty"

terminalWithCommand :: String -> String
terminalWithCommand cmd = "alacritty -o shell.program=fish -o shell.args=['-C " <> cmd <> "']"

myBashTerminal = "alacritty --hold -e bash"
myZshTerminal = "alacritty --hold -e zsh"

delayTerminal      = "sleep 2s && alacritty"
myGuildView        = "alacritty --hold -e ./guild-operators/scripts/cnode-helper-scripts/gLiveView.sh"
cnodeStatus        = "alacritty --hold -o font.size=5 -e systemctl status cardano-node"
myCardanoCli       = "sleep 20m && alacritty --hold -e node_check"
appLauncher        = "rofi -modi drun,ssh,window -show drun -show-icons"
playerctl c        = "playerctl --player=spotify,%any " <> c

calcLauncher = "rofi -show calc -modi calc -no-show-match -no-sort"
emojiPicker  = "rofi -modi emoji -show emoji -emoji-mode copy"
--spotlight    = "rofi -modi spotlight -show spotlight -spotlight-mode copy"

-- Screen Lock 
screenLocker  = "betterlockscreen -l dim"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
showKeybindings :: [((KeyMask, KeySym), NamedAction)] -> NamedAction
showKeybindings xs =
  let
    filename = "/home/bismuth/.xmonad/keybindings"
    command f = "alacritty -e dialog --title 'XMonad Key Bindings' --colors --hline \"$(date)\" --textbox " ++ f ++ " 50 100"
  in addName "Show Keybindings" $ do
    b <- liftIO $ doesFileExist filename
    unless b $ liftIO (writeFile filename (unlines $ showKm xs))
    spawnOn webWs $ command filename -- show dialog on webWs
    windows $ W.greedyView webWs     -- switch to webWs


 -- use "xev" to figure out exactly what key you are pressing
myKeys conf@XConfig {XMonad.modMask = modm} =
  keySet "Applications"
    [ key "Mastodon"        (modm .|. controlMask, xK_t             ) $ spawnOn comWs "brave --app=https://mastodon.social/"
    , key "Youtube"         (modm .|. controlMask, xK_y             ) $ spawnOn webWs "brave --app=https://youtube.com/"
    , key "Private Browser" (modm .|. controlMask, xK_p             ) $ spawnOn webWs "brave --incognito"
    -- , key "Home Page w/App" (modm .|. controlMask, xK_a             ) $ spawnOn webWs "brave --app=https://harryprayiv.github.io/fluidity/"
    ] ^++^
  keySet "Lighting Cues"
    [ key "DarkWarm"          (0, xF86XK_MonBrightnessDown                  ) (runLightCue 0)
    , key "BrighterWarm"      (0, xF86XK_MonBrightnessUp                    ) (runLightCue 2)
    , key "FullWarm"          (controlMask, xF86XK_MonBrightnessUp          ) (runLightCue 3)
    , key "Prev Lighting Cue" (modm, xF86XK_MonBrightnessDown               ) prevLightCue
    , key "Next Lighting Cue" (modm,  xF86XK_MonBrightnessUp                ) nextLightCue
    , key "FullCold"          (modm .|. controlMask, xF86XK_MonBrightnessUp ) (runLightCue 6)
    ] ^++^    
  keySet "Audio"
    [ key "Mute"            (0, xF86XK_AudioMute                   ) $ spawn "amixer -q set Master toggle"
    , key "Lower volume"    (0, xF86XK_AudioLowerVolume            ) $ spawn "amixer -q set Master 3%-"
    , key "Raise volume"    (0, xF86XK_AudioRaiseVolume            ) $ spawn "amixer -q set Master 3%+"
    , key "Lower S volume"  (modm, xF86XK_AudioLowerVolume         ) $ spawn $ playerctl "volume 0.05-"
    , key "Raise S volume"  (modm, xF86XK_AudioRaiseVolume         ) $ spawn $ playerctl "volume 0.05+"
    , key "Mute S volume"   (modm, xF86XK_AudioMute                ) $ spawn $ playerctl "volume 0.0"
    , key "100% S volume"   (modm .|. shiftMask , xF86XK_AudioMute ) $ spawn $ playerctl "volume 1.0"
    , key "Play / Pause"    (0, xF86XK_AudioPlay                   ) $ spawn $ playerctl "play-pause"
    , key "Stop"            (0, xF86XK_AudioStop                   ) $ spawn $ playerctl "stop"
    , key "Previous"        (0, xF86XK_AudioPrev                   ) $ spawn $ playerctl "previous"
    , key "Next"            (0, xF86XK_AudioNext                   ) $ spawn $ playerctl "next"
    ] ^++^
  keySet "Launchers"
    [ key "Terminal"        (modm .|. shiftMask  , xK_Return  ) $ spawn (XMonad.terminal conf)
    , key "Bash Terminal"   (modm .|. controlMask,  xK_b      ) $ spawn myBashTerminal   
    , key "Zsh Terminal"    (modm .|. controlMask,  xK_z      ) $ spawn myZshTerminal    
    , key "Apps (Rofi)"     (0, xF86XK_LaunchA                ) $ spawn appLauncher
    , key "Calc (Rofi)"     (modm .|. shiftMask  , xK_c       ) $ spawn calcLauncher
    , key "Emojis (Rofi)"   (modm .|. shiftMask  , xK_m       ) $ spawn emojiPicker
    , key "Lock screen"     (modm .|. controlMask, xK_l       ) $ spawn screenLocker >> runLightCue 9
    ] ^++^
  keySet "Layouts"
    [ key "Next"            (modm                 , xK_space   ) $ sendMessage NextLayout
    , key "SpaceInc"        (modm                 , xK_g       ) $ incScreenWindowSpacing 2 
    , key "SpaceDec"        (modm .|. shiftMask   , xK_g       ) $ decScreenWindowSpacing 2 
    , key "BorderSwitch"    (modm                 , xK_b       ) cycleGaps 
    , key "Reset"           (modm .|. shiftMask   , xK_space   ) $ setLayout (XMonad.layoutHook conf)
    , key "Fullscreen"      (modm                 , xK_f       ) $ sendMessage (Toggle NBFULL)
    ] ^++^
  keySet "Polybar"
    [ key "Toggle"          (modm                 , xK_equal ) togglePolybar
    , key "Toggle Bottom"   (modm .|. shiftMask   , xK_b     ) toggleBtmPolybar
    , key "Toggle Top"      (modm .|. shiftMask   , xK_u     ) toggleTopPolybar
    ] ^++^
  keySet "Projects"
    [ key "Switch prompt"   (0, xF86XK_KbdBrightnessDown      ) $ switchProjectPrompt projectsTheme
    ] ^++^
  keySet "Scratchpads"
    [ key "bottom"          (0, xF86XK_LaunchB                ) $ runScratchpadApp btm
    , key "GuildView"       (modm .|. controlMask,  xK_g      ) $ spawnOn spoWs myGuildView
    , key "Files"           (modm .|. controlMask,  xK_f      ) $ runScratchpadApp nautilus
    , key "Screen recorder" (modm .|. controlMask,  xK_r      ) $ runScratchpadApp scr
    -- , key "Spotify"         (modm .|. controlMask,  xK_s      ) $ runScratchpadApp spotify
    , key "Mpv"             (modm .|. controlMask,  xK_m      ) $ safePromptSelection "mpv"
    , key "Gimp"            (modm .|. controlMask,  xK_i      ) $ runScratchpadApp gimp
    ] ^++^
  keySet "Screens" switchScreen ^++^
  keySet "System"
    [ -- key "Toggle status bar gap"  (modm .|. shiftMask, xK_b  ) toggleStruts
      key "Logout (quit XMonad)"   (modm .|. shiftMask, xK_q  ) $ io exitSuccess
    , key "Restart XMonad"         (modm              , xK_q  ) $ spawn "xmonad --recompile; xmonad --restart"
    , key "Capture entire screen"  (modm          , xK_Print  ) $ spawn "flameshot full -p ~/Pictures/flameshot/"
    , key "Switch keyboard layout" (modm             , xK_F8  ) $ spawn "kls"
    , key "Disable CapsLock"       (modm             , xK_F9  ) $ spawn "setxkbmap -option ctrl:nocaps"
    ] ^++^
  keySet "Windows"
    [ key "Close focused"   (modm              , xK_BackSpace ) kill1
    , key "Close all in ws" (modm .|. shiftMask, xK_BackSpace ) killAll
    , key "Refresh size"    (modm              , xK_n         ) refresh
    , key "Focus next"      (modm              , xK_j         ) $ windows W.focusDown
    , key "Focus previous"  (modm              , xK_k         ) $ windows W.focusUp
    , key "Focus master"    (modm              , xK_m         ) $ windows W.focusMaster
    , key "Swap master"     (modm              , xK_Return    ) $ windows W.swapMaster
    , key "Swap next"       (modm .|. shiftMask, xK_j         ) $ windows W.swapDown
    , key "Swap previous"   (modm .|. shiftMask, xK_k         ) $ windows W.swapUp
    , key "Shrink master"   (modm              , xK_h         ) $ sendMessage Shrink
    , key "Expand master"   (modm              , xK_l         ) $ sendMessage Expand
    , key "Mirror grow"     (modm              , xK_a         ) $ sendMessage MirrorExpand
    , key "Mirror shrink"   (modm              , xK_z         ) $ sendMessage MirrorShrink
    , key "Switch to tile"  (modm              , xK_t         ) $ withFocused (windows . W.sink)
    , key "Rotate slaves"   (modm .|. shiftMask, xK_Tab       ) rotSlavesUp
    , key "Decrease size"   (modm              , xK_d         ) $ withFocused (keysResizeWindow (-10,-10) (1,1))
    , key "Increase size"   (modm              , xK_s         ) $ withFocused (keysResizeWindow (10,10) (1,1))
    , key "Decr  abs size"  (modm .|. shiftMask, xK_d         ) $ withFocused (keysAbsResizeWindow (-10,-10) (1024,752))
    , key "Incr  abs size"  (modm .|. shiftMask, xK_s         ) $ withFocused (keysAbsResizeWindow (10,10) (1024,752))
    , key "Always Visible"  (modm              , xK_v         ) $ windows copyToAll
    , key "Kill Copies"     (modm .|. shiftMask, xK_v         ) $ killAllOtherCopies
    ] ^++^
  keySet "Workspaces"
    [ key "Next"            (modm              , xK_period    ) nextWS'
    , key "Previous"        (modm              , xK_comma     ) prevWS'
    , key "Remove"          (modm              , xF86XK_Eject ) removeWorkspace
    ] ++ switchWsById
 where
  togglePolybar = spawn "polybar-msg cmd toggle &"
  toggleStruts = togglePolybar >> sendMessage ToggleStruts
  toggleTopPolybar = spawn "top_bar=$(xdotool search --name polybar-top getwindowpid) ; polybar-msg -p $top_bar cmd toggle &"
  toggleTopStrut = toggleTopPolybar >> (sendMessage $ ToggleStrut U)
  toggleBtmPolybar = spawn "btm_bar=$(xdotool search --name polybar-bottom getwindowpid) ; polybar-msg -p $btm_bar cmd toggle &"
  toggleBtmStrut = toggleBtmPolybar >> (sendMessage $ ToggleStrut D)
  keySet s ks = subtitle s : ks
  key n k a = (k, addName n a)
  action m = if m == shiftMask then "Move to " else "Switch to "
-- mod-[1..9]: Switch to workspace N | 
-- mod-shift-[1..9]: Move client to workspace N
-- mod-ctrl-shift-[1..9]: Copy client to workspace N
  switchWsById =
    [ key (action m <> show i) (m .|. modm, k) (windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask), (copy, shiftMask .|. controlMask)]]
  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  switchScreen =
    [ key (action m <> show sc) (m .|. modm, k) (screenWorkspace sc >>= flip whenJust (windows . f))
        | (k, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m)  <- [(W.view, 0), (W.shift, shiftMask)]]

----------- Cycle through workspaces one by one but filtering out NSP (scratchpads) -----------

nextWS' = switchWS Next
prevWS' = switchWS Prev

switchWS dir =
  findWorkspace filterOutNSP dir anyWS 1 >>= windows . W.view

filterOutNSP =
  let g f xs = filter (\(W.Workspace t _ _) -> t /= "NSP") (f xs)
  in  g <$> getSortByIndex

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events----------------
myMouseBindings XConfig {XMonad.modMask = modm} = M.fromList

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), \w -> focus w >> mouseMoveWindow w
                                      >> windows W.shiftMaster)

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), \w -> focus w >> mouseResizeWindow w
                                      >> windows W.shiftMaster)

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
--
myLayout =
  avoidStruts
    . smartBorders
    . fullScreenToggle
    . comLayout
    . vscLayout    
    . musLayout     
    . webLayout
    . mscLayout
    . devLayout   
    . scdLayout   
    . spoLayout
    . secLayout $ (devTiles ||| resize2Master ||| resizeTall ||| Mirror tiled ||| column3 ||| full)
   where
     -- default tiling algorithm partitions the screen into two panes
     grid                    = spacing gapSize . gaps (head myGaps) $ Grid False
     grid_strict_portrait    = spacing gapSize . gaps (head myGaps) $ GridRatio grid_portrait False 
     grid_strict_landscape   = spacing gapSize . gaps (head myGaps) $ GridRatio grid_landscape False 
     tiled                   = spacing gapSize . gaps (head myGaps) $ Tall nmaster delta golden_ratio
     doubletiled             = spacing gapSize . gaps (head myGaps) $ Tall nmasterTwo delta golden_ratio
     tiled_nogap             = spacing 0 . gaps (myGaps !! 13) $ Tall nmaster delta golden_ratio
     tiled_spaced            = spacing 0 . gaps (myGaps !! 3) $ Tall nmaster delta ratio
     column3_og              = spacing gapSize . gaps (head myGaps) $ ThreeColMid 1 (3/100) (1/2)
     video_tile              = spacing gapSize . gaps (head myGaps) $ Mirror (Tall 1 (1/50) (3/5))
     full                    = Full
     fuller                  = spacing 0 . gaps (myGaps !! 13) $ Full
     column3                 = spacing 2 . gaps (myGaps !! 2) $ ThreeColMid 1 (33/100) (1/2)
     goldenSpiral            = spacing gapSize . gaps (head myGaps) $ spiral golden_ratio
     silverSpiral            = spacing gapSize . gaps (head myGaps) $ spiralWithDir East CCW ratio
     dynamicGaps             = spacing gapSize . gaps (head myGaps) $ spiralWithDir East CCW ratio
     oneBig                  = spacing 2 . gaps (myGaps !! 3) $ OneBig (3/4) (3/4) 
     tabber                  = spacing 2 . gaps (myGaps !! 3) $ simpleTabbed
     resizeTall              = spacing gapSize . gaps (head myGaps) $ ResizableTall 1 (3/100) (3/4) []
     resize2Master           = spacing gapSize . gaps (head myGaps) $ ResizableTall 2 (3/100) (3/4) []
     devTiles                = spacing 2 . gaps (myGaps !! 3) $ ResizableTall 2 (3/100) (7/8) []


     -- The default number of windows in the master pane
     nmaster = 1
     nmasterTwo = 2

     -- Default proportions of screen occupied by master pane
     ratio          = 1/2
     golden_ratio   = 1/1.618033988749894e0
     grid_portrait     = 3/4
     grid_landscape    = 4/3

     -- Percent of screen to increment by when resizing panes
     delta   = 2/100

     -- Per workspace layout
     webLayout = onWorkspace webWs (resizeTall ||| devTiles ||| tiled_nogap ||| oneBig ||| reflectHoriz tiled_nogap ||| fuller ||| tabber ||| goldenSpiral ||| reflectHoriz  goldenSpiral ||| tiled_spaced ||| reflectHoriz tiled_spaced ||| full ||| grid ||| grid_strict_landscape)
     mscLayout = onWorkspace mscWs (devTiles ||| resize2Master ||| resizeTall ||| tabber ||| resize2Master ||| dynamicGaps ||| doubletiled ||| Mirror grid_strict_landscape ||| grid_strict_landscape ||| Mirror grid_strict_portrait ||| grid_strict_portrait ||| column3_og ||| tiled_spaced ||| grid ||| fuller ||| Mirror tiled_nogap ||| Mirror tiled ||| tiled_nogap ||| tiled ||| video_tile ||| full  ||| column3 ||| goldenSpiral ||| silverSpiral)
     musLayout = onWorkspace musWs (fuller ||| oneBig ||| tiled ||| tiled_spaced ||| reflectHoriz tiled_spaced)
     vscLayout = onWorkspace vscWs (devTiles ||| resize2Master ||| resizeTall ||| oneBig ||| Mirror tiled_nogap ||| reflectHoriz tiled ||| fuller ||| tiled_nogap ||| goldenSpiral ||| full ||| Mirror tiled ||| column3_og )
     comLayout = onWorkspace comWs (resize2Master ||| resizeTall ||| tiled ||| full ||| column3 ||| goldenSpiral)
     spoLayout = onWorkspace spoWs (resizeTall ||| devTiles ||| resize2Master ||| oneBig ||| goldenSpiral ||| column3 ||| Mirror tiled_nogap ||| fuller ||| full ||| tiled)
     scdLayout = onWorkspace scdWs (devTiles ||| resize2Master ||| resizeTall ||| oneBig ||| Mirror tiled_nogap ||| reflectHoriz tiled ||| fuller ||| tiled_nogap ||| goldenSpiral ||| full ||| Mirror tiled ||| column3_og )
     devLayout = onWorkspace devWs (devTiles ||| resize2Master ||| resizeTall ||| oneBig ||| Mirror tiled_nogap ||| reflectHoriz tiled ||| fuller ||| tiled_nogap ||| goldenSpiral ||| full ||| Mirror tiled ||| column3_og )
     secLayout = onWorkspace secWs (tiled ||| fuller ||| column3) 

     -- Fullscreen
     fullScreenToggle = mkToggle (single NBFULL)

-- Defining Rectangles using absolute points (https://gist.github.com/tkf/1343015)
doFloatAbsRect :: Rational -> Rational -> Rational -> Rational -> ManageHook
doFloatAbsRect x y width height = do
  win <- ask -- get Window
  q <- liftX (floatLocation win) -- get (ScreenId, W.RationalRect)
  let sid = fst q :: ScreenId
      oirgRect = snd q :: W.RationalRect
      ss2ss ss = -- :: StackSet ... -> StackSet ...
        W.float win newRect ss where
          mapping = map (\s -> (W.screen s, W.screenDetail s)) (c:v) where
            c = W.current ss
            v = W.visible ss
          maybeSD = lookup sid mapping
          scRect  = fmap screenRect maybeSD
          newRect = case scRect of
            Nothing -> oirgRect
            Just (Rectangle x0 y0 w0 h0) ->
              W.RationalRect x' y' w' h' where
                W.RationalRect x1 y1 w1 h1 = oirgRect
                x' = if x0 == 0 then x1 else x / (fromIntegral x0)
                y' = if y0 == 0 then y1 else y / (fromIntegral y0)
                w' = if w0 == 0 then w1 else width / (fromIntegral w0)
                h' = if h0 == 0 then h1 else height / (fromIntegral h0)
  doF ss2ss

type AppName      = String
type AppTitle     = String
type AppClassName = String
type AppCommand   = String

data App
  = ClassApp AppClassName AppCommand
  | TitleApp AppTitle AppCommand
  | NameApp AppName AppCommand
  deriving Show

audacious = ClassApp "Audacious"            "audacious"
btm       = TitleApp "btm"                  "alacritty -t btm -e btm --color gruvbox --default_widget_type proc"
virtbox   = ClassApp "VirtualBox Machine"   "VBoxManage startvm 'plutusVM_bismuth'"
calendar  = ClassApp "Orage"                "orage"
cmatrix   = TitleApp "cmatrix"              "alacritty cmatrix"
eog       = NameApp  "eog"                  "eog"
evince    = ClassApp "Evince"               "evince"
gimp      = ClassApp "Gimp"                 "gimp"
keepass   = ClassApp "KeePassXC"            "keepassxc"
-- mastodon  = TitleApp "Mastodon"          "tokodon"
nautilus  = ClassApp "Org.Gnome.Nautilus"   "nautilus"
office    = ClassApp "libreoffice-draw"     "libreoffice-draw"
pavuctrl  = ClassApp "Pavucontrol"          "pavucontrol"
scr       = ClassApp "SimpleScreenRecorder" "simplescreenrecorder"
-- spotify   = ClassApp "Spotify"              "spotify"
vlc       = ClassApp "Vlc"                  "vlc --qt-minimal-view"
mpv       = ClassApp "Mpv"                  "mpv" 
kodi      = ClassApp "Kodi"                 "kodi"
vscodium  = ClassApp "VSCodium"             "vscodium"
yad       = ClassApp "Yad"                  "yad --text-info --text 'XMonad'"

myManageHook = manageApps <+> manageSpawn <+> manageScratchpads
 where
  isBrowserDialog     = isDialog <&&> className =? "Brave-browser"
  isFileChooserDialog = isRole =? "GtkFileChooserDialog"
  isPopup             = isRole =? "pop-up"
  isSplash            = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_SPLASH"
  isRole              = stringProperty "WM_WINDOW_ROLE"
  tileBelow           = insertPosition Below Newer
  tileAbove           = insertPosition Above Newer
  doVideoFloat        = doFloatAbsRect 240 720 600 300
  doCalendarFloat     = customFloating (W.RationalRect (11 / 15) (1 / 48) (1 / 4) (1 / 8))
  manageScratchpads = namedScratchpadManageHook scratchpads
  anyOf :: [Query Bool] -> Query Bool
  anyOf = foldl (<||>) (pure False)
  match :: [App] -> Query Bool
  match = anyOf . fmap isInstance
  manageApps = composeOne
    [ isInstance calendar                      -?> doCalendarFloat
    , match [ virtbox
            ]                                  -?> tileAbove
    , match [ mpv
            ]                                  -?> tileAbove
    , match [ audacious
            , eog
            , nautilus
            , office
            , pavuctrl
            , scr
            , keepass
            ]                                  -?> doCenterFloat
    , match [ btm
            , evince
            , gimp
            ]                                  -?> doFullFloat
    , resource =? "desktop_window"             -?> doIgnore
    , resource =? "kdesktop"                   -?> doIgnore
    , anyOf [ isPopup
            ]                                  -?> tileBelow  
    , anyOf [ isFileChooserDialog
            , isDialog
            , isSplash
            , isBrowserDialog
            ]                                  -?> doCenterFloat        
    , isFullscreen                             -?> doFullFloat
    , pure True                                -?> tileBelow
    ]

isInstance (ClassApp c _) = className =? c
isInstance (TitleApp t _) = title =? t
isInstance (NameApp n _)  = appName =? n

getNameCommand (ClassApp n c) = (n, c)
getNameCommand (TitleApp n c) = (n, c)
getNameCommand (NameApp  n c) = (n, c)

getAppName    = fst . getNameCommand
getAppCommand = snd . getNameCommand

scratchpadApp :: App -> NamedScratchpad
scratchpadApp app = NS (getAppName app) (getAppCommand app) (isInstance app) defaultFloating

runScratchpadApp = namedScratchpadAction scratchpads . getAppName

scratchpads = scratchpadApp <$> [ audacious, btm, nautilus, scr, gimp, mpv, keepass, virtbox ]

------------------------------------------------------------------------
-- Workspaces
--
webWs = "web"
mscWs = "msc"
musWs = "mus"
vscWs = "vsc"
comWs = "com"
spoWs = "spo"
scdWs = "scd"
devWs = "dev"
secWs = "sec"

myWS :: [WorkspaceId]
myWS = [webWs, mscWs, musWs, vscWs, comWs, spoWs, devWs, scdWs, secWs]

------------------------------------------------------------------------
-- Dynamic Projects
--
projects :: [Project]
projects =
  [ Project { projectName      = webWs
            , projectDirectory = "~/plutus/workspace/webWs/"
            , projectStartHook = Just $ do spawn "brave"
                                           spawn "brave --app=https://youtube.com/" 
            }
  , Project { projectName      = mscWs
            , projectDirectory = "~/plutus/workspace/mscWs/"
            , projectStartHook = Just $ do spawn myTerminal
            }
  , Project { projectName      = musWs
            , projectDirectory = "~/plutus/workspace/musWs/"
            , projectStartHook = Just $ do spawn "brave --app=https://music.youtube.com/"
            }
  , Project { projectName      = vscWs
            , projectDirectory = "~/plutus/workspace/vscWs/nix-config.git/intelTower/"
            , projectStartHook = Just $ do spawn "codium -n ."
                                           spawn delayTerminal 
                                           spawn (terminalWithCommand "cowsay no way jose!")
            }
  , Project { projectName      = comWs
            , projectDirectory = "~/plutus/workspace/comWs/"
            , projectStartHook = Just $ do spawn "brave --app=https://mastodon.social/"
                                           spawn "discord"
                                           spawn "telegram-desktop"
                                           spawn "signal-desktop"
                                          --  spawn "element-desktop"
                                          --  spawn "slack"
            }
  , Project { projectName      = spoWs
            , projectDirectory = "~/plutus/workspace/spoWs/"
            , projectStartHook = Just $ do spawn (terminalWithCommand "systemctl status cardano-node")
            }
  , Project { projectName      = devWs
            , projectDirectory = "~/plutus/workspace/devWs/pelotero/"
            , projectStartHook = Just $ do spawn "codium -n ."
                                           spawn delayTerminal 
            }
  , Project { projectName      = scdWs
            , projectDirectory = "~/plutus/workspace/scdWs/scraperProto"
            , projectStartHook = Just $ do spawn "codium -n ."
                                           spawn delayTerminal 
            }
  , Project { projectName      = secWs
            , projectDirectory = "~/plutus/workspace/secWs/"
            , projectStartHook = Just $ runScratchpadApp keepass
            }
  ]

projectsTheme :: XPConfig
projectsTheme = amberXPConfig
  { bgHLight = "#002b36"
  , font     = "xft:Bitstream Vera Sans Mono:size=8:antialias=true"
  , height   = 60
  , position = CenteredAt 0.5 0.5
  }

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
-- NOTE: the (docks . ewmh . ewmhFullscreen) defined in main already overrides handleEventHook
--
-- myEventHook = docksEventHook <+> ewmhDesktopsEventHook <+> fullscreenEventHook

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--TODO: Add trandparency on a per app basis
--TODO: Add figure out how to make one window persistent using a keystroke
myLogHook = fadeInactiveLogHook 1.0
