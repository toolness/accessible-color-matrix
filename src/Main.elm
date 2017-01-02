module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)

import Palette exposing (
  Palette, PaletteMsg, paletteDiv, createPalette, updatePalette
  )
import Matrix exposing (matrixDiv)

type Message = PaletteMessage PaletteMsg

type alias Model =
  { palette: Palette
  }

initialPalette : Palette
initialPalette = createPalette
  [ ("white", "ffffff")
  , ("light", "b3efff")
  , ("bright", "00cfff")
  , ("medium", "046b99")
  , ("dark", "1c304a")
  , ("black", "000000")
  ]

model : Model
model =
  { palette = initialPalette
  }

view : Model -> Html Message
view model =
  div []
    [ h2 [] [ text "Palette" ]
    , Html.map (\m -> PaletteMessage m) (paletteDiv model.palette True)
    , h2 [] [ text "Accessible Color Combinations" ]
    , matrixDiv model.palette
    ]

update : Message -> Model -> Model
update message model =
  case message of
    PaletteMessage msg ->
      {model | palette = updatePalette msg model.palette}

main =
  Html.beginnerProgram { model = model
                       , view = view
                       , update = update }
