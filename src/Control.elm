module Control exposing (..)

import Data exposing (..)
import Login
import Ports


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { user = flags.user
      , loginModel = Login.init
      , selectedTab = Poo
      }
    , Cmd.none
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
