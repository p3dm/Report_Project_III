#let mel = "Mel"

= NỀN TẢNG LÝ THUYẾT VÀ CÔNG NGHỆ

== Bài toán phát hiện đặc trưng giọng hát

=== Khái niệm phổ âm thanh

Phổ âm thanh (spectrogram) là biểu diễn hai chiều của tín hiệu âm thanh trong miền thời gian–tần số, trong đó trục hoành biểu diễn thời gian, trục tung biểu diễn tần số, còn mỗi điểm ảnh thể hiện cường độ, phản ánh mức năng lượng của thành phần tần số tương ứng tại một thời điểm cụ thể. Về bản chất, spectrogram được tạo thành bằng cách chồng các vector phổ thu được từ những khung tín hiệu ngắn liên tiếp, nhờ đó cho phép quan sát sự biến thiên của cấu trúc phổ theo thời gian @4.

Do tín hiệu âm thanh là tín hiệu không dừng trên toàn cục nhưng có thể được xem là gần dừng trong những khoảng thời gian ngắn, quá trình phân tích thường bắt đầu bằng việc chia tín hiệu thành các frame ngắn, áp dụng hàm cửa sổ Hamming và thực hiện biến đổi Fourier thời gian ngắn (STFT). Kết quả của phép biến đổi này là một ma trận phổ, trong đó độ phân giải theo tần số phụ thuộc vào kích thước cửa sổ phân tích, còn độ phân giải theo thời gian phụ thuộc vào bước trượt giữa hai khung liên tiếp @14.

Trong các bài toán phân tích tiếng nói và giọng hát, spectrogram tuyến tính thường tiếp tục được biến đổi sang #mel spectrogram để phù hợp hơn với cơ chế cảm nhận của hệ thính giác con người. Ý tưởng cốt lõi của phép biến đổi này là ánh xạ trục tần số từ đơn vị Hertz sang thang Mel, một thang đo phi tuyến cho phép biểu diễn chi tiết hơn ở vùng tần số thấp và nén mạnh hơn ở vùng tần số cao @4.

Phép ánh xạ từ tần số tuyến tính $f$ sang tần số Mel $f_"mel"$ thường được mô tả bởi công thức:
$
  f_"mel" = 2595 * log_10(1 + f / 700)
$

Từ phổ công suất thu được sau STFT, một tập các bộ lọc tam giác được bố trí đều trên thang Mel sẽ được sử dụng để cộng gộp năng lượng của các dải tần lân cận. Kết quả của bước này là ma trận #mel spectrogram, trong đó mỗi hàng không còn biểu diễn một tần số tuyến tính riêng lẻ mà biểu diễn năng lượng của một dải Mel tại từng thời điểm @4.

So với phổ tuyến tính thông thường, #mel spectrogram có ưu điểm là làm nổi bật tốt hơn các đặc trưng quan trọng đối với tiếng nói và giọng hát, đặc biệt ở vùng tần số thấp và trung bình, nơi tập trung nhiều thông tin về cao độ, cộng hưởng và cấu trúc âm sắc. Vì vậy, đây là một trong những biểu diễn đầu vào được sử dụng rộng rãi trong các hệ thống nhận dạng tiếng nói, nhận dạng người nói, nhận diện cảm xúc và phân tích âm thanh bằng học sâu @4.

Bên cạnh trục tần số, trục thời gian của #mel spectrogram cũng mang ý nghĩa quan trọng vì nó phản ánh diễn biến động của tín hiệu âm thanh. Mỗi cột của ma trận tương ứng với một frame phân tích, còn toàn bộ chuỗi các cột liên tiếp tạo thành một chuỗi quan sát theo thời gian, cho phép mô hình học được không chỉ đặc trưng phổ cục bộ mà còn cả sự chuyển tiếp giữa các trạng thái âm học liên tiếp.

=== Khái niệm chuỗi thời gian

Chuỗi thời gian (time series) được định nghĩa là một dãy các quan sát được sắp xếp theo thứ tự thời gian, trong đó mỗi quan sát phản ánh trạng thái của hệ thống tại một thời điểm hoặc một khoảng thời gian xác định. Trong bài toán xử lý âm thanh, chuỗi thời gian không chỉ xuất hiện ở tín hiệu sóng ban đầu mà còn xuất hiện ở các đặc trưng sau biến đổi, trong đó #mel spectrogram có thể được xem là một chuỗi các vector đặc trưng Mel liên tiếp theo thời gian @14.

