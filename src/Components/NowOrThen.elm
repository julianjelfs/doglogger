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
import Utils


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
                                ++ Utils.monthToNum (Time.toMonth zone now)
                                ++ "-"
                                ++ Utils.pad (Time.toDay zone now)
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
                    , Utils.parseDate model model.hour model.minute
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
                    , Utils.parseDate model model.hour model.minute
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
                    option [ value (String.fromInt n), selected (model.hour == n) ] [ text (Utils.pad n) ]
                )
                (List.range 0 23)
            )
        , select
            [ class "noworthen__min"
            , onInput UpdateMinute
            ]
            (List.map
                (\n ->
                    option [ value (String.fromInt n), selected (model.minute == n) ] [ text (Utils.pad n) ]
                )
                (List.range 0 59)
            )
        ]


subscriptions : Model -> Sub Msg
subscriptions (Model _) =
    Ports.complete OnComplete
