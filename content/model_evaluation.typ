= ĐÁNH GIÁ THỰC NGHIỆM

Chương này trình bày quá trình huấn luyện và đánh giá mô hình để nhận dạng giọng ca sĩ Việt Nam nhằm so sánh hiệu quả của 2 mô hình GRU và LSTM trên các tập dữ liệu đã được xử lý, tăng cường dữ liệu và thực nghiệm để tìm ra mô hình phù hợp nhất.

== Phương pháp đánh giá
Trong quá trình triển khai để nhận dạng mười giọng ca sĩ Việt Nam đương đại, các mô hình học sâu đã được đưa vào một quy trình đánh giá, trong đó mỗi lần lặp sử dụng chín bài hát cho tập huấn luyện để huấn luyện, một bài hát cho tập xác thực và một bài nhạc mới để kiểm tra.

== Thiết lập môi trường thực nghiệm
Các thực nghiệm trong khóa luận được triển khai bằng ngôn ngữ Python sử dụng thư viện PyTorch cho quá trình xây dựng và huấn luyện mô hình học sâu. Toàn bộ quá trình huấn luyện và đánh giá được thực hiện trên môi trường GPU nhằm tăng tốc các phép tính.

#figure(
  table(
    columns: 2,
    align: center + horizon,
    [*Tham số*], [*Giá trị*],
    [CPU], [Intel Core i5-12400F],
    [GPU], [NVIDIA GeForce RTX 3050 8GB],
    [RAM], [16GB DDR4],
    [OS], [Windows 11],
    [Python], [3.10.12],
    [PyTorch], [2.7.0],
  ),
  caption: [Cấu hình môi trường phần cứng và phần mềm],
)

== Cấu hình các mô hình

Cả hai mô hình đều chia sẻ kiến trúc tổng thể giống nhau, chỉ khác nhau ở loại ô nhớ hồi quy (GRU hoặc LSTM). Phần dưới đây phân tích chi tiết cấu trúc từng lớp và luồng dữ liệu xuyên suốt mạng.

=== Đầu vào

Mỗi mẫu đầu vào là một phổ Mel spectrogram có kích thước $300 times 300$, trong đó 300 bước thời gian (time steps) và 300 dải tần số Mel (Mel bins). Khi đưa vào mô hình mạng nơ-ron hồi quy, tensor đầu vào có dạng $(B, T, F)$ với $B = 32$ (batch size), $T = 300$ (sequence length) và $F = 300$ (input size). Mô hình sẽ xử lý tuần tự qua 300 bước thời gian, tại mỗi bước nhận một vector đặc trưng 300 chiều.

=== Khối mạng nơ-ron hồi quy hai lớp xếp chồng (Stacked mạng nơ-ron hồi quy)

Mô hình sử dụng 2 lớp mạng nơ-ron hồi quy xếp chồng lên nhau (num_layers = 2) với kích thước không gian ẩn (hidden state) là $h = 356$. Cả hai lớp đều hoạt động theo chiều duy nhất (unidirectional) và không sử dụng cơ chế attention. Cấu trúc này cho phép mô hình học được các biểu diễn phức tạp từ chuỗi Mel spectrogram.

*Lớp mạng nơ-ron hồi quy thứ nhất* nhận đầu vào trực tiếp từ phổ Mel với kích thước $F = 300$. Tại mỗi bước thời gian $t$, lớp này tính toán trạng thái ẩn $bold(h)_t$ dựa trên vector đặc trưng $bold(x)_t$ và trạng thái ẩn trước đó $bold(h)_(t-1)$.

*Lớp mạng nơ-ron hồi quy thứ hai* nhận đầu ra của lớp thứ nhất làm đầu vào, tức là vector 356 chiều tại mỗi bước thời gian. Lớp này tiếp tục xử lý theo một chiều duy nhất và giữ nguyên chiều ẩn $h = 356$, tạo ra đầu ra $bold(o)_t^(2) in RR^(356)$. Giữa hai lớp, Dropout với tỷ lệ 0.25 được áp dụng để giảm hiện tượng quá khớp bằng cách ngẫu nhiên tắt 25% các nơ-ron trong quá trình huấn luyện.

=== Cơ chế Mean Pooling

Sau khi xử lý xong toàn bộ $T = 300$ bước thời gian, lớp mạng nơ-ron hồi quy thứ hai tạo ra chuỗi đầu ra ${bold(o)_1^(2), bold(o)_2^(2), ..., bold(o)_T^(2)}$ với mỗi $bold(o)_t^(2) in RR^(356)$. Thay vì chỉ lấy trạng thái ẩn ở bước cuối cùng, mô hình áp dụng Mean Pooling — tính trung bình cộng toàn bộ chuỗi đầu ra:

