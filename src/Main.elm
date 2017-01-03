port module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Palette exposing (
  Palette, PaletteMsg, SerializedPalette, paletteDiv,
  updatePalette, deserializePalette, serializePalette,
  arePaletteEditsValid
  )
import Matrix exposing (matrixDiv)

type Message =
  PaletteMessage PaletteMsg
  | LoadPalette SerializedPalette
  | StartEditing
  | FinishEditing
  | CancelEditing

type alias Model =
  { palette: Palette
  , isEditing: Bool
  , lastPalette: Palette
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

actions : Model -> Html Message
actions model =
  let
    edit =
      [ button [ onClick StartEditing ] [ text "Edit palette" ] ]

    -- TODO: If enter/esc is pressed in a field while editing, it
    -- should have the same effect as pressing the save/cancel buttons.
    -- Well, at least enter should, since it's easily undoable.
    saveOrCancel =
      [ button
        ([ onClick FinishEditing ] ++
          if arePaletteEditsValid model.palette
            then [] else [ disabled True, class "usa-button-disabled" ])
        [ text "Save changes" ]
      , button [ onClick CancelEditing
               , class "usa-button-secondary" ] [ text "Cancel" ]
      ]
  in
    div [ class "usa-grid-full usa-color-row" ]
      (if model.isEditing then saveOrCancel else edit)

view : Model -> Html Message
view model =
  div []
    [ h1 [] [ text "Accessible color palette builder" ]
    , Html.map (\m -> PaletteMessage m)
      (paletteDiv model.palette model.isEditing)
    , actions model
    , h2 [] [ text "Accessible color combinations" ]
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
        ({model | palette = newPalette}, Cmd.none)
    LoadPalette palette ->
      ({model | palette = getPaletteOrDefault palette
              , isEditing = False}, Cmd.none)
    StartEditing ->
      ({model | isEditing = True
              , lastPalette = model.palette}, Cmd.none)
    FinishEditing ->
      ({model | isEditing = False},
        updateQs (serializePalette model.palette))
    CancelEditing ->
      ({model | isEditing = False
              , palette = model.lastPalette}, Cmd.none)

getPaletteOrDefault : SerializedPalette -> Palette
getPaletteOrDefault palette =
  if List.length palette == 0
    then deserializePalette defaultPalette
    else deserializePalette palette

init : SerializedPalette -> (Model, Cmd msg)
init qsPalette =
  ({ palette = getPaletteOrDefault qsPalette
   , isEditing = False
   , lastPalette = [] }, Cmd.none)

subscriptions : Model -> Sub Message
subscriptions model =
  qsUpdated LoadPalette

main =
  Html.programWithFlags
    { init = init
    , subscriptions = subscriptions
    , view = view
    , update = update }
