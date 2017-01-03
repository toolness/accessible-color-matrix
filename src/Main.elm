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

defaultPalette : Palette
defaultPalette = createPalette
  [ ("white", "ffffff")
  , ("light", "b3efff")
  , ("bright", "00cfff")
  , ("medium", "046b99")
  , ("dark", "1c304a")
  , ("black", "000000")
  ]

model : Model
model =
  { palette = defaultPalette
  }

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
init initialPalette =
  if List.length initialPalette == 0 then
    (model, Cmd.none)
    else ({model | palette = createPalette initialPalette}, Cmd.none)

main =
  Html.programWithFlags
    { init = init
    , subscriptions = subscriptions
    , view = view
    , update = update }
