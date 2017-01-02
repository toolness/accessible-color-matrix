module Matrix exposing (..)

import Html exposing (Html, div, p)
import Html.Attributes exposing (attribute, class)
import Svg as S
import Svg.Attributes as SA

import Palette exposing (Palette)

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

matrixDiv : Palette -> Html msg
matrixDiv palette =
  div []
    [ symbols
    , legend
    ]
