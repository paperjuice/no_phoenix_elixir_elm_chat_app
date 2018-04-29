import Html exposing (Html, div, text)

main =
  Html.program
  { view = view
  , init = init
  , update = update
  , subscriptions = subscriptions
  }

-- MODEL --
type alias Model =
  { name : String
  , messages : List String
  , input : String
  }

type Msg
  = Input String

init: (Model, Cmd Msg)
init =
  (Model "" [] "", Cmd.none)


-- VIEW --
view : Model -> Html msg
view model =
  div []
      [ text "merge" ]


-- UPDATE --
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Input input ->
      ({model | input = input }, Cmd.none)

-- SUBSCRIPTION --
subscriptions model =
  Sub.none
