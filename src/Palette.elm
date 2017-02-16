module Palette exposing (..)

import Json.Decode
import Char exposing (isHexDigit)
import Html exposing (div, p, text, input, label, button, ul, li, Html)
import Html.Attributes exposing (
  class, classList, style, type_, value, id, for, attribute, title
  )
import Html.Events exposing (onInput, onClick, on, targetValue)
import Color exposing (Color, white, red, black)
import Color.Convert exposing (colorToHex, hexToColor)

import ContrastRatio exposing (areColorsIndistinguishable, contrastRatio)
import Accessibility exposing (ariaLabel)

type alias PaletteEntry =
  { id: Int
  , name: String
  , color: Color
  , editableColor: String
  }

type alias Palette = List PaletteEntry

type alias SerializedPalette = List (String, String)

type PaletteMsg =
  ChangeName Int String
  | ChangeColor Int String
  | Remove Int
  | Add

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
    Remove id ->
      List.filter (\e -> e.id /= id) palette
    Add ->
      let
        newId : Int
        newId = (List.foldl max 0 (List.map .id palette)) + 1

        newColor : Color
        newColor = red
      in
        palette ++ [ { id = newId
                     , name = "Color " ++ (toString (newId + 1))
                     , color = newColor
                     , editableColor = filterHex (colorToHex newColor) } ]

deserializePalette : SerializedPalette -> Palette
deserializePalette items =
  let
    entry id (name, hex) =
      { id = id
      , name = name
      , color = safeHexToColor hex
      , editableColor = filterHex hex }
  in
    items
      |> List.indexedMap entry

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
  String.toUpper str
    |> String.trim
    |> String.filter isHexDigit
    |> String.left 6

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

paletteUl : Palette -> Bool -> Html PaletteMsg
paletteUl palette isEditable =
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
      let
        removeActions : List (Html PaletteMsg)
        removeActions =
          if isEditable && (List.length palette > 1) then
            let
              labelText = "Remove color " ++ entry.name
              isLight = contrastRatio entry.color black >
                        contrastRatio entry.color white
            in
              [ button [ onClick (Remove entry.id)
                       , classList [ ("usa-button-outline-inverse", True)
                                   , ("palette-action-remove", True)
                                   , ("palette-entry-is-light", isLight)
                                   ]
                       , ariaLabel labelText
                       , title labelText
                       ]
                  [ text "×" ]
              ]
          else []
      in
        li [ classList [ ("usa-color-square", True)
                        , ("usa-mobile-end-row", isOdd i)
                        ]
            , style (squareBgStyle entry) ]
          (removeActions ++
           [ div [ class "usa-color-inner-content" ]
             [ p [ class "usa-color-name" ] (entryName entry)
             , p [ class "usa-color-hex" ] (entryHex entry)
             ]
           ])

    addActions : List (Html PaletteMsg)
    addActions =
      if isEditable then
        [ li [ class "usa-color-square palette-action-add-wrapper" ]
            [ button [ class "usa-button-outline"
                     , ariaLabel "Add a new color"
                     , title "Add a new color"
                     , onClick Add ] [ text "+" ] ]
        ]
      else []
  in
    ul [ classList [ ("usa-grid-full", True)
                    , ("usa-color-row", True)
                    , ("usa-primary-color-section", True)
                    , ("palette-is-editable", isEditable)
                    ] ]
      ((List.indexedMap square palette) ++ addActions)
