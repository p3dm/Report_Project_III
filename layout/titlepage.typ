#import "/layout/fonts.typ": *

#let titlepage(
  title: "",
  subject: "",
  subject_description: "",
  supervisor: "",
  advisors: (),
  author: "",
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

  set par(leading: 0.5em)

  
  // --- Title Page ---
  align(center, text(font: fonts.sans, 2em, weight: 700,   " ĐẠI HỌC BÁCH KHOA HÀ NỘI"))

  align(center, text(font: fonts.sans, 1.5em, weight: 100,   " Trường Công nghệ Thông tin và Truyền thông"))
  align(center, text(font: fonts.sans, 1.5em, weight: 700,   " ------------ 🏵 ------------"))

  v(8mm)
  align(center, image("../figures/hust_logo.svg", width: 20%))

  v(6mm)
  align(center, text(font: fonts.sans, 2em, weight: 700, title))

  align(center, text(font: fonts.sans, 1.8em, weight: 100, subject + ": " +  subject_description))

  v(4mm)
  align(center, image("../figures/book.svg", width: 35%))

  v(4mm)
  let entries = ()
  entries.push(("Họ và tên: ", author))
  entries.push(("Mã số sinh viên: ", "20225361"))
  entries.push(("Mã lớp: ", "755578"))
  entries.push(("Giảng viên hướng dẫn: ", supervisor))
  // Only show advisors if there are any
  if advisors.len() > 0 {
    entries.push(("Giáo viên hướng dẫn: ", advisors.join(", ")))
  }

  align(
    center,
    grid(
      columns: 2,
      gutter: 1em,
      align: left,
      ..for (term, desc) in entries {
        (strong(term), desc)
      }
    )
  )

  v(3mm)
  align(center, "Hà Nội")
}
