= Kiến trúc phần mềm

== Tổng quan về kiến trúc

- Mô hình Client-Server sử dụng TCP socket để giao tiếp. Ứng dụng CameraX hoạt động với 2 vai trò:

	-- Server Mode: Thiết bị chụp ảnh/quay video, lắng nghe lệnh từ Client

	-- Client Mode: Điều khiển từ xa thiết bị Server
*Vòng đời của phần mềm (Lifecycle)*

#figure(
  image(
    "../figures/overall.png",
    width: 75%
  ),
  caption: "Sơ đồ vòng đời phần mềm"
)
\
*Mô tả các bước chính:*
1. *App Start* → MainActivity → Kiểm tra quyền → Khởi tạo camera
2. *Become Server* → Khởi tạo CameraSocketServer → Lắng nghe cổng 2000 → Hiển thị IP
3. *Client connects* → Server chấp nhận → Gửi "CONNECTED_TO_SERVER"
4. *Client sends command* → Server nhận → RemoteCommandHandler xử lý → Thực thi hành động camera
5. *Server stop* → Gửi "SERVER_SHUTDOWN" → Đóng các socket → Đặt lại trạng thái
6. *Remote Control* → Điều hướng đến RemoteControlActivity → Nhập IP → Kết nối
7. *Client connected* → Kích hoạt các nút điều khiển → Gửi lệnh qua TCP
8. *Client disconnect* → Đóng socket → Đặt lại giao diện → Sẵn sàng cho kết nối mới

=== Luồng xử lý khởi tạo camera.
\
- Triển khai ứng dụng chụp ảnh bằng CameraX gồm các luồng xử lý khởi tạo camera và các chức năng chụp ảnh, quay phim, truy cập thư viện, xoay camera. Đối với các chức năng này, Android Studio có cung cấp các API hỗ trợ trực tiếp cho việc triển khai CameraX như CameraProvider, ImageCapture, VideoCapture, Preview, v.v. Dưới đây là sơ đồ luồng xử lý cho các chức năng:

#figure(
	image(
		"../figures/startCameraFlow.png",
		width: 80%
	),
	caption: "Sơ đồ luồng xử lý khởi tạo CameraX"
)


=== Luồng xử lý chụp ảnh
	-- Chụp một ảnh tĩnh và lưu vào MediaStore để ảnh xuất hiện trong thư viện hệ thống. Hàm bắt đầu bằng việc kiểm tra imageCapture có sẵn hay không; nếu chưa có (null) thì kết thúc sớm nhằm tránh crash. Khi đã có use case, controller tạo tên file bằng timestamp để đảm bảo không trùng, sau đó tạo ContentValues mô tả metadata của ảnh (tên hiển thị, MIME type và đường dẫn). Dựa trên những metadata này, controller tạo OutputFileOptions và gọi hàm chụp ảnh. Khi ảnh được lưu thành công, cập nhật thumbnail của nút xem thư viện bằng đường dẫn đã lưu ở trên, giúp người dùng thấy ảnh mới nhất ngay trên UI.

#figure(
	image(
		"../figures/capture.png",
		width: 80%
	),
	caption: "Sơ đồ luồng xử lý chụp ảnh"
)
=== Luồng xử lý quay video
	-- Thiết kế một nút toggle: khi người dùng bấm lần đầu, nó bắt đầu quay; khi bấm lần nữa, nó dừng quay. Vì vậy, trạng thái recording là chìa khoá quyết định nhánh xử lý. Hàm cũng quản lý UI liên quan đến quay video, bao gồm vô hiệu hoá chuyển mode trong lúc quay, đổi icon của nút quay/dừng, hiển thị indicator và chạy RecordingTimer để cập nhật thời gian.

#figure(
	image(
		"../figures/record.png",
		width: 70%
	),
	caption: "Sơ đồ luồng xử lý quay video"
)


=== Luồng xử lý xoay camera
	-- Khi người dùng bấm nút xoay camera, hàm kiểm tra camera hiện tại là trước hay sau. Dựa trên đó, nó chuyển sang camera đối diện bằng cách cập nhật biến  để tái khởi tạo các use case với ống kính mới.

=== Luồng xử lý mở thư viện
 -- Khi người dùng bấm nút mở thư viện, mở ứng dụng xem ảnh của hệ thống bằng Intent để yêu cầu hệ thống tìm một activity có thể hiển thị ảnh. Android sẽ thực hiện intent resolution: nếu có app mặc định thì mở trực tiếp, nếu có nhiều app phù hợp thì hệ thống có thể hiển thị chooser (tuỳ cấu hình người dùng), và nếu không có app nào xử lý thì thao tác sẽ thất bại.

== Luồng xử lý kiến trúc Client-Server với TCP Socket

=== Khởi tạo server TCP Socket
-- Triển khai server TCP Socket với IPv4 để lắng nghe kết nối từ client. Khi server được khởi tạo, nó mở một ServerSocket trên cổng xác định (2000). Server sau đó chờ đợi các kết nối đến từ client. Sau đó hiển thị thông tin về IP của server. Khi một client kết nối, server chấp nhận kết nối và tạo một socket riêng để giao tiếp với client đó.

#figure(
	image(
		"../figures/startServer.png",
		width: 80%
	),
	caption: "Sơ đồ luồng xử lý khởi tạo server TCP Socket"
)

* Cách server xử lý với các yêu cầu từ client:*

-- Khi server nhận được kết nối từ client, nó tạo một luồng riêng để xử lý giao tiếp với client đó. Luồng này liên tục lắng nghe các thông điệp từ client. Khi nhận được một thông điệp, nó phân tích cú pháp và xác định loại lệnh. Dựa trên lệnh nhận được (chẳng hạn "TAKE_PHOTO", "START_RECORDING", "STOP_RECORDING"), server sẽ gọi các phương thức tương ứng trong RemoteCommandHandler để thực thi hành động camera. Sau khi thực hiện xong, server có thể gửi phản hồi trở lại client để thông báo kết quả của lệnh.

#figure(
	image(
		"../figures/handleClient.png",
		width: 80%
	),
	caption: "Sơ đồ luồng xử lý yêu cầu từ client"
)

=== Khởi tạo client TCP Socket
-- Triển khai client TCP Socket để kết nối và gửi lệnh đến server. Khi client được khởi tạo, nó tạo một socket và cố gắng kết nối đến địa chỉ IP và cổng của server. Nếu kết nối thành công, client sẽ bắt đầu lắng nghe các thông điệp từ server trong một luồng riêng biệt.
#figure(
	image(
		"../figures/client.png",
		width: 80%
	),
	caption: "Sơ đồ luồng xử lý khởi tạo client TCP Socket"
)
\
* Cách client gửi lệnh đến server:*

-- Người dùng sử dụng các nút trên giao diện điều khiển gửi lệnh đến server qua TCP socket bằng văn bản (VD: "TAKE_PHOTO", "START_RECORDING"). Khi người dùng bấm một nút, client sẽ gửi lệnh tương ứng qua socket đến server. Client cũng lắng nghe các phản hồi từ server để cập nhật giao diện người dùng dựa trên trạng thái hiện tại của camera trên server.


