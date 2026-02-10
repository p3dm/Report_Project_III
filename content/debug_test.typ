= Kiểm thử và Gỡ lỗi

== Mục đích kiểm thử
Mục đích của việc kiểm thử và gỡ lỗi là để đảm bảo rằng hệ thống điều khiển camera từ xa hoạt động đúng như mong đợi, không có lỗi và đáp ứng các yêu cầu đã đề ra. Quá trình này giúp phát hiện và sửa chữa các lỗi tiềm ẩn, cải thiện hiệu suất và độ ổn định của hệ thống.

== Phương pháp kiểm thử
=== Kiểm thử chức năng (Functional Testing)
- Kiểm thử từng chức năng của hệ thống như chụp ảnh, quay video, thay đổi chế độ chụp, kết nối và giao tiếp giữa client và server.
- Sử dụng các kịch bản kiểm thử để mô phỏng các tình huống sử dụng thực tế.

*Tên Ca 1:* Kiểm thử chức năng điều khiển chụp ảnh, quay video và khởi tạo TCP Socket server
*Mục đích:* Xác minh rằng ứng dụng có thể chụp ảnh và lưu vào MediaStore
*Điều kiện tiên quyết:* 
- Ứng dụng đã cấp quyền CAMERA và WRITE_EXTERNAL_STORAGE
- Thiết bị có camera hoạt động

 *Các bước kiểm thử*
  #figure(
    table(
      columns: (10%, 65%, 25%),
      align: (center, left, left),
      table.header(
        [*Bước*], [*Hành động*], [*Kết quả mong đợi*]
      ),
      [1], [Mở ứng dụng CameraXApp trên thiết bị Android.], [Ứng dụng khởi động thành công và hiển thị giao diện chính với nút chụp ảnh.],
      [2], [Đảm bảo rằng ứng dụng đã được cấp quyền CAMERA và WRITE_EXTERNAL_STORAGE. Nếu chưa, cấp quyền khi được yêu cầu.], [Ứng dụng có quyền truy cập camera và lưu trữ.],
      [3], [Nhấn vào nút chụp ảnh (capture button) trên giao diện chính.], [Camera chụp ảnh và lưu hình ảnh vào MediaStore.],
      [4], [Nhấn nút quay video để bắt đầu quay. Sau đó nhấn lại để dừng quay.], [Video được quay và lưu vào MediaStore.],
      [5], [Kiểm tra thư viện ảnh trên thiết bị để xác nhận rằng ảnh và video đã được lưu thành công.], [Ảnh chụp xuất hiện trong thư viện ảnh với chất lượng tốt và đúng định dạng.],
      [6],[Khởi tạo server], [Server khởi động và lắng nghe kết nối từ client đồng thời hiện lên thông tin kết nối bao gồm địa chỉ IP.],
    ),
    caption: "Kịch bản kiểm thử chức khởi tạo server"
  )
 *Log kiểm thử bằng Logcat*

Khi thực hiện chụp ảnh thành công, các log sau sẽ xuất hiện:

*Khởi tạo camera:*

Tiến hình câp quyền và khởi tạo camera:
#figure(
  image(
    "../figures/permission.png",
    width: 50%
  ), caption :"Cấp quyền truy cập camera và lưu trữ"
)
```Logcat
2026-01-18 20:10:55.147   605-701   Attributio...ssionUtils cameraserver                         I  checkPermission (forDataDelivery 0 startDataDelivery 0): Permission hard denied for client attribution [uid 10147, pid 6707, packageName "<unknown>"]

2026-01-18 20:10:55.176   605-701   Attributio...ssionUtils cameraserver                         I  checkPermission (forDataDelivery 0 startDataDelivery 0): Permission hard denied for client attribution [uid 10147, pid 6707, packageName "<unknown>"]

CameraController com.example.camerax   D Camera started with site: BACK

CameraController com.example.camerax  D Photo capture succeeded: content://media/external/images/media/40

CameraController com.example.camerax D Video capture succeeded: content://media/external/video/media/42
```
\
Mở thư viện ảnh để kiểm tra ảnh vừa chụp:
#figure(
image(
    "../figures/test_1.png",
    width: 50%
  ),
  caption: "Thư viện ảnh"
)

*Khởi tạo server TCP Socket:*
```Logcat

CameraSocketServer   com.example.camerax   D  Server started on port 2000
```
#figure(
image(
    "../figures/test_2.png",
    width: 50%
  ), caption:"Thông tin kết nối server TCP Socket"
)

