type t =
  | VoiceMail
  | Mobile
  | Landline;
module Normalize: {let clean: Js.String.t => Js.String.t;};
let typeOfNumber: Js.String.t => t;
let parse: Js.String.t => Js.String.t;
