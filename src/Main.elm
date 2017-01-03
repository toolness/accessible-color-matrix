module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)

import Palette exposing (
  Palette, PaletteMsg, SerializedPalette, paletteDiv, createPalette,
  updatePalette
  )
import Matrix exposing (matrixDiv)

type Message = PaletteMessage PaletteMsg

type alias Model =
  { palette: Palette
  }

defaultPalette : SerializedPalette
defaultPalette =
  [ ("white", "ffffff")
  , ("light", "b3efff")
  , ("bright", "00cfff")
  , ("medium", "046b99")
  , ("dark", "1c304a")
  , ("black", "000000")
  ]

view : Model -> Html Message
view model =
  div []
    [ h2 [] [ text "Palette" ]
    , Html.map (\m -> PaletteMessage m) (paletteDiv model.palette True)
    , h2 [] [ text "Accessible Color Combinations" ]
    , matrixDiv model.palette
    ]

update : Message -> Model -> (Model, Cmd msg)
update message model =
  case message of
    PaletteMessage msg ->
      ({model | palette = updatePalette msg model.palette}, Cmd.none)

subscriptions : Model -> Sub msg
subscriptions model =
  Sub.none

init : SerializedPalette -> (Model, Cmd msg)
init qsPalette =
  let
    palette = if List.length qsPalette == 0 then defaultPalette
      else qsPalette
    model = { palette = createPalette palette }
  in
    (model, Cmd.none)

main =
  Html.programWithFlags
    { init = init
    , subscriptions = subscriptions
    , view = view
    , update = update }
