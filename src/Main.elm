import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Browser
import Json.Decode as Decode

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
    }


type alias Model =
    { input : String
    , response : String
    }


type Msg
    = Validate String
    | TxInfo (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        TxInfo result ->
          case result of
            Ok info ->
              ( { model | response = info }
              , Cmd.none
              )

            Err _ ->
              ( { model | response = "Error" }
              , Cmd.none
              )

        Validate txHash ->
            if String.length txHash == 64 then
              ( { model
                  | response = "Requesting..."
                }
              , getTxInfo txHash
              )
            else
              ( model, Cmd.none )


getTxInfo : String -> Cmd Msg
getTxInfo txHash =
  Http.send TxInfo (Http.getString (blockChairApi txHash))


blockChairApi : String -> String
blockChairApi txHash =
  "https://api.blockchair.com/bitcoin-cash/transactions?q=hash(" ++ txHash ++ ")"


-- blockChairDecoder : Decode.Decoder String
-- blockChairDecoder =
--   Decode.string

view : Model -> Html Msg
view model =
    div []
    [ input
      [ onInput Validate
      ]
      []
    , div [] [ text model.response ]
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : () -> ( Model, Cmd Msg)
init _ =
    ( Model "" "Please enter the transaction hash."
    , Cmd.none
    )