#text(size: 15pt)[
  $
    bold(v) = 1/T sum_(t=1)^(T) bold(o)_t^(2) in RR^(356)
  $
]

Cơ chế này giúp tổng hợp thông tin từ toàn bộ đoạn nhạc thay vì chỉ dựa vào khoảnh khắc cuối cùng, tạo ra biểu diễn đặc trưng ổn định hơn cho giọng hát.

=== Lớp phân loại (Classification Head)

Vector $bold(v) in RR^(356)$ được đưa qua một lớp kết nối đầy đủ với phép biến đổi tuyến tính:

#text(size: 15pt)[
  $
    bold(y) = bold(W) dot bold(v) + bold(b)
  $
]

Trong đó:

$bold(W) in RR^(10 times 356)$ là ma trận trọng số của lớp Linear, với 10 hàng ứng với 10 nhãn ca sĩ và 356 cột ứng với từng thành phần của vector đặc trưng $bold(v)$.
$bold(b) in RR^(10)$ là vector độ lệch, thêm một hạng cố định cho mỗi nhãn để điều chỉnh điểm số.

Kết quả là $bold(y) \in RR^(10)$, trong đó mỗi phần tử $y_i$ là điểm số thô (logit) cho lớp ca sĩ thứ $i$. Các logit này không phải là xác suất ngay lập tức; chúng đại diện cho độ ưu tiên tương đối của mô hình đối với mỗi nhãn.

Sau đó, đầu ra $bold(y)$ được đưa qua hàm Softmax để chuyển các logit thành xác suất phân loại:

#text(size: 15pt)[
  $
    "softmax"(bold(y)_i) = frac(e^(y_i), sum_(j=1)^10 e^(y_j))
  $
]

Hàm Softmax đảm bảo rằng tất cả giá trị đầu ra đều nằm trong khoảng $[0,1]$ và tổng bằng 1, nên nó phù hợp để lựa chọn nhãn ca sĩ có xác suất cao nhất.

=== So sánh số lượng tham số

Sự khác biệt cơ bản giữa GRU và LSTM nằm ở cấu trúc cổng bên trong. GRU sử dụng 3 cổng (cổng thiết lập lại, cổng cập nhật, cổng mới) trong khi LSTM sử dụng 4 cổng (cổng quên, cổng đầu vào, cổng tế bào, cổng đầu ra). Công thức tổng quát để tính số lượng tham số cho toàn bộ khối mạng nơ-ron hồi quy là:
#text(size: 15pt)[
  $
    "params"_"GRU" = 3 dot ("input_size" dot h + h^2 + 2h) + 3 dot (2h^2 + 2h)
  $
]

#text(size: 15pt)[
  $
    "params"_"LSTM" = 4 dot ("input_size" dot h + h^2 + 2h) + 4 dot (2h^2 + 2h)
  $
]

Ở đây, $"input"_"size"$ là số chiều của đầu vào mỗi bước thời gian và $h$ là kích thước của trạng thái ẩn. Công thức này đã bao gồm cả trọng số đầu vào, trọng số trạng thái ẩn và bias cho từng cổng.

Khi có hai lớp mạng nơ-ron hồi quy xếp chồng, tổng số tham số của khối mạng nơ-ron hồi quy bằng tổng tham số của lớp thứ nhất và lớp thứ hai. Lớp thứ hai nhận đầu vào có kích thước bằng $h$ của lớp thứ nhất, nên phần trọng số đầu vào của lớp thứ hai được tính với $"input"_"size" = h$.

Ngoài phần tham số của khối mạng nơ-ron hồi quy, cần cộng thêm tham số của lớp phân loại Linear. Lớp này ánh xạ vector đặc trưng cuối cùng sang số lượng nhãn đầu ra, nên số tham số của nó phụ thuộc vào kích thước vector đầu vào và số lớp phân loại.

=== Cấu hình huấn luyện

Trong quá trình huấn luyện, mô hình sử dụng optimizer AdamW với tham số learning rate được đặt ở mức $10^(-4)$ và kích thước batch size ở mức 32.

Các siêu tham số chính có ý nghĩa như sau:

*Optimizer AdamW*: là biến thể của Adam với cơ chế weight decay tách rời khỏi bước cập nhật gradient. Điều này giúp giảm hiện tượng quá khớp mà không làm sai lệch momen gradient trong quá trình tối ưu.

*Learning Rate ($10^{-4}$)*: xác định độ lớn của bước cập nhật trọng số sau mỗi lần tính gradient. Giá trị nhỏ giúp quá trình học ổn định với dữ liệu tuần tự và kiến trúc mạng nơ-ron hồi quy.

*Batch Size (32)*: là số mẫu được đưa vào một bước lan truyền tiến và lan truyền ngược. Batch size 32 cân bằng giữa tính ổn định của gradient và khả năng sử dụng hiệu quả bộ nhớ GPU.

