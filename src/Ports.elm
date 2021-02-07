port module Ports exposing (..)

import Json.Encode as E


port signIn : ( String, String ) -> Cmd msg


port pooNow : () -> Cmd msg


port pooThen : Int -> Cmd msg


port whoopsNow : () -> Cmd msg


port whoopsThen : Int -> Cmd msg


port signOut : () -> Cmd msg


port signInError : (String -> msg) -> Sub msg


port receivedItems : (E.Value -> msg) -> Sub msg


port complete : (String -> msg) -> Sub msg
