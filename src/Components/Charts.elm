module Components.Charts exposing (ChartType(..), Model, Msg, init, subscriptions, update, view)

import Components.DeleteIcon as DeleteIcon
import Date exposing (Date)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as D
import Json.Encode as E
import Ports
import Task
import Time exposing (Month(..), Posix, Zone)
import TimedEvent exposing (TimedEventLookup)


type alias TimedEvent =
    { id : String
    , timestamp : Posix
    }


type alias Weighing =
    { id : String
    , date : Posix
    , weight : Float
    }


type Model
    = Model
        { chartType : ChartType
        , zone : Zone
        , now : Posix
        , selectedDate : Date
        , poos : List TimedEvent
        , whoops : List TimedEvent
        , weights : List Weighing
        }


type Msg
    = SelectChart ChartType
    | HereAndNow ( Zone, Posix )
    | ReceivedPoos (List TimedEvent)
    | ReceivedWhoops (List TimedEvent)
    | ReceivedWeights (List Weighing)
    | PreviousDay
    | NextDay
    | DeletePoo String
    | DeleteWhoops String


type ChartType
    = NoChart
    | PooChart
    | WhoopsChart
    | WeightChart


dataForChart : ChartType -> Cmd Msg
dataForChart chartType =
    case chartType of
        NoChart ->
            Cmd.none

        PooChart ->
            Ports.loadCollection "poos"

        WhoopsChart ->
            Ports.loadCollection "whoops"

        WeightChart ->
            Ports.loadCollection "weight"


