module View exposing (..)

import Components.Charts as Charts exposing (ChartType(..))
import Components.EnterWeight as Weight
import Components.LogoutIcon
import Components.NowOrThen as NowOrThen
import Data exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Login


view : Model -> Html Msg
view model =
    case model.user of
        Nothing ->
            Html.map LoginMsg (Login.view model.loginModel)

        Just _ ->
            div [ class "app" ]
                [ div
                    [ class "header" ]
                    [ Components.LogoutIcon.icon SignOut
                    , h1 [ class "headline" ]
                        [ text "🐾 Doggylog 🐾"
                        ]
                    ]
                , tabs model
                , content model
                , footer model
                ]


footer : Model -> Html Msg
footer model =
    case model.selectedTab of
        PooTab ->
            a [ class "footer", onClick (SelectTab (ChartsTab PooChart)) ]
                [ text "poo data" ]

        WhoopsTab ->
            a [ class "footer", onClick (SelectTab (ChartsTab WhoopsChart)) ]
                [ text "whoopsie data" ]

        WeightTab ->
            a [ class "footer", onClick (SelectTab (ChartsTab WeightChart)) ]
                [ text "weight data" ]

        _ ->
            text ""


content : Model -> Html Msg
content model =
    case model.selectedTab of
        PooTab ->
            Html.map NowOrThenMsg (NowOrThen.view model.poo)

        WhoopsTab ->
            Html.map NowOrThenMsg (NowOrThen.view model.whoops)

        WeightTab ->
            Html.map WeightMsg (Weight.view model.weight)

        ChartsTab _ ->
            Html.map ChartsMsg (Charts.view model.charts)


whoopsie : Model -> Html Msg
whoopsie _ =
    div [ class "content" ] [ h3 [] [ text "Whoopsie" ] ]


selectedTab : Tab -> Tab -> Bool
selectedTab selected t =
    case ( selected, t ) of
        ( ChartsTab _, ChartsTab _ ) ->
            True

        _ ->
            selected == t


tabs : Model -> Html Msg
tabs model =
    let
        tab t txt =
            li
                [ class "tab"
                , classList [ ( "-selected", selectedTab model.selectedTab t ) ]
                , onClick (SelectTab t)
                ]
                [ a [] [ text txt ]
                ]
    in
    ul
        [ class "tabs" ]
        [ tab PooTab "Poo"
        , tab WhoopsTab "Whoopsie"
        , tab WeightTab "Weight"
        , tab (ChartsTab NoChart) "Data"
        ]
