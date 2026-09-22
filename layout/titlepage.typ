#import "/layout/fonts.typ": *


#let titlepage(
  title: "",
  subject: "",
  subject_description: "",
  supervisor: "",
  advisors: (),
  author: "",
  email: "",
  major: "",
  submissionDate: "",
) = {
  set page(
    margin: (left: 20mm, right: 20mm, top: 30mm, bottom: 30mm),
    numbering: none,
    number-align: center,
  )

  set text(
    font: fonts.body,
    size: 12pt,
  )

  set par(leading: 0.4em)

  show link: it => underline(text(fill: rgb("#1a73e8"), it))

  // --- Title Page (reformatted to match provided cover image) ---
  align(center, text(font: fonts.sans, 15pt, weight: 700, "ĐẠI HỌC BÁCH KHOA HÀ NỘI"))

  v(1fr)

  align(center, text(font: fonts.sans, 25pt, weight: 800, subject))

  v(10mm)

  align(
    center,
    text(
      font: fonts.sans,
      25pt,
      weight: 700,
      title,
    ),
  )

  v(10mm)

  align(center, text(font: fonts.sans, 15pt, weight: 700, author))
  if email != "" {
    v(1mm)
    align(
      center,
      link("mailto:" + email)[
        #text(font: fonts.sans, 10pt, weight: 400, email)
      ],
    )
  }

  v(2mm)

  if major != "" {
    align(center, text(font: fonts.sans, 12pt, weight: 700, "Ngành: " + major))
  }

  v(10mm)

  v(1fr)

  let entries = ()
  entries.push(("Giảng viên hướng dẫn:", supervisor))
  for a in advisors {
    entries.push(("Đồng hướng dẫn:", a))
  }
  entries.push(("Học phần:", "Đồ án nghiên cứu cử nhân"))
  entries.push(("Trường:", "Công nghệ Thông tin và Truyền thông"))

  align(
    center,
    grid(
      columns: (auto, auto),
      column-gutter: 8mm,
      row-gutter: 4mm,
      align: (left, left),
      ..entries.map(e => (strong(e.at(0)), e.at(1))).flatten()
    ),
  )

  v(1fr)

  let date_text = submissionDate.display("[month]/[year]")
  align(center, text(font: fonts.sans, 12pt, weight: 700, "HÀ NỘI, " + date_text))
}
