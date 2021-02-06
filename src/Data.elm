module Data exposing (Flags, Model, Msg(..), Tab(..), User)

import Json.Encode as E
import Login
import SingleDatePicker exposing (Settings, TimePickerVisibility(..), defaultSettings, defaultTimePickerSettings)
import Time exposing (Posix, Zone)


type alias Flags =
    { user : Maybe User }


type Tab
    = PooTab
    | WhoopsieTab
    | WeightTab
    | ChartsTab


type Msg
    = LoginMsg Login.Msg
    | ReceivedItems E.Value
    | SelectTab Tab
    | SignOut
    | UpdatePicker ( SingleDatePicker.DatePicker, Maybe Posix )
    | AdjustTimeZone Zone
    | Tick Posix


type alias Model =
    { user : Maybe User
    , loginModel : Login.Model
    , selectedTab : Tab
    , picker : SingleDatePicker.DatePicker
    , pickedTime : Maybe Posix
    , zone : Zone
    , now : Posix
    }


type alias User =
    { email : String }
