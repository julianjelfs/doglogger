module Data exposing (Flags, Model, Msg(..), Tab(..), User)

import Components.NowOrThen as NowOrThen
import Json.Encode as E
import Login


type alias Flags =
    { user : Maybe User }


type Tab
    = PooTab
    | WhoopsTab
    | WeightTab
    | ChartsTab


type Msg
    = LoginMsg Login.Msg
    | ReceivedItems E.Value
    | SelectTab Tab
    | SignOut
    | NowOrThenMsg NowOrThen.Msg


type alias Model =
    { user : Maybe User
    , loginModel : Login.Model
    , selectedTab : Tab
    , poo : NowOrThen.Model
    , whoops : NowOrThen.Model
    }


type alias User =
    { email : String }
