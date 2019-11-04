module Msg exposing (Msg(..))

import ParseSchedule exposing (Schedule)


type Msg
    = Schedule Schedule
    | ToggleSubgroup
    | ToggleParity
