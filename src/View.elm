module View exposing (..)

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
        Poo ->
            poo model

        Whoopsie ->
            whoopsie model

        Weight ->
            weight model

        Charts ->
            charts model


poo : Model -> Html Msg
poo _ =
    div [ class "content" ] [ h3 [] [ text "Poo" ] ]


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
        [ tab Poo "Poo" "💩"
        , tab Whoopsie "Whoopsie" "\u{1F926}"
        , tab Weight "Weight" "⚖️"
        , tab Charts "Charts" "📈"
        ]
