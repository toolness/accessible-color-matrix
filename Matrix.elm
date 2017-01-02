module Matrix exposing (..)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, scope, style)
import Svg as S
import Svg.Attributes as SA
import Color exposing (white)

import Palette exposing (Palette, PaletteEntry, paletteEntryHex)

badContrastId = "usa-matrix-bad-contrast-ratio"
badContrastHref = "#" ++ badContrastId

symbols : S.Svg msg
symbols =
  S.svg [ SA.class "usa-matrix-symbol-definitions" ]
    [ S.symbol [ SA.id badContrastId
               , SA.viewBox "0 0 100 100" ]
      [ S.rect [ SA.width "100"
               , SA.height "100"
               , SA.fill "#f0f0f0" ] []
      , S.line [ SA.x1 "0"
               , SA.y1 "100"
               , SA.x2 "100"
               , SA.y2 "0"
               , SA.stroke "white"
               , SA.strokeWidth "4" ] []
      ]
    ]

badContrastSvg : S.Svg msg
badContrastSvg =
  S.svg [] [ S.use [ SA.xlinkHref badContrastHref ] [] ]

ariaHidden : Bool -> Html.Attribute msg
ariaHidden val =
  attribute "aria-hidden" (if val then "true" else "false")

badContrastText : String
badContrastText = """
  Please don't use these color combinations; they do not meet a color
  contrast ratio of 4.5:1, so they do not conform with the standards of
  Section 508 for body text. This means that some people would have
  difficulty reading the text. Employing accessibility best practices
  improves the user experience for all users.
"""

legend : Html msg
legend =
  div [ class "usa-matrix-legend" ]
    [ badContrastSvg
    , p [ class "usa-sr-invisible", ariaHidden True ]
        [ Html.text badContrastText ]
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
        -- TODO: We really want to be doing some color math here to
        -- determine whether the color will be indistinguishable
        -- from its background or not, rather than comparing directly
        -- to white.
        if entry.color == white then
          -- https://css-tricks.com/adding-stroke-to-web-text/
          [ ("text-shadow"
            ,"-1px -1px 0 #000, 1px -1px 0 #000, -1px 1px 0 #000, " ++
             "1px 1px 0 #000") ]
          else []

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

matrixTable : Palette -> Html msg
matrixTable palette =
  table [ class "usa-table-borderless usa-matrix" ]
    [ matrixTableHeader palette
    ]

matrixDiv : Palette -> Html msg
matrixDiv palette =
  div []
    [ symbols
    , legend
    , matrixTable palette
    ]
