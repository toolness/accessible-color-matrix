module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode exposing (succeed)

import Palette exposing (
  Palette, PaletteMsg, paletteDiv, createPalette, updatePalette
  )
import Matrix exposing (matrixDiv)

type Message = PaletteMessage PaletteMsg | StylesLoaded

type alias Model =
  { palette: Palette
  , stylesLoaded: Bool
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
  , stylesLoaded = False
  }

styledContent : Model -> List (Html Message) -> Html Message
styledContent model content =
  -- This is a temporary hack until we define our own styles.
  div [] (
    [ node "link"
      [ rel "stylesheet"
      , href "main.css"
      , on "load" (succeed StylesLoaded)
      ] []
    ] ++ (if model.stylesLoaded then content else []))

view : Model -> Html Message
view model =
  div [ style [ ("padding", "0 5em") ] ]
    [ styledContent model
      [ h2 [] [ text "Palette" ]
      , Html.map (\m -> PaletteMessage m) (paletteDiv model.palette True)
      , h2 [] [ text "Accessible Color Combinations" ]
      , matrixDiv model.palette
      ]
    ]

update : Message -> Model -> Model
update message model =
  case message of
    PaletteMessage msg ->
      {model | palette = updatePalette msg model.palette}
    StylesLoaded ->
      {model | stylesLoaded = True}

main =
  Html.beginnerProgram { model = model
                       , view = view
                       , update = update }
