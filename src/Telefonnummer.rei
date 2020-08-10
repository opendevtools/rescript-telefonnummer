type t =
  | VoiceMail
  | Mobile
  | Landline;
module Normalize: {let clean: Js.String.t => Js.String.t;};
module Link: {let make: Js.String.t => Js.String.t;};
let typeOfNumber: Js.String.t => t;
let parse: Js.String.t => Js.String.t;
module Validate: {let isValid: string => bool;};
