#import "/layout/cover.typ": *
#import "/layout/titlepage.typ": *
#import "/layout/disclaimer.typ": *
#import "/layout/acknowledgement.typ": acknowledgement as acknowledgement_layout
#import "/layout/abstract.typ": *
#import "/utils/print_page_break.typ": *
#import "/layout/fonts.typ": *
#import "/utils/diagram.typ": in-outline

#let thesis(
  title: "",
  subject: "",
  subject_description: "",
  supervisor: "",
  advisors: (),
  author: "",
  email: "",
  major: "",
  submissionDate: "",
  abstract_content: "",
  background_content: "",
  acknowledgement: "",
  is_print: false,
  body,
) = {
  // cover(
  //   title: title,
  //   subject: subject,
  //   subject_description: subject_description,
  //   author: author,
  // )

  // pagebreak()

  titlepage(
    title: title,
    subject: subject,
    subject_description: subject_description,
    supervisor: supervisor,
    advisors: advisors,
    author: author,
    email: email,
    major: major,
    submissionDate: submissionDate,
  )

  pagebreak()

  titlepage(
    title: title,
    subject: subject,
    subject_description: subject_description,
    supervisor: supervisor,
    advisors: advisors,
    author: author,
    email: email,
    major: major,
    submissionDate: submissionDate,
  )

  // print_page_break(print: is_print, to: "even")

  // disclaimer(
  //   title: title,
  //   subject: subject,
  //   subject_description: subject_description,
  //   author: author,
  // )

  // print_page_break(print: is_print)

  // acknowledgement_layout(acknowledgement)

  print_page_break(print: is_print)

  background_content
  pagebreak()

  abstract(abstract_content)
  pagebreak()

  set page(
    margin: (left: 30mm, right: 30mm, top: 40mm, bottom: 40mm),
    numbering: none,
    number-align: center,
  )

  set text(
    font: fonts.body,
    size: 12pt,
    lang: "en",
  )

  show math.equation: set text(weight: 400)

  // --- Headings ---

  show heading: set block(below: 0.85em, above: 1.75em)
  show heading: set text(font: fonts.body)
  set heading(numbering: "1.1.1.1")
  // Reference first-level headings as "chapters"
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading and el.level == 1 {
      link(
        el.location(),
        [Chapter #numbering(el.numbering, ..counter(heading).at(el.location()))],
      )
    } else {
      it
    }
  }

  // --- Paragraphs ---
  set par(leading: 1em)

  // --- Citations ---
  set cite(style: "/layout/cite.cls")

  // --- Figures ---
  show figure: set text(size: 0.85em)
  show figure.where(kind: image): set figure(supplement: "Hình")
  show figure.where(kind: table): set figure(supplement: "Bảng")

  show figure.caption: c => {
    let supplement = if c.kind == image { "Hình" } else if c.kind == table { "Bảng" } else { c.supplement }
    let cnt = if c.kind == image {
      counter(figure.where(kind: image))
    } else if c.kind == table {
      counter(figure.where(kind: table))
    } else {
      counter(figure)
    }
    context [
      #supplement #cnt.display(c.numbering):
      #c.body
    ]
  }

  // --- Table of Contents ---
  show outline.entry.where(level: 1): it => {
    v(15pt, weak: true)
    strong(it)
  }
  outline(
    title: {
      text(font: fonts.body, 1.5em, weight: 700, "Mục lục")
      v(15mm)
    },
    indent: 2em,
    depth: 4,
  )

  v(2.4fr)
  pagebreak()

  // List of figures.
  heading(numbering: none)[Danh mục hình ảnh]
  show outline: it => {
    // Show only the short caption here
    in-outline.update(true)
    it
    in-outline.update(false)
  }
  show outline.entry.where(level: 1): it => {
    if it.element != none and it.element.func() == figure and it.element.kind == image {
      link(it.element.location(), it.indented(
        context [Hình #counter(figure.where(kind: image)).at(it.element.location()).first()],
        it.inner(),
      ))
    } else {
      it
    }
  }
  outline(
    title: "",
    target: figure.where(kind: image),
  )

  // List of tables.
  context [
    #if query(figure.where(kind: table)).len() > 0 {
      pagebreak()
      heading(numbering: none)[Danh mục Bảng biểu]
      show outline.entry.where(level: 1): it => {
        if it.element != none and it.element.func() == figure and it.element.kind == table {
          link(it.element.location(), it.indented(
            context [Bảng #counter(figure.where(kind: table)).at(it.element.location()).first()],
            it.inner(),
          ))
        } else {
          it
        }
      }
      outline(
        title: "",
        target: figure.where(kind: table),
      )
    }
  ]

  pagebreak()

  // Main body. Reset page numbering.
  set page(numbering: "1")
  counter(page).update(1)
  set par(justify: true, first-line-indent: (amount: 2em, all: true))

  body

  // Appendix.
  // pagebreak()
  // heading(numbering: none)[Phụ lục]
  // include("/layout/appendix.typ")

  pagebreak()
  bibliography(title: "TÀI LIỆU THAM KHẢO", "/thesis.yml", style: "/layout/cite.cls", full: true)
}
