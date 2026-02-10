= Thiết kế giao diện

== Tổng quan giao diện

Giao diện ứng dụng sẽ bao gồm các thành phần chính sau:
1. Màn hình hiển thị ứng dụng camera bình thường với các nút điều khiển chụp ảnh, quay video, chuyển đổi camera trước/sau, xem thư viện ảnh.
2. Menu để chuyển đổi giữa chế độ Server (máy chụp ảnh) và Client (máy điều khiển từ xa).
3. Giao diện điều khiển từ xa trên Client với các nút gửi lệnh chụp ảnh, quay video đến Server.

=== Màn hình Camera + Server
Tại màn hình chính camera sẽ được hiển thị với các nút điều khiển cơ bản, theo đó khi bắt đầu ứng dụng ở chế độ server, thiết bị sẽ khởi tạo server TCP socket để lắng nghe kết nối từ client, hiển thị địa chỉ IP để client kết nối, và giữ nguyên màn hình như bình thường để người dùng có thể chụp ảnh/quay video.

Về layout, màn hình này gồm 3 lớp chính:

*A) Toolbar trên cùng*

 setSupportActionBar(viewBinding.toolbar) trong MainActivity

 Toolbar dùng để hiển thị title (thường là `@string/app_name`) và menu.

 Menu được inflate bằng onCreateOptionsMenu() → R.menu.main_menu.

Trong menu có 2 items:

- Chuyển giữa giao diện chụp ảnh và giao diện điều khiển từ xa
  
- Khởi động/dừng server (chỉ hiển thị khi ở Server mode)
\
#figure(
  grid(
    columns: 2,
    gutter: 1em,
    image("../figures/tool_bar.png", width: 70%),
    image("../figures/tool_bar2.png", width: 70%)
  ),
  caption: [Menu tùy chọn ứng dụng CameraXApp]
)
\
\

*B) Overlay/Controls trên preview*  

Các phần điều khiển đặt “đè” trên preview (tuỳ XML của bạn đang set kiểu constraint/overlay):

modeSelectorGroup: radio group đổi mode PHOTO/VIDEO.

flipCameraButton: lật camera.

photoViewButton: mở thư viện/hiển thị thumbnail mới nhất.

Đối với các nút chụp ảnh/quay video, nút chuyển chế độ, nút lật camera, và nút mở thư viện ảnh sẽ được tạo bằng file layout XML với thuộc tính là `drawable` để hiển thị biểu tượng tương ứng.

*Các nút điều khiển*

#figure(
  table(
    columns: (1fr, 1fr, 1.5fr),
    align: (center, center, left),
    stroke: 0.75pt,
    
    [*Tên nút*], [*Icon*], [*Tên hàm*],
    
    [Nút chụp], 
    image("../figures/capture_button.png", width: 40pt),
    [`takePhoto()`],
    
    [Bộ chọn chế độ],
    image("../figures/mode_selector.png", width: 80pt),
    [`setModeListener()`],
    
    [Đổi camera],
    image("../figures/flip_camera.png", width: 40pt),
    [`flipCamera()`],

    [Quay video],
    image("../figures/start_capture.png", width: 40pt),
    [`captureVideo()`],
    
    [Dừng video],
    image("../figures/stop_capture.png", width: 40pt),
    [`stopVideoRecording()`],
   
    [Nút xem ảnh],
    image("../figures/view_photo.png", width: 40pt),
    [`onPhotoViewerClicked()`],

  ),
  caption: [Danh sách các nút điều khiển và thông tin liên quan]
)
\

*Chi tiết hoạt động nút Quay video và Dừng video*

Nút capture có tác dụng kép trong VIDEO mode: nhấn lần đầu để bắt đầu quay video, nhấn lần thứ hai để dừng. Khi bắt đầu quay, nút chuyển chế độ (modeSelectorGroup) sẽ bị vô hiệu hóa để tránh thay đổi chế độ trong quá trình ghi, indicator quay video sẽ hiển thị, timer khởi động, và nút quay/chụp chính đổi thành recording_button (đỏ). Khi dừng quay, nút quay/chụp chính trở lại video_button bình thường, nút chuyển chế độ được kích hoạt lại, và frame đầu tiên của video được trích xuất làm thumbnail. Thiết kế này đảm bảo tính ổn định khi ghi hình và cung cấp phản hồi UI trực quan cho người dùng.

*Tổng thể màn hình*

#figure(
  image(
    "../figures/main_ui.png",
    width: 50%
  ),
  caption: "Giao diện chính của ứng dụng CameraXApp"
)

=== Màn hình phía client (Remote Control)

Khi chuyển sang chế độ Client (Remote Control), giao diện sẽ thay đổi để hiển thị các nút điều khiển từ xa. Màn hình này sẽ bao gồm:

  - 1. Hộp nhập thông tin địa chỉ IP để kết nối 
  - 2. Nút kết nối đến server
  - 3. Vị trí nhận phản hồi từ server (nếu cần)
  - 4. Các nút điều khiển từ xa: Chụp ảnh, Bắt đầu quay video, Dừng quay video

  #figure(
    image(
      "../figures/clien_side.png",
      width: 60%
    ),
    caption: "Giao diện điều khiển từ xa trên Client"
  )