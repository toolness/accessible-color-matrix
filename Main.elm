module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)

import Palette exposing (Palette, paletteDiv)

initialPalette : Palette
initialPalette = 
  [ { name="white", hex="FFFFFF" }
  , { name="light", hex="B3EFFF" }
  , { name="bright", hex="00CFFF" }
  , { name="medium", hex="046B99" }
  , { name="dark", hex="1C304A" }
  , { name="black", hex="000000" }
  ]

styles : Html msg
styles =
  -- This is a temporary hack until we define our own styles.
  node "link" [ rel "stylesheet"
              , href "https://pages.18f.gov/brand/css/main.css" ] []

main =
  div [ style [ ("padding", "0 5em") ] ]
    [ styles
    , h1 [] [ text "Palette" ]
    , paletteDiv initialPalette ]