*Weight Decay ($lambda = 10^{-3}$)*: là hệ số phạt L2 để hạn chế độ lớn của trọng số. Weight decay thêm một số hạng $lambda sum_i w_i^2$ vào hàm mất mát, khuyến khích trọng số nhỏ hơn và giảm độ phức tạp mô hình.

#text(size: 16pt)[
  $
    cal(L)_"total" = cal(L)_"CrossEntropy" + lambda sum_(i) w_i^2
  $
]

trong đó $cal(L)_"CrossEntropy"$ là hàm mất mát gốc và $lambda sum w_i^2$ là số hạng phạt L2. Khi trọng số $w_i$ có giá trị lớn, số hạng phạt tăng lên đáng kể, khiến optimizer phải cân bằng giữa việc giảm lỗi phân loại và việc giữ trọng số ở mức nhỏ. Điều này ngăn mô hình ghi nhớ quá mức các mẫu huấn luyện cụ thể, thay vào đó khuyến khích mô hình học các đặc trưng tổng quát hơn. Riêng với AdamW, weight decay được tách biệt khỏi bước cập nhật gradient (decoupled weight decay), khác với cách triển khai L2 truyền thống trong Adam, giúp quá trình chính quy hóa hoạt động hiệu quả hơn.

*Dropout (0.25)*: tắt ngẫu nhiên 25% đơn vị ở giữa hai lớp mạng nơ-ron hồi quy trong mỗi bước huấn luyện. Điều này giúp giảm sự phụ thuộc quá mức vào một số nơ-ron cố định và tăng khả năng tổng quát của mô hình.

*ReduceLROnPlateau*: giảm learning rate khi validation loss không cải thiện sau một số chu kỳnhất định. Cơ chế này giúp mô hình tiến tới các cực tiểu sâu hơn khi learning rate ban đầu đã bão hòa.

*Early Stopping*: dừng huấn luyện khi validation loss không còn cải thiện để tránh huấn luyện quá mức và giữ lại mô hình tốt nhất theo tập xác thực.

*CrossEntropyLoss*: Hàm mất mát CrossEntropyLoss mặc định sẽ tính toán giá trị trung bình trên toàn bộ 32 mẫu trong một lô, từ đó mô hình mới thực hiện lan truyền ngược để cập nhật tham số, giúp quỹ đạo học mượt mà và tránh nhiễu cục bộ. Đồng thời, để theo dõi chính xác tổng mức độ mất mát của toàn bộ chu kỳ, giá trị loss trung bình này luôn được nhân ngược lại với kích thước lô trước khi cộng dồn.

Ngoài ra, hệ thống tích hợp cơ chế điều chỉnh tỷ lệ học linh hoạt thông qua thuật toán ReduceLROnPlateau. Cơ chế này hoạt động bằng cách liên tục theo dõi độ lỗi trên tập xác thực với mục tiêu tối thiểu hóa, và nếu độ lỗi này không cho thấy sự cải thiện sau một khoảng thời gian chờ, tỷ lệ học sẽ tự động giảm xuống. Điều này giúp các trọng số của mô hình không bị dao động chệch hướng khi đã tiến rất gần đến điểm cực tiểu tối ưu, tạo điều kiện cho mạng nơ-ron học các tinh chỉnh nhỏ nhất và hội tụ ổn định ở những giai đoạn huấn luyện cuối cùng. Early stopping cũng được sử dụng bằng cách kiểm tra validation loss sau mỗi chu kỳ và lưu lại mô hình tốt nhất thời điểm đó để tiến hành kiểm tra ở bước cuối với tập kiểm tra.

#figure(
  table(
    columns: 2,
    align: center + horizon,
    [*Tham số*], [*Giá trị*],
    [Lớp], [`nn.GRU`],
    [Kích thước Hidden State], [356],
    [Số lớp (Num Layers)], [2],
    [Cơ chế Pooling], [Mean Pooling],
    [Optimizer], [AdamW],
    [Learning Rate], [$10^(-4)$],
    [Weight Decay], [$10^(-4)$],
    [Scheduler], [ReduceLROnPlateau (patience=5)],
    [Batch Size], [32],
    [Dropout], [0.25],
  ),
  caption: [Cấu hình chi tiết các siêu tham số của mô hình GRU],
)

#figure(
  table(
    columns: 2,
    align: center + horizon,
    [*Tham số*], [*Giá trị*],
    [Lớp], [`nn.LSTM`],
    [Kích thước Hidden State], [356],
    [Số lớp (Num Layers)], [2],
    [Cơ chế Pooling], [Mean Pooling],
    [Optimizer], [AdamW],
    [Learning Rate], [$10^(-4)$],
    [Weight Decay], [$10^(-4)$],
    [Scheduler], [ReduceLROnPlateau (patience=5)],
    [Batch Size], [32],
    [Dropout], [0.25],
  ),
  caption: [Cấu hình chi tiết các siêu tham số của mô hình LSTM],
)

