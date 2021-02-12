module Components.EnterWeight exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Ports
import Task
import Time exposing (Posix, Zone)
import Utils


type Model
    = Model
        { zone : Zone
        , now : Posix
        , dateString : Maybe String
        , busy : Bool
        , weightString : Maybe String
        }


type Msg
    = HereAndNow ( Zone, Posix )
    | UpdateDate String
    | UpdateWeight String
    | EnterWeight Int Float
    | OnComplete String


init : ( Model, Cmd Msg )
init =
    let
        now =
            Time.millisToPosix 0

        zone =
            Time.utc
    in
    ( Model
        { zone = zone
        , now = now
        , dateString = Nothing
        , busy = False
        , weightString = Nothing
        }
    , Task.perform HereAndNow (Task.map2 Tuple.pair Time.here Time.now)
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    case msg of
        HereAndNow ( zone, now ) ->
            ( Model
                { model
                    | zone = zone
                    , now = now
                    , dateString =
                        Just <|
                            String.fromInt (Time.toYear zone now)
                                ++ "-"
                                ++ Utils.monthToNum (Time.toMonth zone now)
                                ++ "-"
                                ++ Utils.pad (Time.toDay zone now)
                }
            , Cmd.none
            )

        UpdateDate date ->
            ( Model
                { model
                    | dateString =
                        if date == "" then
                            Nothing

                        else
                            Just date
                }
            , Cmd.none
            )

        UpdateWeight weight ->
            ( Model
                { model
                    | weightString =
                        if weight == "" then
                            Nothing

                        else
                            Just weight
                }
            , Cmd.none
            )

        EnterWeight date weight ->
            ( Model { model | busy = True }
            , Ports.enterWeight ( date, weight )
            )

        OnComplete _ ->
            ( Model { model | busy = False }, Cmd.none )


parseWeight : Maybe String -> Maybe Float
parseWeight =
    Maybe.andThen String.toFloat


view : Model -> Html Msg
view (Model model) =
    let
        enterMsg =
            Maybe.map2 EnterWeight (Utils.parseDate model 12 0) (parseWeight model.weightString)

        btnAttrs =
            [ class "weight__btn", disabled (enterMsg == Nothing || model.busy) ]
    in
    div [ class "content weight__content" ]
        [ h5 [] [ text "Record a new weight (kg)" ]
        , input
            [ type_ "date"
            , class "weight__date"
            , onInput UpdateDate
            , value (Maybe.withDefault "" model.dateString)
            , placeholder "Select the date"
            ]
            []
        , input
            [ type_ "number"
            , class "weight__kg"
            , onInput UpdateWeight
            , value (Maybe.withDefault "" model.weightString)
            , placeholder "Enter the weight in kg"
            ]
            []
        , button
            (case enterMsg of
                Nothing ->
                    btnAttrs

                Just msg ->
                    onClick msg :: btnAttrs
            )
            [ text "Enter" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions (Model _) =
    Ports.complete OnComplete
