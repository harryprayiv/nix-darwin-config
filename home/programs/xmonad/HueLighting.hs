module HueLighting
  ( nextLightCue
  , prevLightCue
  , cycleLightCue
  , runLightCue
  ) where

import           XMonad
import           XMonad.Util.Run                      
import qualified XMonad.Util.ExtensibleState           as XS

type LightCommand = String
data HueCommand = HueCommand { lights :: [Int], commands :: [LightCommand] }

type LightZone = [Int]

{- Smart Lighting Hotkeys

Lights:
     1. Window 1 (rest area)
     2. Corner  (rest area)
     3. Closet (work area)
     5. TV candle 2  (rest area)
     6. Bed China Ball  (rest area)
     7. Chandelier 1 (Su)
     8. Dresser Candle 1 (boundary)
     9. Shelf Box 1 (rest area)
    10. Chandelier 2 (Su)
    12. Desk Light (Su)
    14. Overhead Computers  (work area)
    16. Overhead Middle (boundary)
    17. Guitars (work area)
    18. Overhead Bed (rest area)
    19. TV Candle 1 (rest area)
    20. Window 2 (rest area)
    21. TV Candle 3 (rest area)
-}

-- A function to generate hue strings
buildLightCommand :: HueCommand -> String
buildLightCommand (HueCommand ls cmds) = concatMap buildCommands cmds
  where
    buildCommands cmd = unwords $ concatMap (\light -> ["hue light", show light, cmd, ";"]) ls

-- Chain multiple HueCommands
chainCommands :: [HueCommand] -> String
chainCommands = unwords . map buildLightCommand

-- Zones
wholeRoom, restArea, boundary, workArea, suRoom:: LightZone
wholeRoom = [1, 2, 3, 5, 6, 8, 9, 14, 16, 17, 18, 19, 20, 21]
restArea = [1, 2, 5, 6, 9, 18, 19, 20, 21] 
boundary = [8, 16]
workArea = [3, 14, 17]
suRoom = [7, 10, 12]

-- Hue Lighting Cues
blackOut :: String
blackOut = chainCommands   [ HueCommand wholeRoom ["off"]]

darkWarm = chainCommands   [ HueCommand restArea ["off"]
                             , HueCommand boundary ["off"]
                             , HueCommand [17] [ "on", "brightness  28%", "color 2141" ]
                             , HueCommand [3] [ "on", "color 2000", "brightness 100%" ]
                             , HueCommand [14] [ "on", "color 2141", "brightness 10%" ]
                             ]
brightWarm = chainCommands [ HueCommand restArea ["relax", "brightness 50%" ]
                             , HueCommand boundary [ "relax", "brightness  22%" ]
                             , HueCommand [17] [ "on", "color 2141", "brightness 69%" ]
                             , HueCommand [3] [ "on", "color 2141", "brightness 100%" ]
                             , HueCommand [14] [ "on", "color 2141", "brightness 80%" ]
                             ]   
basque = chainCommands   [ HueCommand [1]  [ "on", "brightness   155", "color 0.4247, 0.3421" ]
                         , HueCommand [2]  [ "on", "brightness   132", "color 0.4834, 0.3606" ]
                         , HueCommand [3]  [ "on", "brightness   155", "color 0.4129, 0.3416" ]
                         , HueCommand [6]  [ "on", "brightness   134", "color 0.414, 0.3905" ]
                         , HueCommand [5, 8, 9, 14, 16, 18, 19]  [ "on", "brightness   125", "color 0.5106, 0.3739" ]
                         , HueCommand [17] [ "on", "brightness   156", "color 0.4834, 0.3606" ]
                         , HueCommand [20] [ "on", "brightness   155", "color 0.413, 0.3415" ]
                         , HueCommand [21] [ "on", "brightness   156", "color 0.4831, 0.3606" ]
                         ]

fullWarm = chainCommands   [ HueCommand wholeRoom [ "on", "color 2900", "brightness 100%" ]]


darkCold = chainCommands [ HueCommand restArea ["off"]
                            , HueCommand boundary ["off"]
                          , HueCommand [17]  ["on", "color 6200", "brightness 28%"]
                            , HueCommand [3]  ["on", "blue", "brightness 100%"]
                            , HueCommand [14] ["on", "blue", "brightness 10%"]
                            ]
brightCold = chainCommands [ HueCommand restArea [ "on", "color 6500", "brightness 50%" ]
                             , HueCommand boundary [ "on", "color 6500", "brightness 22%" ]
                             , HueCommand [2] [ "on", "color 6500", "brightness 10%" ]
                             , HueCommand [17] [ "on", "color 6500", "brightness 69%" ]
                             , HueCommand [3] ["concentrate"]
                             , HueCommand [14] [ "on", "color 6500", "brightness 80%" ]
                             ]
fullCold = chainCommands   [ HueCommand wholeRoom [ "on", "color 5900", "brightness 100%" ]]
freakOut = chainCommands   [ HueCommand restArea ["on", "blue", "brightness 80%" ]
                             , HueCommand workArea ["on", "red", "brightness 80%" ]
                             , HueCommand boundary ["on", "green", "brightness 80%", "blink" ]
                             , HueCommand [2, 17] [ "on", "brightness  28%" ]
                             , HueCommand [3] [ "on", "brightness  100%", "blink" ]
                             , HueCommand [14] [ "on", "brightness  45%" ]
                             ]
deskOff = chainCommands      [ HueCommand [17] ["off"]]
audrey = chainCommands   [ HueCommand wholeRoom [ "on", "color 0.4729, 0.2024", "brightness 100%" ]
                              , HueCommand [6] [ "on", "brightness  100%", "blink" ] 
                              ]

data LightingCue = DarkWarm | BrightWarm | Basque | FullWarm | DarkCold | BrightCold | FullCold | FreakOut | Audrey | DeskOff | BlackOut deriving (Enum, Bounded, Show)

lightingCues :: [X ()]
lightingCues =
  [ spawn darkWarm
  , spawn brightWarm
  , spawn basque
  , spawn fullWarm
  , spawn darkCold
  , spawn brightCold
  , spawn fullCold
  , spawn freakOut
  , spawn audrey
  , spawn deskOff
  , spawn blackOut
  ]

nextLightCue, prevLightCue :: X ()
nextLightCue = cycleLightCue 1
prevLightCue = cycleLightCue (-1)

cycleLightCue :: Int -> X ()
cycleLightCue d = do
  LightCueIndex idx <- XS.get
  let n = length lightingCues
      newIndex = (idx + d) `mod` n
  (lightingCues !! newIndex)
  XS.put $ LightCueIndex newIndex

runLightCue :: Int -> X ()
runLightCue idx = do
  let n = length lightingCues
      newIndex = idx `mod` n
  (lightingCues !! newIndex)
  XS.put $ LightCueIndex newIndex

newtype LightCueState = LightCueIndex Int deriving Show
instance ExtensionClass LightCueState where
  initialValue = LightCueIndex 0