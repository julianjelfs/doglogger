port module Ports exposing (..)

import Json.Encode as E



-- Outbound


port signIn : ( String, String ) -> Cmd msg


port loadCollection : String -> Cmd msg


port pooNow : () -> Cmd msg


port pooThen : Int -> Cmd msg


port deletePoo : String -> Cmd msg


port deleteWhoops : String -> Cmd msg


port enterWeight : ( Int, Float ) -> Cmd msg


port whoopsNow : () -> Cmd msg


port whoopsThen : Int -> Cmd msg


port signOut : () -> Cmd msg



-- Inbound


port signInError : (String -> msg) -> Sub msg


port receivedItems : (E.Value -> msg) -> Sub msg


port received_poos : (E.Value -> msg) -> Sub msg


port received_whoops : (E.Value -> msg) -> Sub msg


port received_weight : (E.Value -> msg) -> Sub msg


port complete : (String -> msg) -> Sub msg