== Kết quả thực nghiệm
=== Tổng quan độ chính xác giữa hai mô hình

Từ dữ liệu thực nghiệm với tập dữ liệu bao gồm tập dữ liệu gốc kết hợp với hai tập dữ liệu được tăng cường thêm. Từ đó nâng số lượng mẫu của tập dữ liệu lên thành 11730 mẫu cho tập huấn luyện và tập xác thực là 433 mẫu. Tập kiểm tra là 1 phần dữ liệu mới sẽ được dùng gồm 391 mẫu để đánh giá độ chính xác của mô hình sau khi được huấn luyện.

==== Kết quả huấn luyện theo các chu kỳ

#figure(
  image("/figures/GRU_loss_chart.png", width: 100%),
  caption: [Chu kỳ huấn luyện của mô hình GRU],
) <fig:gru_loss>

#figure(
  image("/figures/LSTm_loss_chart.png", width: 100%),
  caption: [Chu kỳ huấn luyện của mô hình LSTM],
) <fig:lstm_loss>

Từ hai biểu đồ loss, cả hai mô hình đều hội tụ ổn định trong 15 chu kỳ, nhưng có một số khác biệt quan trọng.

Với LSTM, cả train loss và val loss giảm rất nhanh ngay từ đầu, và hai đường gần như đi song song sau chu kỳ thứ 3. Điều này cho thấy LSTM học khá ổn định trên cả tập huấn luyện và tập xác thực, đồng thời không tạo ra khoảng cách lớn giữa hai đường loss.

Với GRU, train loss cũng giảm đều, nhưng val loss vẫn nằm cao hơn chút so với train loss và có vài dao động nhỏ quanh chu kỳ 10. Điều này gợi ý rằng GRU có một khoảng cách nhỏ hơn giữa train và val loss, nhưng vẫn hơi kém mượt so với LSTM.

Như vậy, xét riêng trên biểu đồ loss, LSTM thể hiện khả năng hội tụ nhanh hơn và độ ổn định validation tốt hơn. Tuy nhiên, vì test accuracy cuối cùng vẫn là thước đo quyết định chất lượng mô hình trên dữ liệu chưa từng thấy, chúng ta cần xem xét cả hai khía cạnh: LSTM có học tốt trên huấn luyện/xác thực, trong khi GRU có thể cho kết quả tổng quát hóa tốt hơn trên tập kiểm thử.

Trong khi Loss là một con số xác suất liên tục dùng để tối ưu mạng nơ-ron, thì Accuracy (Độ chính xác) là một con số rời rạc, được thiết kế để con người dễ hiểu. Nó chỉ quan tâm đến kết quả cuối cùng là Đúng hay Sai, chứ không quan tâm đến mô hình tự tin bao nhiêu.

Cách tính Accuracy:

#text(size: 15pt)[
  $
    "Accuracy" = frac("Số dự đoán đúng", "Tổng số dự đoán") = frac("TP" + "TN", "TP" + "TN" + "FP" + "FN")
  $
]
Trong đó TP: True Positive, TN: True Negative, FP: False Positive, FN: False Negative

Tiêu chí quyết định: Sau khi đi qua lớp Softmax để ra 10 xác suất cho 10 ca sĩ, mô hình sẽ dùng hàm argmax (chọn giá trị cao nhất). Nếu xác suất cao nhất rơi vào đúng nhãn ca sĩ thực tế, nó đếm là 1 điểm cộng (Đúng). Dù xác suất cao nhất đó là 0.99 (rất tự tin) hay chỉ là 0.35 (chỉ nhỉnh hơn các ca sĩ khác một chút), thì kết quả vẫn được tính chung là "1 lần dự đoán đúng".

Độ chính xác Accuracy trên tập kiểm thử (Test Accuracy) của mô hình GRU đạt trung bình 79% và mô hình LSTM đạt 76%. Kết quả này cho thấy mô hình GRU có khả năng khái quát hóa dữ liệu tốt hơn so với LSTM.

=== Đánh giá mô hình qua F1-score

Chỉ số F1-score là trung bình điều hòa của Precision và Recall nên đây là thước đo cân bằng nhất để đánh giá một mô hình phân loại đa lớp.

*Precision* đo lường tỷ lệ dự đoán đúng trên tổng số dự đoán của một lớp. Precision cao nghĩa là khi mô hình gán nhãn là một ca sĩ nào đó, thì khả năng nhãn đó đúng là lớn.

*Recall* đo lường tỷ lệ dự đoán đúng trên tổng số mẫu thực tế của một lớp. Recall cao nghĩa là mô hình tìm được nhiều mẫu thực sự thuộc lớp đó.

