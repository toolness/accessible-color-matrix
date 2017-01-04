module Palette exposing (..)

import Json.Decode
import Char exposing (isHexDigit)
import Html exposing (div, p, text, input, label, Html)
import Html.Attributes exposing (
  class, classList, style, type_, value, id, for, attribute
  )
import Html.Events exposing (onInput, on, targetValue)
import Color exposing (Color, white, red)
import Color.Convert exposing (colorToHex, hexToColor)

import ContrastRatio exposing (areColorsIndistinguishable)

type alias PaletteEntry =
  { id: Int
  , name: String
  , color: Color
  , editableColor: String
  }

type alias Palette = List PaletteEntry

type alias SerializedPalette = List (String, String)

type PaletteMsg = ChangeName Int String | ChangeColor Int String

updatePalette : PaletteMsg -> Palette -> Palette
updatePalette msg palette =
  case msg of
    ChangeName id newName ->
      List.map
        (\e -> if e.id == id then {e | name = newName} else e)
        palette
    ChangeColor id str ->
      let
        newColor = filterHex str
        changeColor entry =
          case hexToColor newColor of
            Nothing -> {entry | editableColor = newColor}
            Just c -> {entry | color = c, editableColor = newColor}
      in
        List.map
          (\e -> if e.id == id then (changeColor e) else e)
          palette

deserializePalette : SerializedPalette -> Palette
deserializePalette items =
  let
    entry id (name, hex) =
      { id = id
      , name = name
      , color = safeHexToColor hex
      , editableColor = filterHex hex }
  in
    List.indexedMap entry items

serializePalette : Palette -> SerializedPalette
serializePalette palette =
  List.map (\e -> (e.name, e.editableColor)) palette

arePaletteEditsValid : Palette -> Bool
arePaletteEditsValid palette =
  let
    isEntryValid entry =
      case hexToColor entry.editableColor of
        Nothing -> False
        Just c -> True
  in
    List.all isEntryValid palette

filterHex : String -> String
filterHex str =
  String.left 6 str
    |> String.toUpper
    |> String.trim
    |> String.filter isHexDigit

safeHexToColor : String -> Color
safeHexToColor hex =
  case hexToColor (filterHex hex) of
    Nothing -> red
    Just c -> c

paletteEntryHex : PaletteEntry -> String
paletteEntryHex entry =
  colorToHex entry.color |> String.toUpper

squareBgStyle : PaletteEntry -> List (String, String)
squareBgStyle entry =
  [ ("background-color", paletteEntryHex entry) ] ++
    if areColorsIndistinguishable entry.color white then
      [ ("box-shadow", "inset 0 0 0 1px #aeb0b5") ]
      else []

paletteDiv : Palette -> Bool -> Html PaletteMsg
paletteDiv palette isEditable =
  let
    makeUniqueId : String -> PaletteEntry -> String
    makeUniqueId prefix entry = prefix ++ "_" ++ (toString entry.id)

    entryName : PaletteEntry -> List (Html PaletteMsg)
    entryName entry =
      if isEditable then let inputId = makeUniqueId "color_name" entry in
        [ input [ type_ "text"
                , id inputId
                , value entry.name
                , onInput (ChangeName entry.id) ] []
        , label [ class "usa-sr-only", for inputId ]
            [ text "Color name" ]
        ]
        else [ text entry.name ]

    onJscolorChange : (String -> PaletteMsg) -> Html.Attribute PaletteMsg
    onJscolorChange tagger =
      on "change" (Json.Decode.map tagger targetValue)

    entryHex : PaletteEntry -> List (Html PaletteMsg)
    entryHex entry =
      if isEditable then let inputId = makeUniqueId "color_value" entry in
        [ input [ type_ "text"
                , id inputId
                , value entry.editableColor
                , attribute "data-jscolorify" ""
                , onJscolorChange (ChangeColor entry.id)
                , onInput (ChangeColor entry.id) ] []
        , label [ class "usa-sr-only", for inputId ]
            [ text "Color value (in hexadecimal)" ]
        ]
        else [ text (paletteEntryHex entry) ]

    isOdd : Int -> Bool
    isOdd i = i % 2 == 1

    square : Int -> PaletteEntry -> Html PaletteMsg
    square i entry =
      div [ classList [ ("usa-color-square", True)
                      , ("usa-mobile-end-row", isOdd i)
                      ]
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
      (List.indexedMap square palette)
