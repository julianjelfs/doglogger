module Components.Poo exposing (subscriptions, view)

import Data exposing (Model, Msg(..), Tab(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import SingleDatePicker exposing (Settings, TimePickerVisibility(..), defaultSettings, defaultTimePickerSettings)
import Time exposing (Month(..), Posix, Zone)


userDefinedDatePickerSettings : Zone -> Posix -> Settings Msg
userDefinedDatePickerSettings zone today =
    let
        defaults =
            defaultSettings zone UpdatePicker
    in
    { defaults
        | focusedDate = Just today
        , dateStringFn = posixToDateString
        , timePickerVisibility =
            AlwaysVisible
                { defaultTimePickerSettings
                    | timeStringFn = posixToTimeString
                }
    }


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ h3 [] [ text "💩💩💩  Log a poo  💩💩💩" ]
        , SingleDatePicker.view (userDefinedDatePickerSettings model.zone model.now) model.picker
        , a [ class "footnote", onClick (SelectTab ChartsTab) ] [ text "view poo chart" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    SingleDatePicker.subscriptions
        (userDefinedDatePickerSettings model.zone model.now)
        UpdatePicker
        model.picker


pad : Int -> String
pad =
    String.fromInt >> String.padLeft 2 '0'


monthToNmbString : Month -> String
monthToNmbString month =
    case month of
        Jan ->
            "01"

        Feb ->
            "02"

        Mar ->
            "03"

        Apr ->
            "04"

        May ->
            "05"

        Jun ->
            "06"

        Jul ->
            "07"

        Aug ->
            "08"

        Sep ->
            "09"

        Oct ->
            "10"

        Nov ->
            "11"

        Dec ->
            "12"


posixToDateString : Zone -> Posix -> String
posixToDateString zone date =
    pad (Time.toDay zone date)
        ++ "."
        ++ monthToNmbString (Time.toMonth zone date)
        ++ "."
        ++ pad (Time.toYear zone date)


posixToTimeString : Zone -> Posix -> String
posixToTimeString zone datetime =
    pad (Time.toHour zone datetime)
        ++ ":"
        ++ pad (Time.toMinute zone datetime)
        ++ ":"
        ++ pad (Time.toSecond zone datetime)
