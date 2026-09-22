= TẬP DỮ LIỆU VÀ TIỀN XỬ LÝ DỮ LIỆU

== Xây dựng tập dữ liệu
=== Dữ liệu âm thanh và nhãn

Đối với bài toán phát hiện giọng hát, dữ liệu âm thanh sẽ được thu thập từ các bài hát của mười ca sĩ Việt Nam, bao gồm 5 ca sĩ nam và 5 ca sĩ nữ. Mỗi ca sĩ sẽ được đại diện bởi 10 bài hát cho tập dữ huấn luyện, tạo thành một tập dữ liệu phong phú và đa dạng. Các bài hát sẽ được thu thập từ nguồn trực tuyến là YouTube. Việc lựa chọn ca sĩ và bài hát sẽ được thực hiện ngẫu nhiên nhằm giúp mô hình học sâu có thể nắm bắt được những đặc điểm riêng biệt của từng ca sĩ. Sau đó mỗi ca sĩ sẽ được lấy thêm 1 bài hát mới hoàn toàn để làm tập dữ liệu kiểm tra, giúp đánh giá khả năng tổng quát hóa của mô hình trên các mẫu âm thanh chưa từng thấy.

=== Tiền xử lý dữ liệu

Trước khi đưa dữ liệu âm thanh vào mô hình học sâu, một bước tiền xử lý quan trọng là chuyển đổi tín hiệu âm thanh thô thành các đặc trưng có ý nghĩa hơn đối với việc nhận diện giọng hát. Một trong những biểu diễn phổ biến và hiệu quả nhất là Mel spectrogram.

Các bài hát của từng ca sĩ sẽ được xử lý qua công cụ Demucs — một mô hình tách nguồn dựa trên mạng nơ-ron sâu để tách tín hiệu âm thanh thành các thành phần âm thanh như vocals, bass, drums. Trong đồ án này, tận dụng thành phần vocals để tách lời ca sĩ, đồng thời loại bỏ phần nhạc nền và tạp âm môi trường. Sau khi tách lời, tiếp tục áp dụng tuyển chọn đoạn giọng hát bằng cách khai thác mức năng lượng và đặc trưng phổ, xác định những vùng có lời rõ ràng và giữ lại các khoảng thời gian chứa âm thanh giọng hát liên tục.

Các đoạn giọng hát được chuẩn hoá về độ dài cố định 5 giây bằng cách cắt và chia nhỏ. Nếu một đoạn có khoảng lặng dài như phần intro, outro, hoặc phần nghỉ giữa câu, các khoảng không có âm thanh hoặc âm thanh rất nhỏ sẽ được loại bỏ, chỉ giữ lại những khung chứa giọng hát rõ ràng hoặc những khoảng nghỉ ngắn gần như bằng 0. Đối với các đoạn quá ngắn sau khi loại bỏ, hệ thống sẽ tiến hành Zero-Padding hoặc bỏ mẫu để đảm bảo mỗi mẫu dữ liệu có độ dài đồng nhất và phù hợp với kiến trúc mạng nơ-ron.

#figure(
  image("../figures/song_am.png", width: 90%),
  caption: [Sóng âm cho đoạn 5 giây lời nhạc ],
)

Theo đặc tính tự nhiên của tiếng nói và âm nhạc, năng lượng của dải tần số cao thường thấp và suy giảm nhanh hơn so với dải tần số thấp nên đầu tiên cần phải áp dụng bộ lọc cân bằng phổ năng lượng tổng thể để giúp mô hình nắm bắt các đặc trưng quan trọng mà không bị bỏ sót. Tín hiệu được xử lý theo công thức với hệ số $alpha = 0.97$:

#text(size: 12pt)[
  $
    y[n]=x[n]− alpha dot x[n−1]
  $
]
Để khắc phục tình trạng rò rỉ dữ liệu khi cắt tín hiệu đột ngột ở hai đầu mỗi mẫu âm thanh, một hàm cửa sổ Hamming sẽ được áp dụng để làm mờ hai đầu có tín hiệu về 0 để đảm bảo tính liên tục. Đồng thời, do các hàm cửa sổ làm mờ tín hiệu về gần 0 ở các ranh giới, các khung phân tích này bắt buộc phải được xếp chồng lấp lên nhau nhằm đảm bảo mọi vùng của dạng sóng âm thanh đều đóng góp đầy đủ vào biểu diễn tần số chung @4.

