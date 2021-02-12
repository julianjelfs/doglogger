module Utils exposing (monthToNum, numToMonth, pad, parseDate)

import Time exposing (Month(..), Zone)
import Time.Extra exposing (Parts, partsToPosix)


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


pad : Int -> String
pad =
    String.fromInt >> String.padLeft 2 '0'


parseDate : { a | dateString : Maybe String, zone : Zone } -> Int -> Int -> Maybe Int
parseDate { dateString, zone } hour minute =
    Maybe.andThen
        (\dateString_ ->
            case String.split "-" dateString_ of
                y :: m :: d :: _ ->
                    Maybe.map3
                        (\y_ m_ d_ ->
                            Parts y_ (numToMonth m_) d_ hour minute 0 0
                                |> partsToPosix zone
                                |> Time.posixToMillis
                        )
                        (String.toInt y)
                        (String.toInt m)
                        (String.toInt d)

                _ ->
                    Nothing
        )
        dateString
