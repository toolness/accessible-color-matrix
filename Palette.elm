module Palette exposing (..)

import Html exposing (div, p, text, input, Html)
import Html.Attributes exposing (class, style, type_, value)
import Html.Events exposing (onInput)
import Color exposing (Color, white, red)
import Color.Convert exposing (colorToHex, hexToColor)

import Messages exposing (Message)

type alias PaletteEntry = { id: Int, name: String, color: Color }

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

paletteDiv : Palette -> Bool -> Html Message
paletteDiv palette isEditable =
  let
    entryName : PaletteEntry -> List (Html Message)
    entryName entry =
      if isEditable then
        [ input [ type_ "text"
                , value entry.name
                , onInput (Messages.ChangeName entry.id) ] []
        ]
        else [ text entry.name ]

    entryHex : PaletteEntry -> List (Html msg)
    entryHex entry =
      if isEditable then
        -- TODO: Allow for editing of hex value.
        [ input [ type_ "text"
                , value (paletteEntryHex entry) ] []
        ]
        else [ text (paletteEntryHex entry) ]

    square : PaletteEntry -> Html Message
    square entry =
      div [ class "usa-color-square"
          , style (squareBgStyle entry) ]
        [ div [ class "usa-color-inner-content" ]
          [ p [ class "usa-color-name" ] (entryName entry)
          , p [ class "usa-color-hex" ] (entryHex entry)
          ]
        ]

    extraStyling : List (String, String)
    extraStyling =
      if isEditable then [("margin-bottom", "12rem")] else []
  in
    div [ class "usa-grid-full usa-color-row usa-primary-color-section"
        , style extraStyling ]
      (List.map square palette)
