port module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)

import Palette exposing (
  Palette, PaletteMsg, SerializedPalette, paletteDiv,
  updatePalette, deserializePalette, serializePalette
  )
import Matrix exposing (matrixDiv)

type Message = PaletteMessage PaletteMsg | LoadPalette SerializedPalette

type alias Model =
  { palette: Palette
  }

port updateQs : SerializedPalette -> Cmd msg

port qsUpdated : (SerializedPalette -> msg) -> Sub msg

defaultPalette : SerializedPalette
defaultPalette =
  [ ("white", "ffffff")
  , ("light", "b3efff")
  , ("bright", "00cfff")
  , ("medium", "046b99")
  , ("dark", "1c304a")
  , ("black", "000000")
  ]

view : Model -> Html Message
view model =
  div []
    [ h2 [] [ text "Palette" ]
    , Html.map (\m -> PaletteMessage m) (paletteDiv model.palette True)
    , h2 [] [ text "Accessible Color Combinations" ]
    , matrixDiv model.palette
    ]

update : Message -> Model -> (Model, Cmd msg)
update message model =
  case message of
    PaletteMessage msg ->
      let
        newPalette : Palette
        newPalette = updatePalette msg model.palette
      in
        ({model | palette = newPalette},
         updateQs (serializePalette newPalette))
    LoadPalette palette ->
      ({model | palette = getPaletteOrDefault palette}, Cmd.none)

getPaletteOrDefault : SerializedPalette -> Palette
getPaletteOrDefault palette =
  if List.length palette == 0
    then deserializePalette defaultPalette
    else deserializePalette palette

init : SerializedPalette -> (Model, Cmd msg)
init qsPalette =
  ({ palette = getPaletteOrDefault qsPalette }, Cmd.none)

subscriptions : Model -> Sub Message
subscriptions model =
  qsUpdated LoadPalette

main =
  Html.programWithFlags
    { init = init
    , subscriptions = subscriptions
    , view = view
    , update = update }
