module Data exposing (Flags, Model, Msg(..), Tab(..), User)

import Components.Charts as Charts exposing (ChartType)
import Components.EnterWeight as Weight
import Components.NowOrThen as NowOrThen
import Json.Encode as E
import Login


type alias Flags =
    { user : Maybe User }


type Tab
    = PooTab
    | WhoopsTab
    | WeightTab
    | ChartsTab ChartType


type Msg
    = LoginMsg Login.Msg
    | ReceivedItems E.Value
    | SelectTab Tab
    | SignOut
    | NowOrThenMsg NowOrThen.Msg
    | WeightMsg Weight.Msg
    | ChartsMsg Charts.Msg


type alias Model =
    { user : Maybe User
    , loginModel : Login.Model
    , selectedTab : Tab
    , poo : NowOrThen.Model
    , whoops : NowOrThen.Model
    , charts : Charts.Model
    , weight : Weight.Model
    }


type alias User =
    { email : String }
