module Palette exposing (..)

import Html exposing (div, p, text, Html)
import Html.Attributes exposing (class, style)
import Color exposing (Color, white, red)
import Color.Convert exposing (colorToHex, hexToColor)

type alias PaletteEntry = { name: String, color: Color }

type alias Palette = List PaletteEntry

safeHex : String -> Color
safeHex hex =
  case hexToColor hex of
    Nothing -> red
    Just c -> c

paletteEntryHex : PaletteEntry -> String
paletteEntryHex entry =
  colorToHex entry.color |> String.toUpper

squareBgStyle : PaletteEntry -> List (String, String)
squareBgStyle entry =
  [ ("background-color", paletteEntryHex entry) ] ++
    -- TODO: We really want to be doing some color math here to
    -- determine whether the color will be indistinguishable
    -- from its background or not, rather than comparing directly
    -- to white.
    if entry.color == white then
      [ ("box-shadow", "inset 0 0 0 1px #aeb0b5") ]
      else []

paletteDiv : Palette -> Html msg
paletteDiv palette =
  let
    square : PaletteEntry -> Html msg
    square entry =
      div [ class "usa-color-square"
          , style (squareBgStyle entry) ]
        [ div [ class "usa-color-inner-content" ]
          [ p [ class "usa-color-name" ] [ text entry.name ]
          , p [ class "usa-color-hex" ] [ text (paletteEntryHex entry) ]
          ]
        ]
  in
    div [ class "usa-grid-full usa-color-row usa-primary-color-section" ]
      (List.map square palette)
