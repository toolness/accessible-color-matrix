module Matrix exposing (..)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, scope, style, title)
import Color exposing (white)

import Symbols exposing (symbols, badContrastSvg)
import ContrastRatio exposing (contrastRatio, areColorsIndistinguishable)
import Palette exposing (
  Palette, PaletteEntry, paletteEntryHex, squareBgStyle
  )

ariaHidden : Bool -> Html.Attribute msg
ariaHidden val =
  attribute "aria-hidden" (if val then "true" else "false")

role : String -> Html.Attribute msg
role val =
  attribute "role" val

badContrastLegendText : String
badContrastLegendText = """
  Please don't use these color combinations; they do not meet a color
  contrast ratio of 4.5:1, so they do not conform with the standards of
  Section 508 for body text. This means that some people would have
  difficulty reading the text. Employing accessibility best practices
  improves the user experience for all users.
"""

humanFriendlyContrastRatio : Float -> String
humanFriendlyContrastRatio ratio =
  -- Um, Elm doesn't seem to have any built-in functionality
  -- for formatting floats to strings, so I guess we'll have
  -- to improvise...
  let
    intPart = toString (floor ratio)
    decimalPart numDigits =
      toString (floor ((ratio - (toFloat (floor ratio))) * 10 ^ numDigits))
    numDigits =
      if ratio < 4 then 1 else if ratio < 5 then 2 else 0
  in
    intPart ++
      (if numDigits > 0 then "." ++ decimalPart numDigits else "") ++
        ":1"

badContrastText : PaletteEntry -> PaletteEntry -> Float -> String
badContrastText background foreground ratio =
  "Do not use " ++ foreground.name ++ " text on " ++ background.name ++
    " background; it is not 508-compliant, with a contrast ratio of " ++
      (humanFriendlyContrastRatio ratio) ++ "."

goodContrastText : PaletteEntry -> PaletteEntry -> Float -> String
goodContrastText background foreground ratio =
  "The contrast ratio of " ++ foreground.name ++ " on " ++ background.name ++
    " is " ++ (humanFriendlyContrastRatio ratio) ++ "."

legend : Html msg
legend =
  div [ class "usa-matrix-legend" ]
    [ badContrastSvg ""
    , p [ class "usa-sr-invisible", ariaHidden True ]
        [ Html.text badContrastLegendText ]
    ]

capFirst : String -> String
capFirst str =
  (String.toUpper (String.left 1 str)) ++ (String.dropLeft 1 str)

matrixTableHeader : Palette -> Html msg
matrixTableHeader palette =
  let
    fgStyle : PaletteEntry -> List (String, String)
    fgStyle entry =
      [ ("color", paletteEntryHex entry) ] ++
        if areColorsIndistinguishable entry.color white then
          -- https://css-tricks.com/adding-stroke-to-web-text/
          [ ("text-shadow"
            ,"-1px -1px 0 #000, 1px -1px 0 #000, -1px 1px 0 #000, " ++
             "1px 1px 0 #000") ]
          else []

    headerCell : PaletteEntry -> Html msg
    headerCell entry =
      td [ scope "col" ]
        [ div [ class "usa-matrix-desc" ]
          [ text (capFirst entry.name)
          , text " text"
          , br [] []
          , small [] [ text (paletteEntryHex entry) ]
          ]
        , strong [ class "usa-sr-invisible"
                 , ariaHidden True
                 , style (fgStyle entry) ]
          [ text "Aa" ]
        ]
  in
    thead []
      [ tr []
        ([ td [ scope "col" ] [] ] ++ List.map headerCell palette)
      ]

matrixTableRow : Palette -> Html msg
matrixTableRow palette =
  let
    rowHeaderCell : PaletteEntry -> Html msg
    rowHeaderCell entry =
      td [ scope "row" ]
        [ div []
          [ div [ class "usa-matrix-square"
                , style (squareBgStyle entry) ] []
          , div [ class "usa-matrix-desc" ]
            [ text (capFirst entry.name)
            , text " background"
            , br [] []
            , small [] [ text (paletteEntryHex entry) ]
            ]
          ]
        ]

    rowComboCell : PaletteEntry -> PaletteEntry -> Html msg
    rowComboCell background foreground =
      let
        ratio : Float
        ratio = contrastRatio background.color foreground.color

        validCell : Html msg
        validCell =
          td [ class "usa-matrix-valid-color-combo" ]
            [ div [ class "usa-matrix-square"
                  , style (squareBgStyle background)
                  , title (goodContrastText background foreground ratio)
                  , role "presentation" ]
                [ strong [ class "usa-sr-invisible"
                         , ariaHidden True
                         , style [("color", paletteEntryHex foreground)] ]
                    [ text "Aa" ]
                ]
            , div [ class "usa-matrix-color-combo-description" ]
              [ strong [] [ text (capFirst foreground.name) ]
              , text " text on "
              , strong [] [ text (capFirst background.name) ]
              , text " background"
              , span [ class "usa-sr-only" ]
                [ text " is 508-compliant, with a contrast ratio of "
                , text (humanFriendlyContrastRatio ratio)
                , text "."
                ]
              ]
            ]

        invalidCell : Html msg
        invalidCell =
          let
            desc = badContrastText background foreground ratio
          in
            td [ class "usa-matrix-invalid-color-combo" ]
              [ div [ role "presentation", title desc ]
                [ badContrastSvg "usa-matrix-square" ]
              , div [ class "usa-sr-only" ] [ text desc ]
              ]
      in
        if ratio >= 4.5 then validCell else invalidCell

    row : Palette -> PaletteEntry -> Html msg
    row palette background =
      tr []
        ([ rowHeaderCell background ] ++
          List.map (rowComboCell background) palette)
  in
    tbody [] (List.map (row palette) (List.reverse palette))

matrixTable : Palette -> Html msg
matrixTable palette =
  table [ class "usa-table-borderless usa-matrix" ]
    [ matrixTableHeader palette
    , matrixTableRow palette
    ]

matrixDiv : Palette -> Html msg
matrixDiv palette =
  div []
    [ symbols
    , legend
    , matrixTable palette
    ]
