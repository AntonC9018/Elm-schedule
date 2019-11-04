module ParseSchedule exposing (..)

import Json.Decode as JD


type alias LectureTime =
    { start : String
    , end : String
    }


type alias Schedule =
    List ScheduleDay


type alias ScheduleDay =
    { dayName : String
    , subjects : Subjects
    }


type alias Subjects =
    { subgroup1 : List Lecture
    , subgroup2 : List Lecture
    , all : List Lecture
    }


type alias Lecture =
    { name : String
    , shortName : String
    , number : Int
    , parity : Parity
    , prof : String
    , block : String
    , classroom : String
    , meta : Maybe String
    }


type Parity
    = Both
    | Even
    | Odd


lectureTimesDecoder : JD.Decoder (List LectureTime)
lectureTimesDecoder =
    JD.field "data" <|
        JD.field "lectureTimes" <|
            JD.list <|
                JD.map2 LectureTime
                    (JD.field "start" JD.string)
                    (JD.field "end" JD.string)


scheduleDecoder : JD.Decoder Schedule
scheduleDecoder =
    JD.field "data" <|
        JD.field "schedule" <|
            JD.list scheduleDayDecoder


scheduleDayDecoder : JD.Decoder ScheduleDay
scheduleDayDecoder =
    JD.map2 ScheduleDay
        (JD.field "dayName" JD.string)
        (JD.field "subjects" <|
            JD.map3 Subjects
                (JD.field "subgroup1" <| JD.list lectureDecoder)
                (JD.field "subgroup2" <| JD.list lectureDecoder)
                (JD.field "all" <| JD.list lectureDecoder)
        )


lectureDecoder : JD.Decoder Lecture
lectureDecoder =
    JD.map8 Lecture
        (JD.field "name" JD.string)
        (JD.field "shortName" JD.string)
        (JD.field "number" JD.int)
        (JD.field "parity" parityDecoder)
        (JD.field "prof" JD.string)
        (JD.field "block" JD.string)
        (JD.field "classroom" JD.string)
        (JD.maybe <| JD.field "meta" JD.string)


parityDecoder : JD.Decoder Parity
parityDecoder =
    JD.string
        |> JD.andThen
            (\str ->
                case str of
                    "both" ->
                        JD.succeed Both

                    "odd" ->
                        JD.succeed Odd

                    "even" ->
                        JD.succeed Even

                    somethingElse ->
                        JD.fail <| "Unknown parity: " ++ somethingElse
            )


normalStringWithDefault : Maybe String -> String -> String
normalStringWithDefault maybe default =
    case maybe of
        Just str ->
            str

        Nothing ->
            default


decodeJsonStringWithDefault : JD.Decoder (List a) -> String -> List a
decodeJsonStringWithDefault decoder string =
    case JD.decodeString decoder string of
        Ok lectureTimes ->
            lectureTimes

        Err err ->
            Debug.log (JD.errorToString err) []


handleJsonError : JD.Error -> String
handleJsonError error =
    case error of
        JD.Failure errorMessage _ ->
            errorMessage

        JD.Field errorMessage err ->
            errorMessage ++ ",  " ++ handleJsonError err

        _ ->
            "Error: Invalid JSON"