init : ChartType -> ( Model, Cmd Msg )
init chartType =
    ( Model
        { chartType = chartType
        , zone = Time.utc
        , now = Time.millisToPosix 0
        , selectedDate = Date.fromPosix Time.utc (Time.millisToPosix 0)
        , poos = []
        , whoops = []
        , weights = []
        }
    , Cmd.batch
        [ dataForChart chartType
        , Task.perform HereAndNow (Task.map2 Tuple.pair Time.here Time.now)
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    case msg of
        ReceivedPoos poos ->
            ( Model { model | poos = poos }, Cmd.none )

        ReceivedWhoops whoops ->
            ( Model { model | whoops = whoops }, Cmd.none )

        ReceivedWeights weights ->
            ( Model { model | weights = weights }, Cmd.none )

        SelectChart chartType ->
            ( Model { model | chartType = chartType }, dataForChart chartType )

        HereAndNow ( zone, now ) ->
            ( Model
                { model
                    | zone = zone
                    , now = now
                    , selectedDate = Date.fromPosix zone now
                }
            , Cmd.none
            )

        PreviousDay ->
            ( Model { model | selectedDate = Date.add Date.Days -1 model.selectedDate }
            , Cmd.none
            )

        NextDay ->
            ( Model { model | selectedDate = Date.add Date.Days 1 model.selectedDate }
            , Cmd.none
            )

        DeletePoo id ->
            ( Model model
            , Ports.deletePoo id
            )

        DeleteWhoops id ->
            ( Model model
            , Ports.deleteWhoops id
            )


view : Model -> Html Msg
view (Model model) =
    case model.chartType of
        NoChart ->
            div [ class "content" ]
                [ button [ class "chart__btn", onClick (SelectChart PooChart) ] [ text "Poo" ]
                , button [ class "chart__btn", onClick (SelectChart WhoopsChart) ] [ text "Whoops" ]
                , button [ class "chart__btn", onClick (SelectChart WeightChart) ] [ text "Weight" ]
                ]

        PooChart ->
            pooCharts (Model model)

        WhoopsChart ->
            whoopsChart (Model model)

        WeightChart ->
            weightChart (Model model)


pad : Int -> String
pad =
    String.fromInt >> String.padLeft 2 '0'


dayNav : Model -> Html Msg
dayNav (Model model) =
    let
        today =
            Date.fromPosix model.zone model.now

        allowForward =
            today /= model.selectedDate

        dateString =
            Date.format "E, dd MMM y" model.selectedDate
    in
    div [ class "chart__nav" ]
        [ div [ class "prev", onClick PreviousDay ] [ text "<" ]
        , div [] [ text dateString ]
        , if allowForward then
            div [ class "next", onClick NextDay ] [ text ">" ]

          else
            div [ class "next -disabled" ] [ text ">" ]
        ]


listOfPills : Model -> TimedEventLookup -> (String -> Msg) -> Html Msg
listOfPills (Model model) grouped onDelete =
    let
        timeString p =
            pad (Time.toHour model.zone p) ++ ":" ++ pad (Time.toMinute model.zone p)
    in
    div [ class "chart__today" ]
        (List.map
            (\event ->
                div [ class "chart__pill" ]
                    [ span [] [ text <| timeString event.timestamp ]
                    , DeleteIcon.icon (onDelete event.id)
                    ]
            )
            (TimedEvent.todaysEvents grouped model.selectedDate)
        )


whoopsChart : Model -> Html Msg
whoopsChart (Model model) =
    let
        grouped =
            TimedEvent.groupByDate model.zone model.whoops
    in
    div [ class "chart__content" ]
        [ dayNav (Model model)
        , listOfPills (Model model) grouped DeleteWhoops
        , div [ class "chart__average" ]
            [ p [ class "chart__average-legend" ] [ text "days since previous whoops" ]
            , p [ class "chart__average-value" ] [ text (String.fromInt (TimedEvent.daysSinceLast grouped model.selectedDate)) ]
            ]
        , div [ class "chart__average" ]
            [ p [ class "chart__average-legend" ] [ text "average whoops per day" ]
            , p [ class "chart__average-value" ] [ text (String.fromFloat (TimedEvent.averagePerDay grouped)) ]
            ]
        ]


pooCharts : Model -> Html Msg
pooCharts (Model model) =
    let
        grouped =
            TimedEvent.groupByDate model.zone model.poos
    in
    div [ class "chart__content" ]
        [ dayNav (Model model)
        , listOfPills (Model model) grouped DeletePoo
        , div [ class "chart__average" ]
            [ p [ class "chart__average-legend" ] [ text "average poos per day" ]
            , p [ class "chart__average-value" ] [ text (String.fromFloat (TimedEvent.averagePerDay grouped)) ]
            ]
        ]


decodeTimedEvents : (List TimedEvent -> Msg) -> (E.Value -> Msg)
decodeTimedEvents tag =
    D.decodeValue timeEventsDecoder
        >> Result.map tag
        >> Result.withDefault (tag [])


decodeWeights : (List Weighing -> Msg) -> (E.Value -> Msg)
decodeWeights tag =
    D.decodeValue weighingDecoder
        >> Result.map tag
        >> Result.withDefault (tag [])


weighingDecoder : D.Decoder (List Weighing)
weighingDecoder =
    D.list
        (D.map3 Weighing
            (D.field "id" D.string)
            (D.map Time.millisToPosix (D.field "date" D.int))
            (D.field "weight" D.float)
        )


timeEventsDecoder : D.Decoder (List TimedEvent)
timeEventsDecoder =
    D.list (D.map2 TimedEvent (D.field "id" D.string) (D.map Time.millisToPosix (D.field "timestamp" D.int)))


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    case model.chartType of
        PooChart ->
            Ports.received_poos (decodeTimedEvents ReceivedPoos)

        WhoopsChart ->
            Ports.received_whoops (decodeTimedEvents ReceivedWhoops)

        _ ->
            Ports.received_weight (decodeWeights ReceivedWeights)


weightChart : Model -> Html Msg
weightChart (Model model) =
    let
        dob =
            Date.fromCalendarDate 2020 Sep 27
    in
    div
        [ class "chart__content" ]
        (List.map
            (\w ->
                let
                    weightDate =
                        Date.fromPosix model.zone w.date

                    age =
                        Date.diff Date.Weeks dob weightDate
                in
                div [ class "chart__weight" ]
                    [ div [ class "chart__weight-date" ] [ text <| Date.format "dd MMM y" weightDate ]
                    , div [ class "chart__weight-value" ] [ text <| String.fromFloat w.weight ]
                    , div [ class "chart__weight-age" ] [ text <| String.fromInt age ]
                    ]
            )
            (model.weights
                |> List.sortBy (.date >> Time.posixToMillis)
                |> List.reverse
            )
        )
