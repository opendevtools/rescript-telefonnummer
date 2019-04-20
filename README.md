# Telefonnummer

![npm](https://img.shields.io/npm/v/bs-telefonnummer.svg)
[![Build Status](https://travis-ci.com/believer/bs-telefonnummer.svg?branch=master)](https://travis-ci.com/believer/bs-telefonnummer)
[![Test Coverage](https://api.codeclimate.com/v1/badges/ca9e96b91ab4cd9f683c/test_coverage)](https://codeclimate.com/github/believer/bs-telefonnummer/test_coverage)

This is a port of my library [telefonnummer](https://github.com/believer/telefonnummer) to ReasonML. It parses Swedish phone numbers into a standard format. It doesn't contain the full API of the original library as I felt it would be a good opportunity to start fresh.

## Installation

```
npm install bs-telefonnummer
```

Add `bs-telefonnummer` in `bs-dependencies` of `bsconfig.json`

## API

### parse

Takes a phone number of any kind and parses it to a standard format

```reason
let parse: Js.String.t => Js.String.t
```

#### Example

```reason
let parsedPhoneNumber = Telefonnummer.parse("081234567") /* 08-123 45 67 */
let parsedMobileNumber = Telefonnummer.parse("0701234567") /* 070-123 45 67 */
```

### typeOfNumber

Takes a phone number and returns the type. Usable for pattern-matching.

```reason
type t =
  | VoiceMail
  | Mobile
  | Landline;

let typeOfNumber: Js.String.t => t
```

#### Example

```reason
let phoneNumberType = Telefonnummer.typeOfNumber("081234567") /* Landline */
```

### Normalize

The `Normalize` module is exposed publically if you need to clean up a phone number for use in for example `tel:` links.

```reason
module Normalize = {
  let clean: Js.String.t => Js.String.t
}
```

#### Example

```reason
let cleanPhoneNumber = Telefonnummer.Normalize.clean("08-12 3 45.67") /* 081234567 */
```
