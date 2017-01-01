module Palette exposing (..)

import Html exposing (div, p, text, Html)
import Html.Attributes exposing (class, style)

type alias PaletteEntry = { name: String, hex: String }

type alias Palette = List PaletteEntry

paletteDiv : Palette -> Html msg
paletteDiv palette =
  let
    bgStyle : PaletteEntry -> List (String, String)
    bgStyle entry =
      [ ("background-color", "#" ++ entry.hex) ] ++
        -- TODO: We really want to be doing some color math here to
        -- determine whether the color will be indistinguishable
        -- from its background or not, rather than comparing directly
        -- to FFFFFF.
        if entry.hex == "FFFFFF" then
          [ ("box-shadow", "inset 0 0 0 1px #aeb0b5") ]
          else []
    square : PaletteEntry -> Html msg
    square entry =
      div [ class "usa-color-square"
          , style (bgStyle entry) ]
        [ div [ class "usa-color-inner-content" ]
          [ p [ class "usa-color-name" ] [ text entry.name ]
          , p [ class "usa-color-hex" ] [ text ("#" ++ entry.hex) ]
          ]
        ]
  in
    div [ class "usa-grid-full usa-color-row usa-primary-color-section" ]
      (List.map square palette)
