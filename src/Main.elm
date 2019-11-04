module Main exposing (init, subscriptions, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Model exposing (Model)
import Msg exposing (Msg(..))
import ParseSchedule exposing (..)
import ScheduleHtml exposing (..)


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Flags =
    { scheduleString : String
    , url : String
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Schedule schedule ->
            ( model, Cmd.none )

        ToggleSubgroup ->
            case model.activeSubgroupIndex of
                1 ->
                    ( { model | activeSubgroupIndex = 2 }, Cmd.none )

                _ ->
                    ( { model | activeSubgroupIndex = 1 }, Cmd.none )

        ToggleParity ->
            case model.currentParity of
                Odd ->
                    ( { model | currentParity = Even }, Cmd.none )

                _ ->
                    ( { model | currentParity = Odd }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        produceHtml day =
            scheduleDayHtml model day

        buttonText =
            case model.activeSubgroupIndex of
                1 ->
                    "1 -> 2"

                _ ->
                    "2 -> 1"

        switchButton =
            a
                [ class "btn-floating"
                , class "btn-large"
                , class "waves-effect"
                , class "waves-light"
                , class "red"
                , class "floating-button"
                , onClick ToggleSubgroup
                ]
                [ text buttonText ]

        switchButtonParity =
            a
                [ class "btn-floating"
                , class "btn-large"
                , class "waves-effect"
                , class "waves-light"
                , class "red"
                , class "floating-button"
                , onClick ToggleParity
                ]
                [ text "parity" ]

        scheduleContainer =
            List.map produceHtml model.schedule
                |> div [ class "container" ]
    in
    div []
        [ div [ class "floating-button-container" ] [ switchButton, switchButtonParity ]
        , scheduleContainer
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        schedule =
            decodeJsonStringWithDefault scheduleDecoder flags.scheduleString

        times =
            decodeJsonStringWithDefault lectureTimesDecoder flags.scheduleString
    in
    ( { message = "Hello"
      , schedule = schedule
      , lectureTimes = times
      , activeSubgroupIndex = 1
      , currentParity = Odd
      }
    , Cmd.none
    )
