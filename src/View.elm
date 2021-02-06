module View exposing (..)

import Components.Poo as Poo
import Data exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Login
import LogoutIcon


view : Model -> Html Msg
view model =
    case model.user of
        Nothing ->
            Html.map LoginMsg (Login.view model.loginModel)

        Just _ ->
            div [ class "app" ]
                [ div
                    [ class "header" ]
                    [ LogoutIcon.icon SignOut
                    , h1 [ class "headline" ]
                        [ text "🐾 Doggylog 🐾"
                        ]
                    ]
                , tabs model
                , content model
                ]


content : Model -> Html Msg
content model =
    case model.selectedTab of
        PooTab ->
            Poo.view model

        WhoopsieTab ->
            whoopsie model

        WeightTab ->
            weight model

        ChartsTab ->
            charts model


whoopsie : Model -> Html Msg
whoopsie _ =
    div [ class "content" ] [ h3 [] [ text "Whoopsie" ] ]


weight : Model -> Html Msg
weight _ =
    div [ class "content" ] [ h3 [] [ text "Weight" ] ]


charts : Model -> Html Msg
charts _ =
    div [ class "content" ] [ h3 [] [ text "Charts" ] ]


tabs : Model -> Html Msg
tabs model =
    let
        tab t txt icon =
            li
                [ class "tab"
                , classList [ ( "-selected", model.selectedTab == t ) ]
                , onClick (SelectTab t)
                ]
                [ a [] [ text txt ]
                , span [] [ text icon ]
                ]
    in
    ul
        [ class "tabs" ]
        [ tab PooTab "Poo" "💩"
        , tab WhoopsieTab "Whoopsie" "\u{1F926}"
        , tab WeightTab "Weight" "⚖️"
        , tab ChartsTab "Charts" "📈"
        ]
