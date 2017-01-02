module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)

import Messages exposing (Message)
import Palette exposing (Palette, paletteDiv, safeHex)
import Matrix exposing (matrixDiv)

initialPalette : Palette
initialPalette = 
  [ { id=0, name="white", color=safeHex "FFFFFF" }
  , { id=1, name="light", color=safeHex "B3EFFF" }
  , { id=2, name="bright", color=safeHex "00CFFF" }
  , { id=3, name="medium", color=safeHex "046B99" }
  , { id=4, name="dark", color=safeHex "1C304A" }
  , { id=5, name="black", color=safeHex "000000" }
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

update : Message -> Palette -> Palette
update msg palette =
  case msg of
    Messages.ChangeName id newName ->
      List.map
        (\e -> if e.id == id then {e | name = newName} else e)
        palette

main =
  Html.beginnerProgram { model = initialPalette
                       , view = view
                       , update = update }
