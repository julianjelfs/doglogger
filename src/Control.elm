module Control exposing (..)

import Data exposing (..)
import Login
import Ports
import SingleDatePicker exposing (TimePickerVisibility(..))
import Task
import Time


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { user = flags.user
      , loginModel = Login.init
      , selectedTab = PooTab
      , picker = SingleDatePicker.init
      , pickedTime = Nothing
      , zone = Time.utc
      , now = Time.millisToPosix 0
      }
    , Task.perform AdjustTimeZone Time.here
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoginMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    Login.update subMsg model.loginModel
            in
            ( { model | loginModel = subModel }
            , Cmd.map LoginMsg subCmd
            )

        SelectTab tab ->
            ( { model | selectedTab = tab }
            , Cmd.none
            )

        ReceivedItems _ ->
            ( model
            , Cmd.none
            )

        SignOut ->
            ( { model | user = Nothing }, Ports.signOut () )

        UpdatePicker ( newPicker, maybeNewTime ) ->
            ( { model
                | picker = newPicker
                , pickedTime = Maybe.map Just maybeNewTime |> Maybe.withDefault model.pickedTime
              }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }, Cmd.none )

        Tick p ->
            ( { model | now = p }, Cmd.none )
