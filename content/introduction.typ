#import "/utils/todo.typ": TODO

= TỔNG QUAN ĐỀ TÀI

== Giới thiệu bài toán
Trong kỷ nguyên số hóa, sự bùng nổ của các nền tảng phát trực tuyến và các thiết bị lưu trữ đã khiến kho dữ liệu âm nhạc khổng lồ trên toàn cầu tăng lên từng ngày. Khi phải đối mặt với hàng triệu bản nhạc, việc con người phân loại, dán nhãn và sắp xếp thủ công đã trở nên khó khăn hơn bao giờ hết. Điều này đặt ra nền tảng thiết yếu cho sự phát triển của lĩnh vực "Truy xuất Thông tin Âm nhạc", trong đó bài toán cốt lõi và đầy thách thức là nhận dạng giọng hát ca sĩ. Nhiều nghiên cứu đã chỉ ra rằng việc nhận dạng giọng ca sĩ từ các đoạn âm thanh ngắn là một bài toán khó bởi vì các đặc trưng của giọng hát có thể thay đổi do các yếu tố như: âm sắc, kỹ thuật thanh nhạc, cách phát âm, cảm xúc và phong cách trình diễn của từng ca sĩ. Thêm vào đó, sự đa dạng về mặt kỹ thuật trong xử lý tín hiệu âm thanh cũng gây ra sự khó dễ trong việc nghiên cứu nhận diện giọng hát ca sĩ.

Trong bối cảnh này, đề tài cung cấp giải pháp để máy tính tự động nhận dạng giọng hát ca sĩ thông qua việc phân loại và nhận dạng giọng ca sĩ của một số ca sĩ đương đại Việt Nam. Qua đó tạo điều kiện cho việc xây dựng các sản phẩm liên quan nhằm hỗ trợ người dùng tìm kiếm bài hát, hoặc tự động phân loại âm nhạc, ca sĩ.

== Mục tiêu của đề tài
Mục tiêu quan trọng nhất là dự đoán và nhận dạng chính xác tên của ca sĩ biểu diễn hoặc thể loại của bài hát chỉ từ các đoạn cắt âm thanh rất ngắn. Thay vì sử dụng các thuật toán học máy truyền thống với các đặc trưng do con người tự thiết kế, đề tài hướng tới việc thiết kế các cấu trúc mạng nơ-ron học sâu tiên tiến (như GRU, LSTM, CNN) để hệ thống có thể tự động trích xuất và học các biểu diễn phức tạp từ ảnh phổ Mel @1.

Nhận thấy sự khan hiếm của các bộ dữ liệu âm nhạc được gán nhãn, một mục tiêu nghiên cứu lớn là đề xuất và kiểm nghiệm các phương pháp tăng cường dữ liệu mới nhằm cải thiện độ chính xác và tính bền bỉ của mô hình mà không cần phải thu thập thêm dữ liệu thực tế @1 @7. Phần lớn các nghiên cứu về truy xuất thông tin âm nhạc hiện nay tập trung vào âm nhạc phương Tây. Do đó, đề tài đặt mục tiêu thu thập, tiền xử lý và xây dựng một bộ dữ liệu chất lượng cao chuyên biệt về các bài hát và giọng ca sĩ phổ biến tại Việt Nam.

Những kết quả nhận dạng từ mô hình sẽ làm nền tảng để xây dựng các hệ thống gợi ý âm nhạc dựa trên nội dung. Điều này giúp các nền tảng phát trực tuyến tạo ra các danh sách phát cá nhân hóa chính xác hơn dựa trên đặc trưng chất giọng của ca sĩ hoặc thể loại nhạc mà người dùng yêu thích @2.

== Phạm vi nghiên cứu của đề tài

Nghiên cứu chủ yếu giải quyết bài toán phân loại, nhận dạng giọng ca sĩ và nhận diện các loại nhạc cụ trong những bản nhạc đa âm. Một phần lớn phạm vi nghiên cứu được dành riêng để phân tích đặc trưng của các nền âm nhạc bản địa, cụ thể là tập dữ liệu các bài hát của các ca sĩ Việt Nam.

