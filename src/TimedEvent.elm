module TimedEvent exposing (TimedEvent, TimedEventLookup, averagePerDay, daysSinceLast, groupByDate, todaysEvents)

import Date exposing (Date)
import Dict exposing (Dict)
import Time exposing (Posix, Zone)


type alias TimedEventLookup =
    Dict Int (List TimedEvent)


type alias TimedEvent =
    { id : String
    , timestamp : Posix
    }


twoDecimalPlaces : Float -> Float
twoDecimalPlaces f =
    (f * 100 |> round |> toFloat) / 100


daysSinceLast : TimedEventLookup -> Date -> Int
daysSinceLast lookup date =
    -- we need to find the highest key in the lookup >= date
    let
        rataDie =
            Date.toRataDie date

        previous =
            Dict.keys lookup
                |> List.filter (\k -> k < rataDie)
                |> List.sort
                |> List.maximum
                |> Maybe.withDefault 0
    in
    rataDie - previous


averagePerDay : TimedEventLookup -> Float
averagePerDay lookup =
    let
        keys =
            Dict.keys lookup |> List.sort

        numberOfDays =
            Maybe.map2 Tuple.pair (List.minimum keys) (List.maximum keys)
                |> Maybe.withDefault ( 0, 0 )
                |> (\( min, max ) -> max - min)

        total =
            List.concat (Dict.values lookup) |> List.length
    in
    if numberOfDays > 0 then
        twoDecimalPlaces <| toFloat total / toFloat numberOfDays

    else
        0


todaysEvents : TimedEventLookup -> Date -> List TimedEvent
todaysEvents lookup date =
    case Dict.get (Date.toRataDie date) lookup of
        Nothing ->
            []

        Just events ->
            List.sortBy (\event -> Time.posixToMillis event.timestamp) events


groupByDate : Zone -> List TimedEvent -> TimedEventLookup
groupByDate zone =
    List.foldr
        (\event dict ->
            let
                key =
                    Date.toRataDie <| Date.fromPosix zone event.timestamp
            in
            case Dict.get key dict of
                Nothing ->
                    Dict.insert key [ event ] dict

                Just list ->
                    Dict.insert key (event :: list) dict
        )
        Dict.empty
