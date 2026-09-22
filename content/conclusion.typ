= KẾT LUẬN

== Tổng kết nghiên cứu

Đồ án đã thực hiện nghiên cứu và triển khai mô hình để giải quyết bài toán định danh tự động giọng hát ca sĩ Việt Nam đương đại, bao gồm toàn bộ quy trình từ thu thập dữ liệu, tiền xử lý, tăng cường dữ liệu đến huấn luyện và đánh giá mô hình. Hai kiến trúc mạng nơ-ron hồi quy Gated Recurrent Unit (GRU) và Long Short-Term Memory (LSTM) đã được triển khai và so sánh trên tập dữ liệu gồm 11730 mẫu huấn luyện của 10 ca sĩ, sử dụng đặc trưng phổ Mel spectrogram làm đầu vào.

== Mức độ hoàn thành mục tiêu

=== Phạm vi nghiên cứu đã thực hiện

Nghiên cứu đã tập trung vào các khía cạnh sau:

- Nghiên cứu và lựa chọn công nghệ phù hợp cho bài toán định danh tự động giọng hát ca sĩ, bao gồm thư viện PyTorch và các kỹ thuật trích xuất đặc trưng âm thanh Mel spectrogram.
- Thu thập dữ liệu từ nền tảng âm nhạc số, tiền xử lý và tăng cường dữ liệu để mở rộng tập huấn luyện từ dữ liệu gốc lên 11730 mẫu.
- Triển khai hai mô hình học sâu GRU và LSTM với cấu hình hai chiều (Bidirectional), hai lớp chồng, kích thước hidden state 356 và cơ chế Mean Pooling.
- Tiến hành đánh giá thực nghiệm toàn diện thông qua ba phương pháp: độ chính xác trên tập kiểm tra, F1-score theo từng lớp và ma trận nhầm lẫn.

=== Kết quả chính đạt được

Từ kết quả thực nghiệm, mô hình GRU thể hiện ưu thế vượt trội so với LSTM trên cả ba tiêu chí đánh giá:

- *Độ chính xác trên tập kiểm tra:* GRU đạt trung bình 79,13%, trong khi LSTM đạt trung bình 76,48%.
- *F1-score:* GRU đạt Macro Avg F1 là 80,0% so với 72,0% của LSTM, chênh lệch 8 điểm phần trăm. GRU vượt trội ở 8 trên 10 lớp ca sĩ, với dải F1 dao động hẹp (71,0%–90,0%, biên độ 19 điểm) so với LSTM (39,0%–95,0%, biên độ 56 điểm).
- *Ma trận nhầm lẫn:* GRU phân tán lỗi nhầm lẫn đều giữa các lớp, không xuất hiện hiện tượng "điểm hút". Trong khi đó, LSTM bộc lộ hiện tượng "điểm hút" nghiêm trọng ở lớp Vũ Cát Tường, nơi hấp thụ lượng lớn mẫu sai từ nhiều lớp khác (37,7% từ Hà Anh Tuấn, 66,7% từ Trần My Anh, 18,8% từ Tóc Tiên, 27,3% từ Vũ Thanh Vân).

Kết quả cho thấy với kiến trúc đơn giản hơn và ít tham số hơn, GRU tránh được hiện tượng quá khớp và duy trì sự cân bằng Precision-Recall trên đa số các lớp, phù hợp hơn cho bài toán nhận dạng giọng hát ca sĩ trên quy mô tập dữ liệu hiện tại. Ngoài ra, việc tăng cường dữ liệu cũng chứng minh được hiệu quả trong việc làm giàu tập huấn luyện mà vẫn giữ được chất lượng phân loại tương đương với tập dữ liệu gốc.

=== Hạn chế

Hiện tượng quá khớp (overfitting) nghiêm trọng xảy ra ở cả hai mô hình: độ chính xác trên tập huấn luyện đạt xấp xỉ 100% trong khi tập kiểm tra chỉ đạt khoảng 79% (GRU) và 76% (LSTM), khoảng cách chênh lệch khoảng 20% vẫn chưa được xử lý mặc dù L2 Regularization và Dropout đã được áp dụng.

Một số cặp ca sĩ có đặc trưng giọng hát tương đồng (Tóc Tiên–Trần My Anh, Bùi Trường Linh–Đỗ Quốc Thịnh) gây ra nhầm lẫn mang tính hệ thống mà cả hai mô hình đều chưa giải quyết được. Ngoài ra, ca sĩ có phong cách trình diễn đa dạng như Hà Anh Tuấn khiến đặc trưng phổ Mel biến thiên mạnh, dẫn đến Recall thấp ở cả hai mô hình (GRU: 55,0%, LSTM: 45,0%).

Mô hình LSTM với nhiều tham số hơn lại cho hiệu năng thấp hơn, cho thấy kiến trúc phức tạp hơn không phải lúc nào cũng mang lại kết quả tốt hơn khi quy mô dữ liệu còn hạn chế.

== Hướng phát triển

Trong tương lai, mô hình GRU vẫn là một lựa chọn tốt để áp dụng cho các bài toán xử lý tín hiệu âm thanh do hiệu quả thực tế của mô hình được chứng minh qua thực nghiệm. Tuy nhiên, vẫn còn những hạn chế xảy ra nên mô hình vẫn cần phải được tinh chỉnh hay kết hợp với nhiều cơ chế mới để hạn chế các hiện tượng như quá khớp. Hơn nữa, cần cải thiện việc xử lý dữ liệu trong bối cảnh thực tế các bài hát trước khi được phát hành trên các nền tảng số, chúng đã qua quá trình hoà âm và phối khí nên có thể bao gồm các đoạn adlib gây ảnh hưởng đến giọng hát. Việc tách âm nhạc nền ra khỏi dữ liệu cũng là vấn đề khó khăn nên được cải thiện bằng cách tận dụng các công cụ tách sạch hơn. Việc cân bằng lượng mẫu cũng là công việc cần thiết khi độ lệch giữa các mẫu cũng khiến cho kết quả không được tốt như kỳ vọng. Việc thử nghiệm trên các mô hình khác cũng là một hướng để giải quyết triệt để bài toán khi mà các mô hình mới sẽ giải quyết được nhiều hạn chế của mô hình được đề xuất. Có thể kết hợp nhiều loại đặc trưng âm thanh bổ sung như MFCC, Chroma, Spectral Contrast bên cạnh Mel spectrogram để tăng khả năng phân biệt giữa các giọng ca tương đồng. Với mục tiêu của bài toán là định danh âm nhạc trên nền tảng số, việc tăng số lượng nhãn hay số lượng ca sĩ là điều hoàn toàn cần thiết để cải thiện và phát triển đề tài.