Phạm vi nghiên cứu không đi sâu vào việc xây dựng hệ thống thu âm chuẩn mà tập trung tối ưu hóa các quy trình tiền xử lý kỹ thuật số. Cụ thể, đề tài ứng dụng các thuật toán để phân đoạn và tự động phân tách giọng hát ra khỏi nhạc nền đa âm. Đặc biệt, do sự thiếu hụt của các bộ dữ liệu có nhãn, nghiên cứu đi sâu vào việc thiết kế và áp dụng các kỹ thuật tăng cường dữ liệu nhằm nhân bản quy mô tập dữ liệu huấn luyện.

Nhận thức rõ những ràng buộc khắt khe về luật sở hữu trí tuệ trong lĩnh vực âm nhạc, bộ dữ liệu của đề tài được thu thập thủ công từ các bài hát lưu hành trên nền tảng YouTube và các kho nhạc số Việt Nam. Để tuân thủ nghiêm ngặt các nguyên tắc về bản quyền, toàn bộ các mẫu âm thanh và bộ dữ liệu này được giới hạn phạm vi sử dụng, chỉ được phép xuất bản và chia sẻ công khai nhằm phục vụ cho các mục đích nghiên cứu khoa học, học thuật và các ứng dụng hoàn toàn phi thương mại.

Cuối cùng, nhằm kiểm chứng tính khả thi và hiệu quả của phương pháp đề xuất, đề tài tiến hành thực nghiệm một cách hệ thống trên các bộ dữ liệu thực tế. Mô hình được đánh giá thông qua các chỉ số đo lường độ chính xác, tiêu biểu như ma trận nhầm lẫn, F1-score trong bối cảnh dữ liệu mất cân bằng.

== Đóng góp của đề tài

Các đóng góp chính của đề tài bao gồm:
- xây dựng bộ dữ liệu âm thanh của các ca sĩ Việt Nam, bao gồm các bài hát phổ biến và được gán nhãn chính xác, ngoài ra việc tăng cường còn làm đa dạng thêm các đặc trưng âm thanh, giúp mô hình học sâu có thể học được nhiều đặc trưng hơn từ dữ liệu.

- Đề xuất các kiến trúc mô hình học sâu và trực tiếp đánh giá qua thực nghiệm, từ đó rút ra những kết luận về hiệu năng của các mô hình mạng hồi quy có cổng - Gated Recurrent Units (GRU) và bộ nhớ dài ngắn hạn - Long Short-Term Memory (LSTM) trong việc nhận dạng giọng hát ca sĩ.

== Cấu trúc khoá luận

Nội dung của khoá luận được tổ chức thành các chương như sau:

- *Chương 1: Tổng quan đề tài.* Trình bày bối cảnh, lý do chọn đề tài, mục tiêu và phạm vi nghiên cứu của bài toán.
- *Chương 2: Nền tảng kỹ thuật và công nghệ.* Tổng quan về các kỹ thuật xử lý tín hiệu âm thanh, kiến thức liên quan đến chuỗi thời gian, học có giám sát.
- *Chương 3: Tập dữ liệu và tiền xử lý dữ liệu.* Mô tả quá trình thu thập và xây dựng tập dữ liệu, các bước tiền xử lý trích xuất đặc trưng âm thanh, các kỹ thuật tăng cường dữ liệu.
- *Chương 4: Kiến trúc đề xuất.* Đi sâu vào cơ sở lý thuyết và cấu trúc chi tiết của các mạng học sâu được sử dụng, cách thức hoạt động chung và các cơ chế hỗ trợ chuẩn hóa mô hình.
- *Chương 5: Đánh giá thực nghiệm.* Mô tả phương pháp và quy trình đánh giá, cấu hình môi trường phần cứng cũng như siêu tham số, từ đó trình bày và so sánh kết quả độ chính xác của các mô hình.
- *Chương 6: Kết luận và hướng phát triển.* Tóm tắt kết quả đạt được, những hạn chế và hướng phát triển trong tương lai.
