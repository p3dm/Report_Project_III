= Nền tảng kỹ thuật và công nghệ

== Công nghệ sử dụng

=== Android Camera API

Android Camera API là bộ công cụ lập trình ứng dụng (Application Programming Interface) cho phép các nhà phát triển tương tác và kiểm soát phần cứng camera trên thiết bị Android. API này cung cấp các chức năng từ cơ bản đến nâng cao để xây dựng các ứng dụng liên quan đến chụp ảnh, quay video và xử lý hình ảnh.


==== Cấu hình SDK

Ứng dụng được cấu hình với các phiên bản SDK phù hợp để tối ưu hóa hiệu suất và bảo mật:

#figure(
  table(
    columns: (25%, 15%, 60%),
    align: (left, center, left),
    table.header(
      [*Tham số SDK*], [*Giá trị*], [*Giải thích*]
    ),
    [compileSdk], [36], [Sử dụng tối đa các tính năng hiện đại (hiệu năng, bảo mật, UI mới) ở các dòng máy mới nhất (Android 16 trở lên)],
    [minSdk], [24], [Ứng dụng hoạt động trên thiết bị Android 7.0 trở lên. MinSdk cao giúp tối ưu hóa trải nghiệm và giảm lỗi API cũ, mặc dù loại trừ một số thiết bị cũ],
    [targetSdk], [36], [TargetSdk cao đảm bảo bảo mật tốt nhất, hiệu năng cao và khả năng chấp nhận trên Google Play]
  ),
  caption: "Cấu hình SDK của ứng dụng"
)

*Ưu điểm của cấu hình này:*
- Loại bỏ các vấn đề tương thích với API cũ (< Android 7.0)
- Tận dụng đầy đủ các tính năng bảo mật và hiệu năng mới
- Đảm bảo tuân thủ yêu cầu của Google Play Store

==== So sánh các phiên bản Camera API

Android cung cấp ba API chính để làm việc với camera:

#figure(
  table(
    columns: (25%, 25%, 25%, 25%),
    align: (left, left, left, left),
    table.header(
      [*API*], [*Phiên bản*], [*Tính năng chính*], [*Khuyến nghị*]
    ),
    [Camera (Legacy)], [API Level 1+], [Đơn giản, dễ sử dụng], [Không khuyến nghị],
    [Camera2], [API Level 21+], [Kiểm soát chi tiết, hiệu năng cao], [Khuyến nghị cho ứng dụng mới],
    [CameraX], [API Level 21+], [Đơn giản hóa Camera2, lifecycle-aware], [Khuyến nghị mạnh mẽ]
  ),
  caption: "So sánh các phiên bản Android Camera API"
)

==== Thư viện Dependencies

Ứng dụng sử dụng các thư viện AndroidX và CameraX hiện đại:

#figure(
  table(
    columns: (60%, 15%, 35%),
    align: (left, center, center),
    table.header(
      [*Dependency*], [*Phiên bản*], [*Tương thích API*]
    ),
    [`androidx.core:core-ktx`], [1.16.0], [API 21+ (khuyên dùng 23+)],
    [`androidx.appcompat:appcompat`], [1.7.1], [API 16+],
    [`com.google.android.material:material`], [1.13.0], [API 21+],
    [`androidx.activity:activity-ktx`], [1.10.0], [API 23+],
    [`androidx.constraintlayout:constraintlayout`], [2.2.1], [API 14+],
    [`CameraX (toàn bộ các gói)`], [1.5.1], [API 23+]
  ),

  caption: "Các dependencies chính của ứng dụng"
)

*Lợi ích của các thư viện này:*

- *AndroidX*: Thư viện hiện đại, tách biệt khỏi Android Platform, cập nhật độc lập

- *CameraX 1.5.1*: Phiên bản ổn định mới nhất, hỗ trợ đầy đủ các tính năng camera hiện đại

- *Material Design*: Giao diện đẹp mắt, tuân thủ chuẩn thiết kế của Google

- *ConstraintLayout*: Layout linh hoạt, hiệu suất cao cho UI phức tạp

==== CameraX - API được khuyến nghị

CameraX là thư viện Jetpack được Google phát triển nhằm đơn giản hóa việc làm việc với camera, đồng thời vẫn tận dụng sức mạnh của Camera2.

*Ưu điểm chính:*

- *Lifecycle-aware*: Tự động quản lý vòng đời camera theo lifecycle của Activity/Fragment

- *Tương thích ngược*: Hoạt động trên Android 5.0 (API 21) trở lên

- *Nhất quán*: Hoạt động tương tự trên các thiết bị khác nhau

- *Extensible*: Hỗ trợ các use case mở rộng

*Các use case chính:*

