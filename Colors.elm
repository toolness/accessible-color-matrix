import Html exposing (..)
import Html.Attributes exposing (..)

type alias PaletteEntry = { name: String, hex: String }

type alias Palette = List PaletteEntry

initialPalette : Palette
initialPalette = 
  [ { name="white", hex="FFFFFF" }
  , { name="light", hex="B3EFFF" }
  , { name="bright", hex="00CFFF" }
  , { name="medium", hex="046B99" }
  , { name="dark", hex="1C304A" }
  , { name="black", hex="000000" }
  ]

paletteHtml : Palette -> Html msg
paletteHtml palette =
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

styles : Html msg
styles =
  -- This is a temporary hack until we define our own styles.
  node "link" [ rel "stylesheet"
              , href "https://pages.18f.gov/brand/css/main.css" ] []

main =
  div [ style [ ("padding", "0 5em") ] ]
    [ styles
    , h1 [] [ text "Palette" ]
    , paletteHtml initialPalette ]
