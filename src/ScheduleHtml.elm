module ScheduleHtml exposing (lecturesHtml, scheduleDayHtml)

import Html exposing (..)
import Html.Attributes exposing (..)
import List.Extra as List exposing (..)
import Model exposing (Model)
import Msg exposing (Msg)
import ParseSchedule exposing (..)


scheduleDayHtml : Model -> ScheduleDay -> Html Msg
scheduleDayHtml model day =
    let
        subgroupString =
            "Subgroup " ++ String.fromInt model.activeSubgroupIndex
    in
    div [ class "pad-top" ]
        [ h2 [] [ text day.dayName ]
        , table
            []
            (tr []
                [ th [] [ text "Time" ]
                , th [] [ text subgroupString ]
                , th [] [ text "Classroom" ]
                ]
                :: lecturesHtml model day
            )
        ]



lecturesHtml : Model -> ScheduleDay -> List (Html Msg)
lecturesHtml model day =
    let

        subjects = day.subjects

        filterByParity : List Lecture -> List Lecture
        filterByParity list =
            List.filter (\e -> e.parity == Both || e.parity == model.currentParity) list

        filteredAll =
            subjects.all
                |> filterByParity

        filteredSubgroup : List Lecture
        filteredSubgroup =
            (if model.activeSubgroupIndex == 1 then
                subjects.subgroup1

                else
                subjects.subgroup2
            )
                |> filterByParity

        lectureAtTime : Int -> Maybe Lecture
        lectureAtTime index =
            List.find (\lec -> lec.number == index) (filteredAll ++ filteredSubgroup)

        mapLectureMeta : Lecture -> Html Msg
        mapLectureMeta lec =
            case lec.meta of
                Nothing ->
                    text ""

                Just str ->
                    i [] [ text (" (" ++ str ++ ")") ]

        mapLectureToHtml : ( LectureTime, Int ) -> Html Msg
        mapLectureToHtml ( time, index ) =
            let

                lectureContent : List (Html Msg)
                lectureContent =
                    let
                        noth =
                            [ td [] [ text "No lectures" ]
                            , td [] [ text "-" ]
                            ]
                    in
                    case lectureAtTime index of
                        Nothing ->
                            noth

                        Just lec ->
                            if lec.parity == Both || lec.parity == model.currentParity then
                                [ td []
                                    [ text lec.name
                                    , mapLectureMeta lec
                                    ]
                                , td [] [ text (lec.classroom ++ ", b. " ++ lec.block) ]
                                ]

                            else
                                noth
            in
            tr []
                (td
                    [ class "times-data" ]
                    [ text (time.start ++ "-" ++ time.end) ]
                    :: lectureContent
                )
    in
    List.range 0 4
        |> List.map2 Tuple.pair model.lectureTimes
        |> List.map mapLectureToHtml