Dưới góc nhìn toán học, dữ liệu đặc trưng có thể được biểu diễn dưới dạng:
$
  X = {x_1, x_2, dots, x_T}, quad x_t in RR^d
$

Trong đó, $T$ là số lượng frame theo thời gian và $d$ là số chiều đặc trưng của mỗi frame. Với #mel spectrogram, mỗi $x_t$ là một vector gồm $d$ hệ số năng lượng Mel, còn toàn bộ dãy ${x_1, x_2, ..., x_T}$ mô tả sự thay đổi của nội dung phổ theo thời gian.

Cách biểu diễn này đặc biệt phù hợp với các mô hình học sâu có khả năng khai thác quan hệ phụ thuộc theo thời gian như RNN, LSTM hoặc GRU. Thay vì chỉ xem mỗi frame là một ảnh chụp độc lập của phổ tại một thời điểm, các mô hình này có thể học được quy luật biến thiên giữa các frame liên tiếp, từ đó nắm bắt tốt hơn đặc trưng động của giọng hát như nhịp điệu, ngữ điệu, chuyển động cao độ và cấu trúc âm sắc theo thời gian.

=== Bài toán phát hiện giọng hát

Từ các đặc trưng đã được xử lý và biểu diễn dưới dạng chuỗi thời gian, bài toán phát hiện giọng hát có thể được xem là việc xác định các đặc trưng âm học đặc thù của giọng hát trong chuỗi tín hiệu âm thanh. Mục tiêu là phân biệt được giọng hát của các ca sĩ khác nhau dựa trên các đặc trưng tần số.

Bài toán được tiếp cận theo phương pháp Học giám sát từ một tập dữ liệu đã được gán nhãn, trong đó mỗi mẫu âm thanh đi kèm với thông tin về ca sĩ hoặc đặc trưng giọng hát. Mô hình học sâu sẽ học cách ánh xạ từ chuỗi đặc trưng Mel sang nhãn tương ứng, từ đó có thể dự đoán giọng hát của các mẫu âm thanh mới. Trên thực tế, dữ liệu âm nhạc thô thường chứa nhiều thành phần phức tạp như nhạc cụ nền, tạp âm môi trường và các đoạn nhạc không lời (intro, outro), gây ra hiện tượng che lấp làm mờ đi các đặc trưng âm sắc cốt lõi của ca sĩ. Bên cạnh đó, việc thu thập và gán nhãn các tập dữ liệu âm thanh lớn thường tốn rất nhiều thời gian và chi phí, dẫn đến tình trạng thiếu hụt dữ liệu, điều này làm tăng độ khó của bài toán và đòi hỏi mô hình phải có khả năng tổng quát hóa tốt để nhận diện chính xác giọng hát trong các điều kiện khác nhau.

=== Học có giám sát cho bài toán phát hiện giọng hát

Học có giám sát (supervised learning) là một phương pháp học máy trong đó mô hình được huấn luyện trên một tập dữ liệu đã được gán nhãn, với mục tiêu học cách ánh xạ từ đầu vào (input) sang đầu ra (output) dựa trên các ví dụ đã biết. Trong bối cảnh bài toán phát hiện giọng hát, đầu vào là các đặc trưng âm thanh như #mel spectrogram, còn đầu ra là nhãn tương ứng với ca sĩ hoặc đặc trưng giọng hát.

Tập dữ liệu sẽ được chia ra thành ba phần chính: tập huấn luyện, tập kiểm tra và tập đánh giá. Tập huấn luyện được sử dụng để cập nhật các tham số của mô hình thông qua quá trình tối ưu hóa, trong khi tập kiểm tra giúp theo dõi hiệu suất của mô hình trong quá trình huấn luyện và điều chỉnh các siêu tham số. Cuối cùng, tập đánh giá được sử dụng để đánh giá khả năng tổng quát hóa của mô hình trên dữ liệu chưa từng thấy.

Đối với phương pháp trên, có thể dựa vào các mô hình trong học sâu được thiết kế để xử lý tuần tự theo chuỗi thời gian, như mạng bộ nhớ ngắn hạn dài (Long Short-Term Memory - LSTM), mạng nơ-ron hồi quy (Recurrent Neural Network - RNN) hoặc nâng cấp hiệu suất cao hơn với mạng nơ-ron hồi quy có cổng (Gated Recurrent Unit - GRU). Những mô hình này có khả năng học được các mối quan hệ phụ thuộc theo thời gian trong dữ liệu, từ đó nắm bắt được các đặc trưng động của giọng hát.

