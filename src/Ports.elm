port module Ports exposing (..)

import Json.Encode as E


port signIn : ( String, String ) -> Cmd msg


port signOut : () -> Cmd msg


port signInError : (String -> msg) -> Sub msg


port receivedItems : (E.Value -> msg) -> Sub msg