Công thức F1-score là:

#text(size: 15pt)[
  $
    "F1" = 2 dot frac("Precision" dot "Recall", "Precision" + "Recall")
  $
]

F1-score ưu tiên sự cân bằng giữa Precision và Recall. Nếu một mô hình có Precision cao nhưng Recall thấp, hoặc ngược lại, F1-score vẫn bị kéo xuống. Dựa trên @tab:model_comparison, phần dưới đây phân tích hiệu năng hai mô hình GRU và LSTM thông qua F1-score.


*Bảng kết quả F1-score theo từng lớp ca sĩ*
#figure(
  caption: [So sánh hiệu năng của mô hình GRU và LSTM trên từng lớp ca sĩ.],
  kind: table,
  table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: (col, row) => if col == 0 { left } else { center },
    stroke: none,
    table.hline(y: 0, stroke: 1pt),
    table.vline(x: 1, start: 0, end: 2, stroke: 0.5pt),
    table.vline(x: 4, start: 0, end: 2, stroke: 0.5pt),

    table.header(
      table.cell(rowspan: 2, align: left + horizon)[*Ca sĩ*],
      table.cell(colspan: 3)[*GRU*],
      table.cell(colspan: 3)[*LSTM*],
      [*P*], [*R*], [*F1*], [*P*], [*R*], [*F1*],
    ),

    // Đường kẻ ngang dưới header
    table.hline(y: 2, stroke: 0.5pt),

    // Dữ liệu từng lớp
    [Bùi Trường Linh], [97.0], [77.0], [86.0], [87.0], [69.0], [77.0],
    [Nguyễn Huyền Trang], [74.0], [97.0], [84.0], [91.0], [100.0], [95.0],
    [Hà Anh Tuấn], [100.0], [55.0], [71.0], [96.0], [45.0], [62.0],
    [Hoàng Dũng], [81.0], [98.0], [88.0], [82.0], [98.0], [89.0],
    [Trần My Anh], [63.0], [88.0], [73.0], [48.0], [33.0], [39.0],
    [Đỗ Quốc Thịnh], [74.0], [80.0], [77.0], [65.0], [88.0], [75.0],
    [Tóc Tiên], [84.0], [66.0], [74.0], [76.0], [50.0], [60.0],
    [Vũ Cát Tường], [69.0], [87.0], [77.0], [44.0], [89.0], [59.0],
    [Vũ Thanh Vân], [100.0], [73.0], [84.0], [95.0], [64.0], [76.0],
    [Hoàng Thái Vũ], [88.0], [92.0], [90.0], [94.0], [84.0], [89.0],

    // Đường kẻ ngang trước phần trung bình
    table.hline(stroke: 0.5pt),

    [*Macro Avg*], [*83.0*], [*81.0*], [*80.0*], [*78.0*], [*72.0*], [*72.0*],
    [*Weighted Avg*], [*84.0*], [*81.0*], [*80.0*], [*78.0*], [*72.0*], [*72.0*],

    // Đường kẻ ngang dưới cùng (đậm)
    table.hline(stroke: 1pt),
  ),
) <tab:model_comparison>

P, R và F1 lần lượt biểu thị Precision, Recall và F1-score (%).

==== Đánh giá tổng quan qua F1-score trung bình

Một tiêu chí quan trọng khi đánh giá mô hình phân loại đa lớp là mức độ đồng đều của F1-score giữa các lớp. Mô hình lý tưởng cần đạt F1 cao và đều trên tất cả các nhãn, tránh hiện tượng chỉ nhận diện tốt một vài lớp nhưng thất bại ở các lớp còn lại.

Xét chỉ số F1-score Macro Avg, mô hình GRU đạt 80.0% trong khi LSTM chỉ đạt 72.0%, chênh lệch 8%. Khoảng cách này phản ánh rằng GRU duy trì được sự cân bằng giữa Precision và Recall ổn định hơn trên toàn bộ 10 lớp ca sĩ. Chỉ số Weighted Avg F1 cũng cho kết quả tương tự, cho thấy ưu thế của GRU không phụ thuộc vào số lượng mẫu của từng lớp mà là ưu thế mang tính hệ thống. Điều đáng lưu ý là LSTM sở hữu số lượng tham số lớn hơn GRU, nhưng F1-score lại thấp hơn đáng kể. Điều này gợi ý rằng với quy mô tập dữ liệu hiện tại (11730 mẫu huấn luyện), kiến trúc LSTM với nhiều tham số hơn có xu hướng quá khớp trên tập huấn luyện, dẫn đến khả năng tổng quát hóa kém hơn khi đánh giá trên tập kiểm thử.

