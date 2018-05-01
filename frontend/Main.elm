import Html exposing (Html, div, text, input, button)
import Html.Attributes exposing (type_, value, class)
import Html.Events exposing (onInput, onClick)
import WebSocket
import Json.Decode exposing (decodeString, field, map2, string, list)
import Json.Encode exposing (encode, object)

main =
  Html.program
  { view = view
  , init = init
  , update = update
  , subscriptions = subscriptions
  }


serverUrl =
  "ws://localhost:9998/chat"


-- MODEL --
type alias Model =
  { name : String
  , messages : List String
  , input : String
  , serverResponse : String
  , participants : List String
  }

type alias NameResponse =
  { msg_type : String
  , msg : String
  }

type Msg
  = Input String
  | SubmitName
  | IncomingMessage String
  | NewMessage
  | ListenForMessage String

init : (Model, Cmd msg)
init =
  (Model "" [] "" "" [""]
  , Cmd.none)


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
  div [ class "chat" ]
      [ div [ class "participants"] (viewParticipants model)
      , div [ class "msgPanel" ] (viewMsgPanel model)
      , div [ class "inputPanel" ] [viewInputField model]
      ]

viewParticipants : Model -> List (Html msg)
viewParticipants model =
  List.map (\part -> div [class "text" ] [ text part ])
    model.participants

viewMsgPanel model =
  List.map(\message -> div [] [ text message]) model.messages

viewInputField : Model -> Html Msg
viewInputField model =
  div []
      [ input [class "inputField", value model.input, onInput Input ] []
      , button [ class "send", onClick NewMessage ] [ text "Send" ]
      ]


showMessage model =
  List.map (\message -> text message ) model.messages

-- UPDATE --
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Input input ->
      ({model | input = input }, Cmd.none)

    SubmitName ->
      let
          registerName =
            object
            [ ("type", Json.Encode.string "register_name")
            , ("name", Json.Encode.string model.input)
              ]

          response = encode 0 registerName

      in
      ({model | input = ""}
      , WebSocket.send serverUrl response
      )

    IncomingMessage resp ->
      let
          record =
            case decodeString nameResponse resp of
              Ok object -> object
              Err reason -> NameResponse "error" reason

      in
          case record.msg_type of
            "register_name" -> ({model | name = record.msg}, Cmd.none)
            _ -> ( model, Cmd.none )

    NewMessage ->
      let
          newMessage =
            object
            [ ("type", Json.Encode.string "new_message")
            , ("message", Json.Encode.string model.input)
            ]

          response = encode 0 newMessage
      in
          ( {model | input = ""}
          , WebSocket.send serverUrl response
          )

    ListenForMessage msg ->
      ( {model | messages = model.messages ++ [msg] }, Cmd.none )


-- JSON DECODE --
nameResponse =
  map2 NameResponse
    (field "response" string)
    (field "name" string)

-- SUBSCRIPTION --

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ WebSocket.listen serverUrl IncomingMessage
  ]
