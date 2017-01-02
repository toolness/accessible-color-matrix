module Palette exposing (..)

import Html exposing (div, p, text, input, label, Html)
import Html.Attributes exposing (class, style, type_, value, id, for)
import Html.Events exposing (onInput)
import Color exposing (Color, white, red)
import Color.Convert exposing (colorToHex, hexToColor)

import Messages exposing (Message)

type alias PaletteEntry =
  { id: Int
  , name: String
  , color: Color
  , editableColor: String
  }

type alias Palette = List PaletteEntry

updatePalette : Message -> Palette -> Palette
updatePalette msg palette =
  case msg of
    Messages.ChangeName id newName ->
      List.map
        (\e -> if e.id == id then {e | name = newName} else e)
        palette
    Messages.ChangeColor id newColor ->
      let
        changeColor entry =
          case hexToColor newColor of
            Nothing -> {entry | editableColor = newColor}
            Just c -> {entry | color = c, editableColor = newColor}
      in
        List.map
          (\e -> if e.id == id then (changeColor e) else e)
          palette

createPalette : List (String, String) -> Palette
createPalette items =
  let
    entry id (name, hex) =
      { id = id
      , name = name
      , color = safeHex hex
      , editableColor = hex }
  in
    List.indexedMap entry items

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
    makeUniqueId : String -> PaletteEntry -> String
    makeUniqueId prefix entry = prefix ++ "_" ++ (toString entry.id)

    entryName : PaletteEntry -> List (Html Message)
    entryName entry =
      if isEditable then let inputId = makeUniqueId "color_name" entry in
        [ input [ type_ "text"
                , id inputId
                , value entry.name
                , onInput (Messages.ChangeName entry.id) ] []
        , label [ class "usa-sr-only", for inputId ]
            [ text "Color name" ]
        ]
        else [ text entry.name ]

    entryHex : PaletteEntry -> List (Html Message)
    entryHex entry =
      if isEditable then let inputId = makeUniqueId "color_value" entry in
        [ input [ type_ "text"
                , id inputId
                , value entry.editableColor
                , onInput (Messages.ChangeColor entry.id) ] []
        , label [ class "usa-sr-only", for inputId ]
            [ text "Color value (in hexadecimal)" ]
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
