#import "/layout/fonts.typ": *

#let abstract(body, lang: "en") = {
  set page(
    margin: (left: 30mm, right: 30mm, top: 40mm, bottom: 40mm),
    numbering: none,
    number-align: center,
  )

  set text(
    font: fonts.body,
    size: 12pt,
    lang: lang,
  )

  set par(
    leading: 1em,
    justify: true,
  )

  v(1fr)
  body
  v(1fr)
}
