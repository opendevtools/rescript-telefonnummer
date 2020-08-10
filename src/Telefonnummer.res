open Js.String

type t =
  | VoiceMail
  | Mobile
  | Landline

module Normalize = {
  let clean = phoneNumber => {
    let normalized =
      phoneNumber |> replace("(0)", "") |> replaceByRe(%re("/\\D+/gi"), "")
    let withPhone = from => "0" ++ (normalized |> substr(~from))

    switch (normalized |> substring(~from=0, ~to_=4)) {
    | pn when pn |> startsWith("0046") => withPhone(4)
    | pn when pn |> startsWith("460") => withPhone(3)
    | pn when pn |> startsWith("46") => withPhone(2)
    | _ => normalized
    }
  }
}

module Link = {
  let make = phoneNumber => "tel:" ++ Normalize.clean(phoneNumber)
}

module AreaCode = {
  let replacer = (regex, ~replaceWith="$1-$2 $3 $4", ()) =>
    replaceByRe(regex, replaceWith)

  module Common = {
    let fiveDigit = areaCode => {
      let regex = "^(\\d{" ++ areaCode->string_of_int ++
        "})(\\d{3})(\\d{2})$" 
      
      Js.Re.fromString(regex)
    }

    let sixDigit = areaCode =>{
      let regex = "^(\\d{" ++ areaCode->string_of_int ++
        "})(\\d{2})(\\d{2})(\\d{2})$"
      
      Js.Re.fromString(regex)
    }

    let sevenDigit = areaCode => {
      let regex = "^(\\d{" ++ areaCode->string_of_int ++
        "})(\\d{3})(\\d{2})(\\d{2})$"
      
      Js.Re.fromString(regex)
    }

    let eightDigit = areaCode => {
      let regex = "^(\\d{" ++ areaCode->string_of_int ++
        "})(\\d{3})(\\d{3})(\\d{2})$"
      
      Js.Re.fromString(regex)
    }
  }

  module Two = {
    let regex = %re("/^08/")

    let sixDigit = replacer(Common.sixDigit(2), ())
    let sevenDigit = replacer(Common.sevenDigit(2), ())
    let eightDigit = replacer(Common.eightDigit(2), ())
  }

  module Three = {
    let regex = %re(
      "/^0(1[013689]|2[0136]|3[1356]|4[0246]|54|6[03]|7[0235-9]|9[09])/"
    )

    let fiveDigit =
      replacer(Common.fiveDigit(3), ~replaceWith="$1-$2 $3", ())
    let sixDigit = replacer(Common.sixDigit(3), ())
    let sevenDigit = replacer(Common.sevenDigit(3), ())
  }

  module Four = {
    let sixDigit = replacer(Common.sixDigit(4), ())
  }

  let digits = value =>
    switch value {
    /* Two digits is only Stockholm 08 */
    | pn when pn |> Js.Re.test_(Two.regex) => #Two
    | pn when pn |> Js.Re.test_(Three.regex) => #Three
    | _ => #Four
    }
}

module VoiceMail = {
  let phoneNumbers = ["888", "333", "222", "147"]

  let isVoicemail = phoneNumber =>
    phoneNumber->Js.Array.includes(phoneNumbers)
}

module Mobile = {
  let valid = %re("/^07(0|2|3|6|9)\\d{7}$/")
  let isMobile = phoneNumber => phoneNumber |> normalize |> startsWith("07")

  let make = AreaCode.Three.sevenDigit

  let validate = normalized =>
    normalized |> Js.Re.test_(valid)
}

module Landline = {
  open AreaCode

  let findValidByRiktnummer = (digits, trailingDigits) => {
    open Js.Array

    let codes =
      Riktnummer.validRiktnummer
      |> filter(((number, _)) => number->Js.String.length === digits)
      |> map(((number, _)) => number)
      |> joinWith("|")

    let regex = "^(" ++ codes ++ ")\\d{5," ++
      trailingDigits->string_of_int ++ "}$"

    Js.Re.fromString(regex)
  }

  let validTwoDigit = %re("/^08\\d{6,7}$/")
  let validThreeDigit = findValidByRiktnummer(3, 7)
  let validFourDigit = findValidByRiktnummer(4, 6)

  let make = pn =>
    pn |> switch (pn |> digits, pn |> length) {
    | (#Two, 8) => Two.sixDigit
    | (#Two, 9) => Two.sevenDigit
    | (#Two, 10) => Two.eightDigit
    | (#Three, 8) => Three.fiveDigit
    | (#Three, 9) => Three.sixDigit
    | (#Three, 10) => Three.sevenDigit
    | (#Four, _) => Four.sixDigit
    | (_, _) => (_ => pn)
    }

  let validate = (normalized, digits) =>
    switch digits {
    | #Two => normalized |> Js.Re.test_(validTwoDigit)
    | #Three => normalized |> Js.Re.test_(validThreeDigit)
    | #Four => normalized |> Js.Re.test_(validFourDigit)
    }
}

let typeOfNumber = number =>
  switch number {
  | pn when Mobile.isMobile(pn) => Mobile
  | pn when VoiceMail.isVoicemail(pn) => VoiceMail
  | _ => Landline
  }

let parse = phoneNumber => {
  switch typeOfNumber(phoneNumber) {
  | VoiceMail => `Röstbrevlåda`
  | Mobile => phoneNumber |> Normalize.clean |> Mobile.make
  | Landline => phoneNumber |> Normalize.clean |> Landline.make
  }
}

module Validate = {
  let isValid = phoneNumber => {
    phoneNumber |> Js.Re.test_(%re("/[a-z]/gi"))
      ? false
      : {
        let normalized = Normalize.clean(phoneNumber)
        let digits = AreaCode.digits(normalized)
        let typeOfNumber = typeOfNumber(normalized)

        switch typeOfNumber {
        | VoiceMail => true
        | Mobile => Mobile.validate(normalized)
        | Landline => Landline.validate(normalized, digits)
        }
      }
  }
}
