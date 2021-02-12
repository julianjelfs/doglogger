module Control exposing (..)

import Components.Charts as Charts
import Components.EnterWeight as Weight
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

        ( charts, chartsCmd ) =
            Charts.init Charts.NoChart

        ( weight, weightCmd ) =
            Weight.init
    in
    ( { user = flags.user
      , loginModel = Login.init
      , selectedTab = PooTab
      , poo = poo
      , whoops = whoops
      , charts = charts
      , weight = weight
      }
    , Cmd.batch
        [ Cmd.map NowOrThenMsg pooCmd
        , Cmd.map NowOrThenMsg whoopsCmd
        , Cmd.map ChartsMsg chartsCmd
        , Cmd.map WeightMsg weightCmd
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
            case tab of
                ChartsTab chartType ->
                    let
                        ( charts, chartsCmd ) =
                            Charts.init chartType
                    in
                    ( { model | charts = charts, selectedTab = tab }
                    , Cmd.map ChartsMsg chartsCmd
                    )

                _ ->
                    ( { model | selectedTab = tab }
                    , Cmd.none
                    )

        ReceivedItems _ ->
            ( model
            , Cmd.none
            )

        SignOut ->
            ( { model | user = Nothing }, Ports.signOut () )

        ChartsMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    Charts.update subMsg model.charts
            in
            ( { model | charts = subModel }
            , Cmd.map ChartsMsg subCmd
            )

        WeightMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    Weight.update subMsg model.weight
            in
            ( { model | weight = subModel }
            , Cmd.map WeightMsg subCmd
            )

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
