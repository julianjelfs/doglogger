module Login exposing (..)

import Html as H exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Ports


type alias Model =
    { username : String
    , password : String
    , error : Maybe String
    }


type Msg
    = UsernameChanged String
    | PasswordChanged String
    | Submit
    | SignInError String


init : Model
init =
    { username = "", password = "", error = Nothing }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UsernameChanged username ->
            ( { model | username = username }, Cmd.none )

        PasswordChanged password ->
            ( { model | password = password }, Cmd.none )

        Submit ->
            ( { model | error = Nothing }, Ports.signIn ( model.username, model.password ) )

        SignInError err ->
            ( { model | error = Just err }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        valid =
            model.username /= "" && model.password /= ""
    in
    fieldset
        [ id "root", class "login" ]
        [ legend [] [ text "Sign in" ]
        , H.form [ onSubmit Submit ]
            [ p []
                [ label [] [ text "Email address" ]
                , input
                    [ onInput UsernameChanged
                    , placeholder "email address"
                    , autofocus True
                    , required True
                    , autocomplete True
                    ]
                    []
                ]
            , p []
                [ label [] [ text "Password" ]
                , input
                    [ onInput PasswordChanged
                    , placeholder "password"
                    , type_ "password"
                    , required True
                    , autocomplete True
                    ]
                    []
                ]
            , button [ type_ "submit", disabled (not valid) ] [ text "Sign in" ]
            , case model.error of
                Nothing ->
                    text ""

                Just err ->
                    p [ class "error" ] [ text err ]
            ]
        ]


subscriptions : Sub Msg
subscriptions =
    Ports.signInError SignInError