Từ kích thước khung 1024 mẫu, biến đổi Fourier thời gian ngắn sinh ra một phổ công suất với 512 dải tần số tuyến tính kéo dài từ 0 đến tần số Nyquist là 11025Hz để tránh hiện tượng chồng phổ @4.

#figure(
  image("../figures/mel_spec.png", width: 100%),
  caption: [Phổ tần số Mel ],
)

Để phù hợp hơn với cơ chế cảm nhận của hệ thính giác con người, phổ tuyến tính sẽ được biến đổi sang Mel spectrogram bằng cách sử dụng một tập các bộ lọc thông dải tam giác được bố trí đều trên thang Mel. Mỗi bộ lọc tam giác sẽ đóng vai trò tích lũy tổng phổ công suất có trọng số dọc theo chiều tần số. Kết quả là một ma trận Mel spectrogram với 300 dải tần số Mel, trong đó mỗi hàng biểu diễn năng lượng của một dải Mel tại từng thời điểm, còn toàn bộ dãy các cột liên tiếp tạo thành một chuỗi quan sát theo thời gian. Cuối cùng, ma trận Mel spectrogram sẽ được chuẩn hóa để đảm bảo rằng các giá trị đặc trưng có phân phối ổn định, giúp mô hình học sâu học hiệu quả hơn.

Việc đưa các con số năng lượng nguyên bản vào mạng nơ-ron sẽ gây ra hiện tượng bùng nổ đạo hàm do chênh lệch biên độ quá lớn. Do đó, ma trận Mel được chuyển sang thang đo Decibel áp dụng cho ma trận Mel là:
#text(size: 14pt)[
  $
    S_"dB" [m,t] = 10 dot log((S_"mel" [m,t]) / (max S_"mel"))
  $
]
nhằm nén dải động khổng lồ này về một khoảng hẹp (chỉ khoảng ~60 dB), giúp mô hình nơ-ron hội tụ ổn định và học nhanh hơn. Việc dùng thang đo Log/dB được thiết kế để mô phỏng chính xác tai người cảm nhận âm lượng là cơ chế phi tuyến tính (logarithmic), qua đó giúp mô hình nơ-ron hội tụ ổn định và học nhanh hơn.

Trước khi đưa vào mô hình để huấn luyện, ta cần phải chuẩn hoá dữ liệu. Quá trình chuẩn hóa là bước để đảm bảo mạng nơ-ron hồi quy có thể hội tụ và học được các đặc trưng một cách ổn định. Quá trình này diễn ra ở hai cấp độ ở khâu tiền xử lý dữ liệu và ở ngay bên trong kiến trúc mô hình. Tại khâu tiền xử lý dữ liệu, dải giá trị của nó sẽ được ép về một khoảng tiêu chuẩn (thường là từ 0 đến 1).

#text(size: 16pt)[
  $
    S_"norm" [m, t] = (S_"dB" [m, t] - S_"dB"_"min" ) / (S_"dB"_max )
  $
]

Nếu đoạn âm thanh trích xuất hơi ngắn và tạo ra số khung thời gian nhỏ hơn, hệ thống sẽ thực hiện Zero-Padding. Thuật toán sẽ chèn thêm các cột chứa toàn giá trị 0 vào phần cuối của ma trận cho đến khi nó đạt đủ bước thời gian. Đối với mạng hồi quy, các bước thời gian chứa số 0 này đóng vai trò như các "khoảng lặng", mạng sẽ học cách bỏ qua chúng mà không làm ảnh hưởng đến đặc trưng giọng hát đã được trích xuất ở phần trước. Ngược lại, nếu đoạn âm thanh dài hơn dự kiến và sinh ra nhiều hơn số khung thời gian, hệ thống sẽ thực hiện cắt bỏ. Dữ liệu thừa ở phía cuối ma trận sẽ bị cắt bỏ để ép kích thước trục hoành về đúng con số bước thời gian.


