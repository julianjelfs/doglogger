module Components.NowOrThen exposing
    ( Model(..)
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ports
import String
import Task
import Time exposing (Month(..), Posix, Zone)
import Time.Extra exposing (Parts, partsToPosix)


type Choosing
    = NotChoosing
    | ChoosingNow
    | ChoosingThen


type Model
    = Model
        { zone : Zone
        , now : Posix
        , choosing : Choosing
        , dateString : Maybe String
        , hour : Int
        , minute : Int
        , busy : Bool
        , onComplete : Choosing
        }


type Msg
    = HereAndNow ( Zone, Posix )
    | Choose Choosing
    | UpdateDate String
    | UpdateHour String
    | UpdateMinute String
    | Confirm
    | ConfirmAndRepeat
    | Cancel
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
        , choosing = NotChoosing
        , dateString = Nothing
        , hour = 0
        , minute = 0
        , busy = False
        , onComplete = NotChoosing
        }
    , Task.perform HereAndNow (Task.map2 Tuple.pair Time.here Time.now)
    )


update : (() -> Cmd Msg) -> (Int -> Cmd Msg) -> Msg -> Model -> ( Model, Cmd Msg )
update onExecuteNow onExecuteThen msg (Model model) =
    case msg of
        HereAndNow ( zone, now ) ->
            ( Model
                { model
                    | zone = zone
                    , now = now
                    , hour = Time.toHour zone now
                    , minute = Time.toMinute zone now
                    , dateString =
                        Just <|
                            String.fromInt (Time.toYear zone now)
                                ++ "-"
                                ++ monthToNum (Time.toMonth zone now)
                                ++ "-"
                                ++ pad (Time.toDay zone now)
                }
            , Cmd.none
            )

        Choose choosing ->
            ( Model { model | choosing = choosing }
            , Cmd.none
            )

        Confirm ->
            case model.choosing of
                NotChoosing ->
                    ( Model { model | choosing = NotChoosing }, Cmd.none )

                ChoosingNow ->
                    ( Model { model | busy = True, onComplete = NotChoosing }, onExecuteNow () )

                ChoosingThen ->
                    ( Model { model | busy = True, onComplete = NotChoosing }
                    , parseDate (Model model)
                        |> Maybe.map onExecuteThen
                        |> Maybe.withDefault Cmd.none
                    )

        OnComplete _ ->
            ( Model { model | busy = False, choosing = model.onComplete }, Cmd.none )

        ConfirmAndRepeat ->
            case model.choosing of
                NotChoosing ->
                    ( Model model, Cmd.none )

                ChoosingNow ->
                    ( Model { model | busy = True, onComplete = ChoosingNow }, onExecuteNow () )

                ChoosingThen ->
                    ( Model { model | busy = True, onComplete = ChoosingThen }
                    , parseDate (Model model)
                        |> Maybe.map onExecuteThen
                        |> Maybe.withDefault Cmd.none
                    )

        Cancel ->
            ( Model { model | choosing = NotChoosing }
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

        UpdateHour hour ->
            ( Model
                { model
                    | hour =
                        case String.toInt hour of
                            Nothing ->
                                model.hour

                            Just hour_ ->
                                hour_
                }
            , Cmd.none
            )

        UpdateMinute min ->
            ( Model
                { model
                    | minute =
                        case String.toInt min of
                            Nothing ->
                                model.minute

                            Just min_ ->
                                min_
                }
            , Cmd.none
            )


view : Model -> Html Msg
view (Model model) =
    let
        nowBtn =
            button
                [ class "noworthen-btn now"
                , onClick (Choose ChoosingNow)
                ]
                [ text "Now" ]

        thenBtn =
            button
                [ class "noworthen-btn before"
                , onClick (Choose ChoosingThen)
                ]
                [ text "Then" ]

        progress =
            if model.busy then
                p [ class "noworthen__progress" ]
                    [ text "busy ..." ]

            else
                text ""
    in
    div [ class "content" ]
        (case model.choosing of
            NotChoosing ->
                [ nowBtn
                , thenBtn
                ]

            ChoosingNow ->
                [ chooseNow progress
                , thenBtn
                ]

            ChoosingThen ->
                [ nowBtn
                , chooseThen progress (Model model)
                ]
        )


chooseNow : Html Msg -> Html Msg
chooseNow progress =
    div
        [ class "noworthen-btn now confirming" ]
        [ span [] [ text "Confirm?" ]
        , div [ class "yesno" ]
            [ a [ onClick Confirm ] [ text "Yes" ]
            , a [ onClick Cancel ] [ text "No" ]
            ]
        , progress
        ]


chooseThen : Html Msg -> Model -> Html Msg
chooseThen progress model =
    div
        [ class "noworthen-btn now confirming" ]
        [ span [] [ text "When?" ]
        , datetime model
        , div [ class "yesno" ]
            [ a [ onClick Confirm ] [ text "ok" ]
            , a [ onClick ConfirmAndRepeat ] [ text "ok+" ]
            , a [ onClick Cancel ] [ text "cancel" ]
            ]
        , progress
        ]


datetime : Model -> Html Msg
datetime (Model model) =
    div
        [ class "noworthen__datetime" ]
        [ input
            [ type_ "date"
            , class "noworthen__date"
            , onInput UpdateDate
            , value (Maybe.withDefault "" model.dateString)
            ]
            []
        , select
            [ class "noworthen__hour"
            , onInput UpdateHour
            ]
            (List.map
                (\n ->
                    option [ value (String.fromInt n), selected (model.hour == n) ] [ text (pad n) ]
                )
                (List.range 0 23)
            )
        , select
            [ class "noworthen__min"
            , onInput UpdateMinute
            ]
            (List.map
                (\n ->
                    option [ value (String.fromInt n), selected (model.minute == n) ] [ text (pad n) ]
                )
                (List.range 0 59)
            )
        ]


pad : Int -> String
pad =
    String.fromInt >> String.padLeft 2 '0'


subscriptions : Model -> Sub Msg
subscriptions (Model _) =
    Ports.complete OnComplete


monthToNum : Month -> String
monthToNum month =
    case month of
        Jan ->
            pad 1

        Feb ->
            pad 2

        Mar ->
            pad 3

        Apr ->
            pad 4

        May ->
            pad 5

        Jun ->
            pad 6

        Jul ->
            pad 7

        Aug ->
            pad 8

        Sep ->
            pad 9

        Oct ->
            pad 10

        Nov ->
            pad 11

        Dec ->
            pad 12


numToMonth : Int -> Month
numToMonth n =
    case n of
        1 ->
            Jan

        2 ->
            Feb

        3 ->
            Mar

        4 ->
            Apr

        5 ->
            May

        6 ->
            Jun

        7 ->
            Jul

        8 ->
            Aug

        9 ->
            Sep

        10 ->
            Oct

        11 ->
            Nov

        12 ->
            Dec

        _ ->
            Jan


parseDate : Model -> Maybe Int
parseDate (Model model) =
    Maybe.andThen
        (\dateString ->
            case String.split "-" dateString of
                y :: m :: d :: _ ->
                    Maybe.map3
                        (\y_ m_ d_ ->
                            Parts y_ (numToMonth m_) d_ model.hour model.minute 0 0
                                |> partsToPosix model.zone
                                |> Time.posixToMillis
                        )
                        (String.toInt y)
                        (String.toInt m)
                        (String.toInt d)

                _ ->
                    Nothing
        )
        model.dateString
