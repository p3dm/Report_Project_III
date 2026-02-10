= KẾT LUẬN

== Tổng kết nghiên cứu

Đồ án đã thực hiện nghiên cứu và triển khai một hệ thống điều khiển camera từ xa trên thiết bị di động sử dụng ngôn ngữ Kotlin và Android CameraX API. Hệ thống cho phép người dùng kết nối từ xa đến thiết bị camera để chụp ảnh và quay video thông qua giao thức TCP socket.

== Mức độ hoàn thành mục tiêu

=== Phạm vi nghiên cứu đã thực hiện

Nghiên cứu đã tập trung vào các khía cạnh sau:

  - Nghiên cứu và lựa chọn công nghệ phù hợp cho việc phát triển ứng dụng di động trên nền tảng Android.
  - Triển khai các chức năng chụp ảnh, quay video, thay đổi chế độ chụp trên thiết bị camera từ Android CameraX API.
  - Thiết kế kiến trúc Client-Server sử dụng TCP socket để giao tiếp giữa thiết bị điều khiển và thiết bị camera.
  - Xây dựng giao diện người dùng thân thiện cho cả thiết bị camera và thiết bị điều khiển.
  - Đảm bảo tính ổn định và hiệu suất của hệ thống trong quá trình hoạt động.

== Kết quả chính đạt được

  - Hệ thống điều khiển camera từ xa hoạt động ổn định, cho phép người dùng chụp ảnh và quay video từ xa thông qua giao diện điều khiển.
  - Giao diện người dùng được thiết kế trực quan, dễ sử dụng, phù hợp với người dùng phổ thông.
  - Kiến trúc Client-Server được triển khai hiệu quả, đảm bảo truyền tải lệnh và dữ liệu nhanh chóng giữa các thiết bị.
  - Ứng dụng tận dụng tốt các tính năng của Android CameraX API để cung cấp trải nghiệm chụp ảnh và quay video chất lượng cao.

== Hạn chế

=== Nguyên nhân chưa đạt yêu cầu hiệu suất

1. Giới hạn về tài nguyên phần cứng của thiết bị di động, ảnh hưởng đến hiệu suất xử lý hình ảnh và video.
2. Độ trễ trong kết nối mạng TCP socket, đặc biệt khó có thể kết nối ngoại mạng LAN do các yếu tố tường lửa, NAT.
3. Thiếu các tính năng nâng cao như điều chỉnh thông số camera từ xa (ISO
, khẩu độ, v.v.) do giới hạn của Android CameraX API.
4. Thiếu truyền tải dữ liệu hình ảnh/video trực tiếp qua socket, chỉ hỗ trợ gửi lệnh điều khiển.

== Hướng phát triển

1. Cải thiện về hiệu suất xử lý hình ảnh và video bằng cách tối ưu hóa mã nguồn và sử dụng các kỹ thuật nén dữ liệu.
2. Nâng cao khả năng kết nối mạng, hỗ trợ các giao thức khác nhau để giảm độ trễ và tăng tính ổn định, mở rộng cho kết nối ngoại mạng LAN như wifi direct, hotspot.
3. Mở rộng các tính năng điều khiển camera từ xa, bao gồm điều chỉnh thông số camera và hỗ trợ các chế độ chụp nâng cao.
4. Triển khai chức năng truyền tải dữ liệu hình ảnh/video trực tiếp qua socket để người dùng có thể xem trước nội dung ngay trên thiết bị điều khiển.