Mô hình GRU có dải F1-score dao động từ 71.0% (Hà Anh Tuấn) đến 90.0% (Hoàng Thái Vũ), biên độ chênh lệch chỉ 19 điểm phần trăm. Cụ thể, có tới 7 trên 10 lớp đạt F1 từ 77.0% trở lên, trong đó ba lớp dẫn đầu là Hoàng Thái Vũ (90.0%), Hoàng Dũng (88.0%) và Bùi Trường Linh (86.0%). Không có lớp nào rơi dưới ngưỡng 70.0%, cho thấy GRU học được các đặc trưng giọng hát một cách tương đối đồng đều.

Mô hình LSTM ngược lại, có dải F1-score trải rộng từ 39.0% (Trần My Anh) đến 95.0% (Nguyễn Huyền Trang), biên độ chênh lệch lên tới 56 điểm phần trăm, gấp gần 3 lần so với GRU. Mặc dù LSTM đạt F1 cao nhất toàn bảng ở lớp Nguyễn Huyền Trang (95.0%), nhưng có tới 3 lớp rơi dưới ngưỡng 62.0% bao gồm Trần My Anh (39.0%), Vũ Cát Tường (59.0%) và Tóc Tiên (60.0%). Sự phân tán lớn này cho thấy LSTM không học được biểu diễn đặc trưng nhất quán cho tất cả các giọng ca, mà chỉ ghi nhớ tốt một số mẫu có đặc trưng nổi bật.

==== Nguyên nhân F1 thấp

Precision cao nhưng Recall thấp ở trường hợp ca sĩ Hà Anh Tuấn xuất hiện lỗi này ở cả hai mô hình. GRU đạt Precision 100.0% nhưng Recall chỉ 55.0% (F1: 71.0%); LSTM đạt Precision 96.0% nhưng Recall chỉ 45.0% (F1: 62.0%). Khi mô hình dự đoán một mẫu là Hà Anh Tuấn thì gần như luôn đúng, tuy nhiên gần một nửa số mẫu thực tế của ca sĩ này lại bị phân loại nhầm sang người khác. Nguyên nhân có thể là do phong cách trình diễn đa dạng và kỹ thuật thanh nhạc phong phú khiến các đặc trưng Mel spectrogram biến thiên mạnh giữa các bài hát, gây khó khăn cho mô hình khi cần nhận ra tính nhất quán của giọng hát.

Ở trường hợp Vũ Cát Tường ở mô hình LSTM khi Recall đạt 89.0% nhưng Precision chỉ 44.0% (F1: 59.0%). Mô hình tuy tìm được hầu hết các mẫu thật nhưng đồng thời gán nhầm rất nhiều mẫu của ca sĩ khác vào nhãn này, dẫn tới tỷ lệ dương tính giả rất cao. Tương tự, lớp Trần My Anh ở LSTM gặp tình trạng nghiêm trọng nhất khi cả Precision (48.0%) lẫn Recall (33.0%) đều rất thấp, kéo F1 xuống còn 39.0%. Đây là lớp mà LSTM gần như thất bại hoàn toàn trong việc phân loại. Ở mô hình GRU, lớp Trần My Anh cũng có Precision thấp nhất (63.0%) nhưng được bù đắp bởi Recall cao (88.0%), giúp F1 duy trì ở mức chấp nhận được (73.0%).


==== Các lớp mà GRU vượt trội so với LSTM

So sánh F1-score theo từng lớp, GRU đạt F1 cao hơn LSTM ở 8 trên 10 lớp. Ba lớp có chênh lệch lớn nhất lần lượt là Trần My Anh (GRU: 73.0% so với LSTM: 39.0%, chênh 34 điểm), Vũ Cát Tường (77.0% so với 59.0%, chênh 18 điểm) và Tóc Tiên (74.0% so với 60.0%, chênh 14 điểm). Đây đều là những lớp mà LSTM gặp vấn đề nghiêm trọng về mất cân bằng Precision-Recall, trong khi GRU duy trì được sự cân đối hơn giữa hai chỉ số này.

LSTM chỉ vượt trội ở lớp Nguyễn Huyền Trang (F1: 95.0% so với 84.0% của GRU) và xấp xỉ bằng ở lớp Hoàng Dũng (89.0% so với 88.0%). Điều này cho thấy ưu thế của LSTM chỉ tập trung vào những giọng ca có đặc trưng rất riêng biệt và dễ phân biệt, nhưng mô hình lại gặp khó khăn lớn với các giọng ca có sự tương đồng hoặc biến thiên phức tạp hơn.


=== Đánh giá với ma trận nhầm lẫn

