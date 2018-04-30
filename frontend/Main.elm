import Html exposing (Html, div, text, input, button)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onInput, onClick)
import WebSocket

main =
  Html.program
  { view = view
  , init = init
  , update = update
  , subscriptions = subscriptions
  }


serverUrl =
  "ws://localhost:9998"

loginPath =
  "/login"

roomPath =
  "/room"


-- MODEL --
type alias Model =
  { name : String
  , messages : List String
  , input : String
  , serverResponse : String
  }

type Msg
  = Input String
  | SubmitName
  | NewMessage String

init : (Model, Cmd msg)
init =
  (Model "" [] "" "", Cmd.none)


-- VIEW --
view : Model -> Html Msg
view model =
  case model.name of
    "" -> loginView model
    _  -> roomView model

loginView : Model -> Html Msg
loginView model =
  div []
      [ text "Please enter your name!"
      , div[] []
      , input [type_ "text", value model.input, onInput Input ] []
      , button [ onClick SubmitName ] [ text "Submit name"]
      , div[] (showMessage model)
      ]

roomView : Model -> Html Msg
roomView model=
  div []
      [ text ("Hello " ++ model.name) ]



showMessage model =
  List.map (\message -> text message ) model.messages

-- UPDATE --
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Input input ->
      ({model | input = input }, Cmd.none)

    SubmitName ->
      ({model | input = ""}
      , WebSocket.send (serverUrl ++ loginPath) model.input
      )

    NewMessage string ->
      ({model | name = string}, Cmd.none)

-- SUBSCRIPTION --
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ WebSocket.listen (serverUrl ++ loginPath) NewMessage
  ]