== Tăng cường dữ liệu

Bên cạnh việc đã chọn ra một tập dữ liệu gốc các bài hát từ YouTube mà số lượng đã khá lớn đối với một ca sĩ, việc tăng cường tập dữ liệu là bước tiền xử lý cần thiết. Nền tảng kỹ thuật của việc này dựa trên nguyên lý: các mô hình học sâu có dung lượng bộ nhớ lớn, rất dễ quá khớp các đặc trưng cục bộ nếu tập dữ liệu huấn luyện quá nhỏ @9 @7. Bằng cách áp dụng các phép biến đổi không làm thay đổi nhãn ngữ nghĩa của âm thanh, ta có thể nhân bản dữ liệu, giúp mô hình cải thiện khả năng khái quát hóa và tăng độ bền bỉ trước các tín hiệu bị nhiễu hoặc suy giảm chất lượng trong môi trường thực tế @7.

*Phương pháp 1: Thêm nhiễu vào mẫu.*

Phương pháp này mô phỏng các tạp âm môi trường hoặc nhiễu thiết bị thu âm sinh ra trong thực tế @9. Đây được xem là một phép biến đổi thêm nhiễu mà không làm thay đổi danh tính giọng hát của ca sĩ. Kỹ thuật này sử dụng thư viện Librosa để tạo ra nhiễu trắng và cộng trực tiếp vào tín hiệu âm thanh gốc @10.

#text(size: 15pt)[$
  y_"add_noise" = y_"org" + "Noise" dot max(y_"org")
$]
Trong đó $y_"org"$ là tín hiệu gốc và Noise là tác nhân gây nhiễu.

*Phương pháp 2: Cắt ghép mẫu.*
Đây là một kỹ thuật tăng cường dữ liệu mới được nhóm tác giả đề xuất. Cụ thể, một đoạn âm thanh dài 5 giây sẽ được cắt làm 2 nửa bằng nhau, mỗi nửa dài 2.5 giây. Sau đó, hai nửa này được nối lại với nhau theo trật tự đảo ngược (nửa số 2 đưa lên trước nửa số 1) để tạo ra một dạng sóng âm hoàn toàn mới @1.

Điểm đặc biệt của kỹ thuật này là khả năng khai thác tính chất chuỗi thời gian của tín hiệu: nó thay đổi trật tự thời gian nhưng không hề làm biến dạng phổ âm sắc của giọng hát ca sĩ ở miền tần số. Kỹ thuật này giúp nhân đôi quy mô tập dữ liệu một cách dễ dàng và an toàn. Để tối đa hóa hiệu suất, hệ thống có thể kết hợp nối tiếp hai phương pháp: áp dụng cắt ghép mẫu trước, sau đó tiếp tục thêm nhiễu nhẹ vào chính mẫu vừa cắt ghép, tạo ra môi trường huấn luyện đa dạng nhất.

Nhờ các phương pháp tăng cường dữ liệu, ta có thể bổ sung thêm vào tập dữ liệu nếu số liệu trả về gặp các vấn đề như quá khớp.


== Tổng hợp dữ liệu
Với số lượng tổng 10 ca sĩ và 11 bài hát cho mỗi ca sĩ. Tập huấn luyện sẽ được chọn ra 9 bài với mỗi ca sĩ tương ứng với 3608 mẫu, 1 bài cho tập xác thực với 433 mẫu, 1 bài cho tập kiểm thử với 391 mẫu. Sau khi xử lý có tổng cộng 4432 mẫu ma trận hai chiều dạng với cấu hình (time_series, n_mels) là (300,300)

#figure(
  image("../figures/dataset.png", width: 90%),
  caption: [Số mẫu và ca sĩ được chọn],
)

Ngoài ra với việc tăng cường dữ liệu sẽ có thêm 2 bộ dữ liệu cùng cấu hình được thêm vào giúp cho số lượng mẫu trong tập dữ liệu tăng lên đến 11730 mẫu.