#figure(
  table(
    columns: (30%, 70%),
    align: (left, left),
    table.header(
      [*Use Case*], [*Mô tả*]
    ),
    [Preview], [Hiển thị luồng camera trực tiếp lên màn hình],
    [Image Capture], [Chụp và lưu hình ảnh chất lượng cao],
    [Image Analysis], [Phân tích từng frame để xử lý (ML, QR code, etc.)],
    [Video Capture], [Quay và lưu video với âm thanh]
  ),
  caption: "Các use case của CameraX"
)

==== Kiến trúc và luồng hoạt động

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#figure(
  diagram(
    spacing: (16mm, 16mm),
    edge-stroke: 1pt,
    node-stroke: 1pt,
    node-fill: white,
    node-corner-radius: 3pt,
    
    node((0, 0), "CameraProvider", shape: rect),
    edge("->", label: "Bind"),
    node((1, 0), "Lifecycle Owner", shape: rect),
    
    node((0, 1), "Preview Use Case", shape: rect),
    edge((0, 0), "->", (0, 1)),
    
    node((1, 1), "ImageCapture Use Case", shape: rect),
    edge((1, 0), "->", (1, 1)),
    
    node((2, 1), "ImageAnalysis Use Case", shape: rect),
    edge((1, 0), "->", (2, 1)),
    
    edge((0, 1), "->", label: "Surface"),
    node((0, 2), "PreviewView", shape: rect),
    
    edge((1, 1), "->", label: "Callback"),
    node((1, 2), "Image File", shape: rect),
    
    edge((2, 1), "->", label: "Analyzer"),
  
  ),
  caption: "Kiến trúc và luồng dữ liệu CameraX"
)

==== Cấu trúc ứng dụng

***AndroidManifest.xml***

File `AndroidManifest.xml` là trung tâm định nghĩa cấu hình, quyền truy cập và các tài nguyên quan trọng cho ứng dụng.

*Các thành phần chính:*

#figure(
  table(
    columns: (30%, 70%),
    align: (left, left),
    table.header(
      [*Thành phần*], [*Mô tả*]
    ),
    [*Permissions*], [
      - `CAMERA`: Quyền truy cập camera
      - `RECORD_AUDIO`: Quyền ghi âm cho video
      - `WRITE_EXTERNAL_STORAGE`: Lưu dữ liệu (chỉ cho maxSdk 28)
    ],
    [*Features*], [
      - `<uses-feature>` yêu cầu thiết bị phải có phần cứng camera
      - Bảo vệ khỏi việc cài đặt trên thiết bị không hỗ trợ
    ],
    [*Application*], [
      - Quản lý icon, nhãn, theme
      - Cấu hình backup & restore
      - Định nghĩa MainActivity với intent-filter
      - `tools:targetApi="31"` tối ưu hóa cho API cao
    ],
    [*Security*], [
      - Quy tắc backup được cấu hình riêng qua resource XML
      - `allowBackup`, `supportsRtl` nâng cao trải nghiệm
      - Đảm bảo an toàn dữ liệu ứng dụng
    ]
  ),
  caption: "Các thành phần chính trong AndroidManifest.xml"
)

***activity_main.xml***

Layout chính của ứng dụng sử dụng `ConstraintLayout` - loại layout mạnh mẽ, đơn giản hóa việc xây dựng UI phức tạp và phản hồi tốt trên nhiều kích thước màn hình.

*Các thành phần UI chính:*

#figure(
  table(
    columns: (30%, 70%),
    align: (left, left),
    table.header(
      [*Component*], [*Chức năng*]
    ),
    [*ConstraintLayout*], [Layout gốc cho phép định vị linh hoạt các view con với constraint relationships],
    [*PreviewView*], [Thành phần CameraX Jetpack hiển thị luồng camera trực tiếp, tối ưu cho xử lý real-time],
    [*Button (Capture)*], [Nút chụp ảnh (`image_capture_button`) với elevation và margin tùy chỉnh],
    [*Button (Video)*], [Nút quay video (`video_capture_button`) được canh đều với nút chụp ảnh],
    [*Guideline*], [Đường hướng dẫn trung tâm (50%) để chia UI và canh chỉnh các nút]
  ),
  caption: "Các thành phần trong activity_main.xml"
)


=== Ngôn ngữ lập trình: Kotlin

Kotlin là ngôn ngữ lập trình hiện đại, tĩnh (statically typed), đa nền tảng được JetBrains phát triển và Google công nhận là ngôn ngữ ưu tiên cho phát triển Android từ năm 2019.


== Kết luận chương
Chương này đã trình bày nền tảng kỹ thuật và công nghệ sử dụng trong việc phát triển hệ thống điều khiển camera từ xa trên thiết bị di động. Việc lựa chọn Android CameraX API, cấu hình SDK phù hợp, cùng với việc sử dụng Kotlin và các thư viện hiện đại đã tạo nên một nền tảng vững chắc cho ứng dụng. Trong các chương tiếp theo, chúng ta sẽ đi sâu vào thiết kế mô hình và kiến trúc hệ thống để triển khai các chức năng cụ thể của ứng dụng.