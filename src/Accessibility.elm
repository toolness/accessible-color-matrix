module Accessibility exposing (..)

import Html
import Html.Attributes exposing (attribute)

ariaLabel : String -> Html.Attribute msg
ariaLabel val =
  attribute "aria-label" val

ariaHidden : Bool -> Html.Attribute msg
ariaHidden val =
  attribute "aria-hidden" (if val then "true" else "false")

role : String -> Html.Attribute msg
role val =
  attribute "role" val
