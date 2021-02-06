module Main exposing (main)

import Browser
import Components.Poo as Poo
import Control exposing (..)
import Data exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Login
import Ports
import Time
import View exposing (..)


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.receivedItems ReceivedItems
        , Sub.map LoginMsg Login.subscriptions
        , Time.every 1000 Tick
        , Poo.subscriptions model
        ]