Ma trận nhầm lẫn (Confusion Matrix) là công cụ trực quan hóa hiệu năng phân loại, trong đó mỗi hàng biểu diễn nhãn thực tế và mỗi cột biểu diễn nhãn dự đoán. Các ô trên đường chéo chính cho biết tỷ lệ phân loại đúng, còn các ô ngoài đường chéo cho biết tỷ lệ nhầm lẫn giữa các cặp lớp. Phân tích ma trận nhầm lẫn giúp xác định chính xác các mẫu bị phân loại sai chảy về đâu, từ đó giải thích nguyên nhân gốc rễ khiến F1-score sụt giảm ở từng lớp cụ thể.

==== Ma trận nhầm lẫn của mô hình GRU

#figure(
  image("/figures/gru_confusion_matrix.png", width: 100%),
  caption: [Ma trận nhầm lẫn của mô hình GRU trên tập kiểm thử],
) <fig:gru_cm>

Từ @fig:gru_cm, hiệu năng phân loại của mô hình GRU có thể được chia thành ba nhóm rõ rệt dựa trên tỷ lệ phân loại đúng trên đường chéo chính.

*Nhóm hiệu năng cao* gồm Hoàng Dũng, Nguyễn Huyền Trang và Hoàng Thái Vũ với tỷ lệ phân loại đúng đều trên 92%. Kết quả này nhất quán với F1-score cao nhất trong @tab:model_comparison, cho thấy các ca sĩ này sở hữu đặc trưng phổ Mel có tính phân biệt cao, có thể do âm vực, kỹ thuật thanh nhạc hoặc phong cách trình diễn mang dấu ấn cá nhân rõ ràng, giúp mô hình dễ dàng tách biệt khỏi các lớp còn lại.

*Nhóm hiệu năng trung bình* gồm Bùi Trường Linh, Vũ Thanh Vân và Đỗ Quốc Thịnh. Ở nhóm này, mô hình nhận diện đúng phần lớn các mẫu nhưng vẫn tồn tại một số cặp nhầm lẫn đáng chú ý. Chẳng hạn, các mẫu của Bùi Trường Linh bị nhầm sang Đỗ Quốc Thịnh cho thấy hai giọng ca nam này chia sẻ một phần vùng đặc trưng phổ, có thể do quãng giọng tương đương hoặc phong cách hát gần nhau. Tương tự, Vũ Thanh Vân bị rò rỉ mẫu sang Vũ Cát Tường và Nguyễn Huyền Trang — những giọng nữ cùng tầm âm vực — phản ánh ranh giới quyết định giữa các lớp này chưa đủ sắc nét.

*Nhóm hiệu năng thấp* gồm Hà Anh Tuấn và Tóc Tiên, là hai trường hợp đáng quan tâm nhất. Ở Hà Anh Tuấn, mẫu bị phân loại sai không tập trung vào một lớp duy nhất mà phân tán sang nhiều hướng khác nhau (Trần My Anh, Vũ Cát Tường, Hoàng Dũng, Tóc Tiên). Hiện tượng phân tán lỗi đa hướng này cho thấy đặc trưng giọng hát của Hà Anh Tuấn không nằm ở vùng riêng biệt trong không gian đặc trưng mà chồng lấn với nhiều ca sĩ khác, có thể do phong cách trình diễn đa dạng qua các thể loại nhạc khác nhau. Còn ở Tóc Tiên, tỷ lệ nhầm sang Trần My Anh chiếm phần lớn trong tổng lỗi, gợi ý rằng hai giọng ca nữ này có sự tương đồng đáng kể về đặc trưng âm sắc — đây là mẫu nhầm lẫn mang tính hệ thống cần được giải quyết ở cấp độ tiền xử lý hoặc tăng cường dữ liệu.

Nhìn tổng thể, một đặc điểm tích cực của mô hình GRU là lỗi nhầm lẫn phân bố tương đối đều giữa các lớp với tỷ lệ nhỏ, không xuất hiện hiện tượng "điểm hút" — tức một lớp duy nhất thu hút lượng lớn mẫu sai từ nhiều lớp khác. Điều này cho thấy mô hình GRU học được không gian biểu diễn cân bằng, trong đó ranh giới quyết định giữa các lớp được phân bổ hợp lý thay vì bị lệch về một phía.

==== Ma trận nhầm lẫn của mô hình LSTM

#figure(
  image("/figures/lstm_confusion_matrix.png", width: 90%),
  caption: [Ma trận nhầm lẫn của mô hình LSTM trên tập kiểm thử],
) <fig:lstm_cm>

Từ @fig:lstm_cm, ma trận nhầm lẫn của LSTM bộc lộ những vấn đề nghiêm trọng hơn so với GRU. Mặc dù một số lớp vẫn duy trì tỷ lệ phân loại đúng rất cao như Nguyễn Huyền Trang (100.0%), Hoàng Dũng (97.9%) và Vũ Cát Tường (88.7%), nhưng nhiều lớp khác có tỷ lệ phân loại đúng sụt giảm đáng kể so với GRU.

