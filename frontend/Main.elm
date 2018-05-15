import Html exposing(Html, div, text, input, button)
import Html.Attributes exposing(type_, placeholder, class, value)
import Html.Events exposing(onInput, onClick)
import Json.Decode as JD
import Json.Encode as JE
import WebSocket as WS


serverUrl =
  "ws://localhost:9998"

-- Main --
main =
  Html.program
  { view = chatView
  , update = chatUpdate
  , init = chatInit
  , subscriptions = chatSubscriptions
  }

-- Json Encode --
messageEncode name msg =
  JE.object
  [ ("name", JE.string name)
  , ("msg",  JE.string msg)
  ]

-- Json Decode --
type alias JsonMessage =
  { name : String
  , msg : String
  }

messageDecode =
  JD.map2 JsonMessage
  ( JD.field "name" JD.string)
  (JD.field "msg" JD.string)

-- Message --
type Msg
  = SendMessage
  | AddName
  | Input String
  | NewMessage String


-- Model --
type alias Message =
  { name : String
  , msg : String
  }

type alias Model =
  { name : String
  , input : String
  , messages : List Message
  }

-- Init --
chatInit : (Model, Cmd msg)
chatInit =
  ( Model  "" "" [ Message "" "" ], Cmd.none)

-- View --
chatView : Model -> Html Msg
chatView model =
  case model.name of
    "" -> initialView model
    _ -> div[ ]
            [ div [] (conversationView model)
            , input [ type_ "text", value model.input, placeholder "Message", onInput Input ] []
            , button [onClick SendMessage] [text "Send message"]
            ]

initialView : Model -> Html Msg
initialView model =
  div [ class "initialView" ]
      [ input [ type_ "text", value model.input, placeholder "Enter name", onInput Input ] []
      , button [ onClick AddName ] [ text "Submit name" ]
      ]

conversationView model =
  case List.isEmpty (Debug.log "model" model.messages) of
    True -> []
    
    False -> 
            List.map (\ msg ->
                    div[] [ text (msg.name ++ "> " ++ msg.msg) ]
            ) model.messages
        

-- Update --
chatUpdate : Msg -> Model -> (Model, Cmd msg)
chatUpdate msg model =
  case msg of
    SendMessage ->
      let
          message =
            messageEncode model.name model.input
            |> JE.encode 0

          newMessage = Message model.name model.input
      in
          ( {model | messages = model.messages ++  [newMessage], input = "" }
          , WS.send serverUrl message
          )

    Input input ->
      ( {model | input = input}, Cmd.none )

    AddName ->
      ( {model | name = model.input, input = ""}, Cmd.none )

    NewMessage message ->
      let
          parsedMessage =
            case JD.decodeString messageDecode message of
              Ok response -> response
              error -> JsonMessage "error" "error"

          newMessage = Message parsedMessage.name parsedMessage.msg
      in
          ( { model | messages = model.messages ++ [ newMessage ]}, Cmd.none)

-- Subscriptions --
chatSubscriptions : Model -> Sub Msg
chatSubscriptions model =
  WS.listen serverUrl NewMessage

