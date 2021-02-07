module Control exposing (..)

import Components.NowOrThen as NowOrThen
import Data exposing (..)
import Login
import Ports


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( poo, pooCmd ) =
            NowOrThen.init

        ( whoops, whoopsCmd ) =
            NowOrThen.init
    in
    ( { user = flags.user
      , loginModel = Login.init
      , selectedTab = PooTab
      , poo = poo
      , whoops = whoops
      }
    , Cmd.batch
        [ Cmd.map NowOrThenMsg pooCmd
        , Cmd.map NowOrThenMsg whoopsCmd
        ]
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

        NowOrThenMsg subMsg ->
            case model.selectedTab of
                PooTab ->
                    let
                        ( subModel, subCmd ) =
                            NowOrThen.update Ports.pooNow Ports.pooThen subMsg model.poo
                    in
                    ( { model | poo = subModel }
                    , Cmd.map NowOrThenMsg subCmd
                    )

                WhoopsTab ->
                    let
                        ( subModel, subCmd ) =
                            NowOrThen.update Ports.whoopsNow Ports.whoopsThen subMsg model.whoops
                    in
                    ( { model | whoops = subModel }
                    , Cmd.map NowOrThenMsg subCmd
                    )

                _ ->
                    ( model, Cmd.none )
