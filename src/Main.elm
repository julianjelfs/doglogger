module Main exposing (main)

import Browser
import Components.NowOrThen as NowOrThen
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
subscriptions model =
    Sub.batch
        [ Ports.receivedItems ReceivedItems
        , Sub.map LoginMsg Login.subscriptions
        , Sub.map NowOrThenMsg (NowOrThen.subscriptions model.poo)
        , Sub.map NowOrThenMsg (NowOrThen.subscriptions model.whoops)
        ]
