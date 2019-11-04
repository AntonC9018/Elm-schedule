module Model exposing (Model)

import ParseSchedule exposing (LectureTime, Parity, Schedule)


type alias Model =
    { message : String
    , schedule : Schedule
    , lectureTimes : List LectureTime
    , activeSubgroupIndex : Int
    , currentParity : Parity
    }