\

*Tên Ca 2:* Kiểm thử người dùng kết nối từ xa và điều khiển chụp ảnh, quay video
*Mục đích:* Xác minh rằng ứng dụng có thể kết nối từ xa và điều khiển chụp ảnh, quay video
*Điều kiện tiên quyết:* 
- Ứng dụng đã cấp quyền CAMERA và WRITE_EXTERNAL_STORAGE
- Thiết bị có camera hoạt động
- Có server lắng nghe
- Biết địa chỉ IP của server

 *Các bước kiểm thử*
  #figure(
    table(
      columns: (10%, 65%, 36%),
      align: (center, left, left),
      table.header(
        [*Bước*], [*Hành động*], [*Kết quả mong đợi*]
      ),
      [1], [Mở ứng dụng CameraXApp trên thiết bị Android và chuyển sang chế độ Client (Remote Control).], [Ứng dụng khởi động thành công và hiển thị giao diện điều khiển từ xa với hộp nhập địa chỉ IP và nút kết nối.],
      [2], [Nhập địa chỉ IP của server vào hộp nhập và nhấn nút kết nối.], [Ứng dụng kết nối thành công đến server và hiển thị trạng thái kết nối.],
      [3], [Nhấn vào nút chụp ảnh trên giao diện điều khiển từ xa.], [Server nhận lệnh chụp ảnh và lưu hình ảnh vào MediaStore.],
      [4], [Nhấn nút quay video để bắt đầu quay. Sau đó nhấn lại để dừng quay.], [Server nhận lệnh quay video và lưu video vào MediaStore.],
      [5], [Kiểm tra thư viện ảnh trên thiết bị server để xác nhận rằng ảnh và video đã được lưu thành công.], [Ảnh chụp và video xuất hiện trong thư viện ảnh với chất lượng tốt và đúng định dạng.],
    ),
    caption: "Kịch bản kiểm thử chức năng điều khiển từ xa"
  )
 *Log kiểm thử bằng Logcat*

Phía client:
 ```Logcat
2026-01-18 22:33:45.223  5896-8604  CameraSocketClient      com.example.camerax                  D  Command sent: CLIENT_CONNECTED
2026-01-18 22:33:45.308  5896-8605  CameraSocketClient      com.example.camerax                  D  Message received: CONNECTED_TO_SERVER


2026-01-18 22:33:45.310  5896-8605  CameraSocketClient      com.example.camerax                  D  Message received: COMMAND_RECEIVED: CLIENT_CONNECTED
```
#figure(
image(
    "../figures/test_3.png",
    width: 50%
  ),
  caption: "Giao diện điều khiển từ xa"
)

*Tiếp tục gửi tín hiệu quay video:*

```Logcat
2026-01-18 22:36:12.349  5896-8604  CameraSocketClient      com.example.camerax                  D  Command sent: RECORD
2026-01-18 22:36:12.379  5896-8605  CameraSocketClient      com.example.camerax                  D  Message received: COMMAND_RECEIVED: RECORD
2026-01-18 22:36:18.437  5896-8602  CameraSocketClient      com.example.camerax                  D  Command sent: RECORD
2026-01-18 22:36:18.463  5896-8605  CameraSocketClient      com.example.camerax                  D  Message received: COMMAND_RECEIVED: RECORD
```
#figure(
image(
    "../figures/test_4.png",
    width: 50%
  ),
  caption: "Phản hồi từ server sau khi quay video"
)
\
*Tiếp tục gửi tín hiệu chụp ảnh:*
```Logcat
2026-01-18 22:36:07.459  5896-8602  CameraSocketClient      com.example.camerax                  D  Command sent: TAKE_PHOTO
2026-01-18 22:36:07.482  5896-8605  CameraSocketClient      com.example.camerax                  D  Message received: COMMAND_RECEIVED: TAKE_PHOTO
```
\
#figure( 
image(
    "../figures/test_5.png",
    width: 50%
  ),
  caption: "Phản hồi từ server sau khi chụp ảnh"
)
\

*Thư viện sau khi chụp ảnh và quay video từ xa:*
#figure(
image(
    "../figures/test_6.png",
    width: 50%
  ),
  caption: "Thư viện ảnh trên server sau khi chụp ảnh và quay video từ xa"
)