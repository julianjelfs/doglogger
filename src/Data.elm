module Data exposing (Flags, Model, Msg(..), Tab(..), User)

import Json.Encode as E
import Login


type alias Flags =
    { user : Maybe User }


type Tab
    = Poo
    | Whoopsie
    | Weight
    | Charts


type Msg
    = LoginMsg Login.Msg
    | ReceivedItems E.Value
    | SelectTab Tab
    | SignOut


type alias Model =
    { user : Maybe User
    , loginModel : Login.Model
    , selectedTab : Tab
    }


type alias User =
    { email : String }
