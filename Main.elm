module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)

import Palette exposing (Palette, paletteDiv, safeHex)
import Matrix exposing (matrixDiv)
import ContrastRatio exposing (contrastRatio)

initialPalette : Palette
initialPalette = 
  [ { name="white", color=safeHex "FFFFFF" }
  , { name="light", color=safeHex "B3EFFF" }
  , { name="bright", color=safeHex "00CFFF" }
  , { name="medium", color=safeHex "046B99" }
  , { name="dark", color=safeHex "1C304A" }
  , { name="black", color=safeHex "000000" }
  ]

styles : Html msg
styles =
  -- This is a temporary hack until we define our own styles.
  node "link" [ rel "stylesheet"
              , href "https://pages.18f.gov/brand/css/main.css" ] []

main =
  div [ style [ ("padding", "0 5em") ] ]
    [ styles
    , h2 [] [ text "Palette" ]
    , paletteDiv initialPalette
    , h2 [] [ text "Matrix" ]
    , matrixDiv initialPalette

    -- TODO: This part is temporary.
    , p []
      [ contrastRatio (safeHex "FFFFFF") (safeHex "000000")
          |> toString
          |> (++) "The contrast ratio of white on black is: "
          |> text
      ]
    ]
