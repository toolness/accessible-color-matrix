module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)

import Messages exposing (Message)
import Palette exposing (Palette, paletteDiv, createPalette, updatePalette)
import Matrix exposing (matrixDiv)

initialPalette : Palette
initialPalette = createPalette
  [ ("white", "ffffff")
  , ("light", "b3efff")
  , ("bright", "00cfff")
  , ("medium", "046b99")
  , ("dark", "1c304a")
  , ("black", "000000")
  ]

styles : Html msg
styles =
  -- This is a temporary hack until we define our own styles.
  node "link" [ rel "stylesheet"
              , href "https://pages.18f.gov/brand/css/main.css" ] []

view : Palette -> Html Message
view palette =
  div [ style [ ("padding", "0 5em") ] ]
    [ styles
    , h2 [] [ text "Palette" ]
    , paletteDiv palette True
    , h2 [] [ text "Accessible Color Combinations" ]
    , matrixDiv palette
    ]

main =
  Html.beginnerProgram { model = initialPalette
                       , view = view
                       , update = updatePalette }