Đặc điểm nổi bật nhất của ma trận LSTM là sự xuất hiện của hiện tượng "điểm hút" (attractor) ở cột Vũ Cát Tường. Cụ thể:

Ca sĩ Trần My Anh chỉ đạt 33.3% phân loại đúng, giảm mạnh so với 87.9% ở GRU. Tới 66.7% mẫu Trần My Anh bị nhầm sang Vũ Cát Tường. Đây là tỷ lệ nhầm lẫn đơn lẻ lớn nhất trên toàn bộ ma trận, giải thích trực tiếp cho F1 cực thấp (39.0%). Và Hà Anh Tuấn chỉ đạt 45.3% phân loại đúng, với 37.7% mẫu bị nhầm sang Vũ Cát Tường và 7.5% sang Hoàng Dũng. So với GRU (54.7%), LSTM để mất nhiều mẫu hơn và các mẫu này tập trung chảy về một hướng duy nhất.

*Tóc Tiên* đạt 50.0% phân loại đúng, với 28.1% bị nhầm sang Trần My Anh và 18.8% sang Vũ Cát Tường. Tổng cộng gần một nửa mẫu bị phân loại sai.

*Vũ Thanh Vân* đạt 63.6% phân loại đúng, nhưng 27.3% bị nhầm sang Vũ Cát Tường — tỷ lệ gần gấp đôi so với GRU (15.2%).

*Bùi Trường Linh* đạt 68.8%, với 22.9% bị nhầm sang Đỗ Quốc Thịnh, cao hơn so với GRU (12.5%).

==== So sánh mô hình nhầm lẫn giữa GRU và LSTM

Khi đặt hai ma trận nhầm lẫn cạnh nhau, có thể rút ra những nhận xét quan trọng sau:

*Thứ nhất*, cột Vũ Cát Tường trong ma trận LSTM (@fig:lstm_cm) hấp thụ một lượng lớn mẫu sai từ nhiều lớp: 37.7% từ Hà Anh Tuấn, 66.7% từ Trần My Anh, 18.8% từ Tóc Tiên và 27.3% từ Vũ Thanh Vân. Hiện tượng này cho thấy LSTM có xu hướng "mặc định" dự đoán nhãn Vũ Cát Tường khi gặp các mẫu không rõ ràng, dẫn đến Precision của lớp này cực thấp (44.0%). Ở GRU, hiện tượng hút mẫu này không xuất hiện rõ ràng, các mẫu nhầm lẫn phân bố đều hơn giữa nhiều lớp.

*Thứ hai*, cả hai mô hình đều gặp khó khăn ở một số cặp ca sĩ nhất định, đặc biệt là cặp Tóc Tiên–Trần My Anh. Ở cả GRU (21.9%) lẫn LSTM (28.1%), một tỷ lệ đáng kể mẫu Tóc Tiên bị nhầm sang Trần My Anh. Điều này gợi ý rằng đặc trưng phổ Mel của hai giọng ca này có sự tương đồng nhất định, có thể do âm vực hoặc phong cách trình diễn gần nhau.

*Thứ ba*, các lớp có tỷ lệ phân loại đúng cao và ổn định ở cả hai mô hình (Nguyễn Huyền Trang, Hoàng Dũng, Hoàng Thái Vũ) đều là những ca sĩ có đặc trưng giọng hát riêng biệt và dễ phân biệt. Ngược lại, các lớp có hiệu năng thấp (Hà Anh Tuấn, Trần My Anh, Tóc Tiên) cho thấy sự cần thiết phải cải thiện khâu tiền xử lý hoặc bổ sung thêm dữ liệu huấn luyện để mô hình có thể nắm bắt được các đặc trưng tinh vi hơn của giọng hát.

=== Kết luận

Qua phân tích kết hợp độ chính xác trên các chu kỳ, F1-score và ma trận nhầm lẫn, mô hình GRU thể hiện ưu thế vượt trội so với LSTM trên ba phương diện: thứ nhất là độ chính xác trên tập kiểm tra là cao hơn (trung bình 79% với 76%); thứ hai là F1-score trung bình cao hơn (80.0% so với 72.0%); thứ ba là tính ổn định giữa các lớp tốt hơn nhiều (biên độ chênh lệch 19 điểm so với 56 điểm); và cuối cùng là mô hình phân tán lỗi nhầm lẫn đều hơn thay vì tập trung vào một lớp duy nhất như LSTM. Với kiến trúc đơn giản hơn và ít tham số hơn, GRU tránh được hiện tượng quá khớp và duy trì được sự cân bằng Precision-Recall trên đa số các lớp, giúp mô hình phù hợp hơn cho bài toán nhận dạng giọng hát ca sĩ trên tập dữ liệu hiện tại.
