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
type alias Model =
        { name : String
        , input : String
        , msg : String
        , listOfMsgs : List String
        }

-- Init --
chatInit : (Model, Cmd msg)
chatInit =
        ( Model "" "" "" [""], Cmd.none)

-- View --
chatView : Model -> Html Msg
chatView model =
        case model.name of
                "" -> initialView model 
                _ -> div[ ]
                        [ div [] (converstationView model)
                        , input [ type_ "text", value model.input, placeholder "Message", onInput Input ] []
                        , button [onClick SendMessage] [text "Send message"]
                        ] 

initialView : Model -> Html Msg
initialView model =
        div [ class "initialView" ]
            [ input [ type_ "text", value model.input, placeholder "Enter name", onInput Input ] []
            , button [ onClick AddName ] [ text "Submit name" ]
            ]

converstationView model =
        List.map (\ msg ->
                div[] [ text (model.name ++ "> " ++ msg) ]
                ) model.listOfMsgs


-- Update --
chatUpdate : Msg -> Model -> (Model, Cmd msg)
chatUpdate msg model =
        case msg of
                SendMessage ->
                        let
                            message = 
                                    messageEncode model.name model.input
                                    |> JE.encode 0
                                    |> Debug.log "message"
                        in
                        ( {model | listOfMsgs = List.append model.listOfMsgs  [model.input], input = "" }
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
                        in
                           ( { model | name = parsedMessage.name, listOfMsgs = model.listOfMsgs ++ [parsedMessage.msg]}, Cmd.none)

-- Subscriptions --
chatSubscriptions : Model -> Sub Msg
chatSubscriptions model =
        WS.listen serverUrl NewMessage
        
                
