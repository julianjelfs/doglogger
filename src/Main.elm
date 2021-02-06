module Main exposing (main)

import Browser
import Control exposing (..)
import Data exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Login
import Ports
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
subscriptions _ =
    Sub.batch
        [ Ports.receivedItems ReceivedItems
        , Sub.map LoginMsg Login.subscriptions
        ]
