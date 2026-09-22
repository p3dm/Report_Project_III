= KIẾN TRÚC ĐỀ XUẤT

== Long Short-Term Memory (LSTM)

=== Tổng quan kiến trúc LSTM

Mạng bộ nhớ ngắn hạn dài (Long Short-Term Memory - LSTM) là một bước đột phá trong lĩnh vực học sâu, được thiết kế chuyên biệt để khắc phục những hạn chế của các mạng nơ-ron hồi quy truyền thống (Recurrent Neural Networks) bằng cách giải quyết triệt để vấn đề tiêu biến đạo hàm khi học các chuỗi dữ liệu dài. Khả năng nắm bắt và duy trì các phụ thuộc dài hạn giúp kiến trúc LSTM trở thành công cụ đắc lực trong việc xử lý dữ liệu chuỗi, đặc biệt là tín hiệu âm thanh và âm nhạc, nơi các mối quan hệ theo thời gian đóng vai trò then chốt. Nhờ vào cơ chế kiểm soát thông tin thông minh thông qua các cổng và trạng thái tế bào, LSTM không chỉ ghi nhớ được các đặc trưng ngữ cảnh từ quá khứ mà còn quyết định được việc nên giữ lại hay loại bỏ thông tin nào @3. Khả năng này mang lại hiệu suất vượt trội cho LSTM trong các bài toán phức tạp như xử lý ngôn ngữ tự nhiên, phân loại chuỗi âm thanh và nhận dạng giọng hát của ca sĩ.

\
#figure(
  image("../figures/lstm_structure.png", width: 70%),
  caption: [Kiến trúc mô hình Long Short-Term Memory (LSTM)],
)
\

Kiến trúc cơ bản của LSTM gồm hai đường truyền tải dữ liệu chính và ba cơ chế cổng để điều tiết luồng thông tin:

- Trạng thái tế bào (Cell state - $C_t$) đóng vai trò là "bộ nhớ dài hạn" của mạng. Nó giống như một băng chuyền thông tin chạy xuyên suốt toàn bộ chuỗi thời gian, mang theo các ngữ cảnh quan trọng. Trạng thái tế bào có thể truyền thông tin từ các bước thời gian rất xa trong quá khứ đến hiện tại mà không bị suy giảm @3.

- Trạng thái ẩn (hidden states - $h_t$) lại đóng vai trò như một bộ nhớ ngắn hạn cung cấp đầu ra tại mỗi bước thời gian, đại diện cho các đặc trưng đã học được từ dữ liệu trạng thái tế bào để phục vụ bước tính toán tiếp theo @3.

Để kiểm soát luông thông tin vào ra bộ nhớ này nhằm giải quyết vấn đề tiêu biến đạo hàm, LSTM sử dụng ba cổng chính: cổng quên (forget gate), cổng đầu vào (input gate) và cổng đầu ra (output gate). Mỗi cổng này sử dụng hàm kích hoạt Sigmoid để tạo ra các giá trị từ 0 đến 1, đóng vai trò như một màng lọc thông tin. Cổng quên quyết định thông tin nào từ quá khứ cần loại bỏ khỏi trạng thái tế bào, cổng đầu vào xác định thông tin mới nào sẽ được thêm vào trạng thái tế bào, và cổng đầu ra điều chỉnh thông tin từ trạng thái tế bào để xuất ra trạng thái ẩn tại bước thời gian hiện tại @3.

=== Cách thức xử lý và học qua các bước thời gian

Tại mỗi bước thời gian $t$, tế bào LSTM sẽ nhận hai dữ liệu đầu vào: tín hiệu của bước hiện tại $x_t$ và trạng thái ẩn của bước ngay trước đó $h_"t-1"$. Để quyết định việc ghi nhớ hay học từ dữ liệu này, LSTM sử dụng cơ chế kiểm soát linh hoạt thông qua ba cổng, mỗi cổng sử dụng hàm kích hoạt Sigmoid xuất ra giá trị từ 0 đến 1 để đóng vai trò như một màng lọc, ba cổng bao gồm cổng quên, cổng đầu vào và cổng đầu ra:

- Cổng quên quyết định thông tin nào từ quá khứ đã trở nên lỗi thời và cần loại bỏ khỏi Trạng thái tế bào. Cổng quên phân tích $x_t$ và $h_"t-1"$ xem nếu loại bỏ hoàn toàn sẽ xuất ra các ma trận có giá trị là 0 và ngược lại nếu giữ lại toàn bộ là 1. Việc chủ động quên này rất quan trọng để ngăn bộ nhớ bị quá tải bởi các thông tin nhiễu không liên quan @3.

\
#figure(
  image("../figures/forget_gate.png", width: 70%),
  caption: [Cổng quên],
) <fig:forget_gate>
\

Đối với cổng quên, áp dụng hàm Sigmoid để tính toán giá trị quên $f_t$ dựa trên đầu vào hiện tại và trạng thái ẩn trước đó, được biểu diễn bằng công thức:

#text(size: 15pt)[
  $
    f_t = sigma(W_f dot [h_"t-1", x_t] + b_f)
  $
]

Với $W_f$ là ma trận trọng số của cổng quên, mô hình sẽ tự động tinh chỉnh qua quá trình huấn luyện để học được các đặc trưng quan trọng, còn $b_f$ là vector độ lệch giúp điều chỉnh ngưỡng kích hoạt của hàm Sigmoid. Thông qua hàm Sigmoid, các tham số này tạo ra một mặt nạ lọc có giá trị từ 0 đến 1 để đánh giá mức độ quan trọng của thông tin. Kết quả của cổng quên sẽ được nhân với trạng thái tế bào trước đó $C_"t-1"$ để loại bỏ có chọn lọc các thông tin không cần thiết. Nhờ việc chủ động quên đi các thông tin nhiễu, trạng thái tế bào không bị quá tải bởi các dữ liệu không liên quan. Điều này bảo vệ tính toàn vẹn của luồng thông tin và giúp mạng nơ-ron nắm bắt xuất sắc các phụ thuộc dài hạn trong chuỗi thời gian @3.


- Cổng đầu vào đóng vai trò quyết định xem sẽ có bao nhiêu thông tin mới từ tín hiệu đầu vào sẽ được phép ghi thêm vào trạng thái tế bào. Quá trình này diễn ra song song và kết hợp chặt chẽ với việc tạo ra các giá trị ứng viên mới, giúp mở rộng quy mô thông tin đảm bảo LSTM có thể thích ứng với dữ liệu một cách có kiểm soát.

Đầu tiên, cổng vào sẽ thực hiện đánh giá tín hiệu âm thanh của bước hiện tại $x_t$ và trạng thái ẩn trước đó $h_"t-1"$ thông qua hàm kích hoạt Sigmoid, hoạt động như một bộ lọc để xác định mức độ quan trọng của thông tin mới cần thêm vào bộ nhớ, với công thức:

#text(size: 15pt)[
  $
    i_t = sigma(W_i dot [h_"t-1", x_t] + b_i)
  $
]

Bộ lọc với hàm Sigmoid sẽ quyết định thông tin quan trọng nếu giá trị $i_t$ gần 1 và sẽ được thêm vào bộ nhớ, ngược lại nếu giá trị $i_t$ gần 0 thì thông tin sẽ bị loại bỏ. Trong đó, $W_i$ là ma trận trọng số của cổng đầu vào, được mô hình tự động tinh chỉnh trong quá trình huấn luyện để học được các đặc trưng quan trọng, còn $b_i$ là vector độ lệch giúp điều chỉnh ngưỡng kích hoạt của hàm Sigmoid. Nhờ cơ chế này, cổng đầu vào cho phép mô hình thu nạp linh hoạt các thông tin liên quan trong khi chủ động bỏ qua các tín hiệu nhiễu @3.

Như đã đề cập ở trên, song song với việc xác định thông tin quan trọng, cổng đầu vào còn tạo ra một vector chứa các giá trị ứng viên mới $tilde(C)_t$ từ dữ liệu đầu vào hiện tại và trạng thái ẩn trước đó thông qua một hàm Tanh với công thức:

#text(size: 15pt)[
  $
    tilde(C)_t = tanh(W_C dot [h_"t-1", x_t] + b_C)
  $
]

Hàm Hyperbolic Tangent, Tanh, giúp định cỡ các thông tin mới này về giá trị nằm trong khoảng [-1, 1], đảm bảo rằng các giá trị này có thể được thêm vào trạng thái tế bào một cách có kiểm soát, tránh làm việc biên độ dao động quá lớn hoặc quá nhỏ, làm mất ổn định quá trình học.

\
#figure(
  image("../figures/input_gate.png", width: 70%),
  caption: [Cổng đầu vào],
)
\

Sau khi có bộ lọc $i_t$ và thông tin ứng viên $tilde(C)_t$, mô hình sẽ nhân hai ma trận này từng phần tử với nhau để cập nhật trạng thái tế bào hiện tại $C_t$ bằng công thức $i_t dot tilde(C)_t$. Chỉ những phần thông tin ứng viên nào được công Sigmoid cho phép mới được thêm vào trạng thái tế bào, còn những thông tin không quan trọng sẽ bị loại bỏ.
#text(size: 15pt)[
  $
    C_t = f_t dot C_"t-1" + i_t dot tilde(C)_t
  $

]

Sau khi qua cổng đầu vào, các trạng thái tế bào cũ sẽ nhân với kết quả của cổng quên để xoá dữ liệu thừa. Sau đó nó sẽ được cộng thêm với lượng thông tin mới đã được chọn lọc từ cổng vào.

- Cổng đầu ra  đóng vai trò là chốt chặn cuối cùng trong một tế bào LSTM tại mỗi bước thời gian. Nếu Cổng quên và Cổng đầu vào làm nhiệm vụ quản lý bộ nhớ dài hạn là trạng thái tế bào - $C_t$, thì cổng đầu ra có nhiệm vụ quyết định xem phần thông tin nào từ bộ nhớ dài hạn đó sẽ được trích xuất ra ngoài để tạo thành bộ nhớ ngắn hạn là trạng thái ẩn - $h_t$. Trạng thái ẩn này chính là dữ liệu sẽ được truyền trực tiếp sang bước thời gian tiếp theo, hoặc đưa vào các lớp phân loại (Dense Layer) để dự đoán kết quả cuối cùng.

Đầu tiên, mô hình cần quyết định xem phần thông tin nào từ trạng thái tế bào hiện tại là quan trọng để xuất ra ngoài dựa trên ngữ cảnh. Cổng đầu ra sẽ thực hiện đánh giá tín hiệu âm thanh của bước hiện tại $x_t$ và trạng thái ẩn trước đó $h_"t-1"$ thông qua hàm kích hoạt Sigmoid, hoạt động như một bộ lọc để xác định mức độ quan trọng của thông tin cần xuất ra ngoài, với công thức:

#text(size: 15pt)[
  $
    o_t = sigma(W_o dot [h_"t-1", x_t] + b_o)
  $
]
Hàm Sigmoid sẽ tạo ra một vector $o_t$  chứa các giá trị từ 0 đến 1. Vector này hoạt động như một bộ lọc. Những giá trị tiến gần về 1 tương ứng với các đặc trưng quan trọng cần được lộ diện, trong khi các giá trị tiến về 0 sẽ che khuất những thông tin không cần thiết. $W_o$ và $b_o$  lần lượt là ma trận trọng số và vector độ lệch của cổng đầu ra, được mô hình tự động tinh chỉnh trong quá trình huấn luyện để học được các đặc trưng quan trọng.

Sau khi đã có bộ lọc $o_t$, mô hình sẽ trích xuất thông tin từ trạng thái tế bào hiện tại $C_t$, vốn đã được cập nhật từ cổng quên và cổng đầu vào, bằng cách đưa qua hàm Hyperbolic tangent để định cỡ các giá trị trong khoảng [-1, 1]. Kết quả này sau đó sẽ được nhân từng phần tử với bộ lọc $o_t$ để tạo ra trạng thái ẩn hiện tại $h_t$ bằng công thức:

#text(size: 15pt)[
  $
    h_t = o_t dot tanh(C_t)
  $
]

Nhờ vào hai phép toán trên, Cổng đầu ra đảm bảo rằng Trạng thái ẩn $h_t$ chỉ phản ánh những thông tin bám sát ngữ cảnh nhất từ bộ nhớ.Đối với dữ liệu âm thanh, mặc dù Trạng thái tế bào $C_t$ có thể đang lưu trữ rất nhiều bối cảnh của cả bài hát, Cổng đầu ra sẽ chỉ chọn lọc các đặc trưng thanh nhạc cốt lõi tại chính giây phút đó (ví dụ: cách nhả chữ, độ rung của thanh quản) để trích xuất ra ngoài. Việc ẩn đi các thông tin dư thừa giúp bộ phân loại ở các lớp cuối cùng không bị nhiễu và phục vụ trực tiếp cho việc dự đoán tên ca sĩ chính xác hơn ở bước tiếp theo @3.



== Gated Recurrent Units (GRU)
=== Tổng quan kiến trúc GRU
Mạng nơ-ron hồi quy có cổng (GRU - Gated Recurrent Unit) là một kiến trúc học sâu mạnh mẽ, được thiết kế chuyên biệt để xử lý và dự đoán các dữ liệu có tính chất chuỗi tuần tự theo thời gian. Mục tiêu cốt lõi của GRU là khắc phục hạn chế của các mạng nơ-ron hồi quy truyền thống bằng cách giải quyết triệt để vấn đề tiêu biến đạo hàm khi phải ghi nhớ thông tin từ các chuỗi dữ liệu dài @6 @13.

So với mô hình bộ nhớ ngắn hạn dài (Long Short-Term Memory), GRU sở hữu một cấu trúc tối giản và hiệu quả hơn rất nhiều khi gộp cổng đầu vào và cổng quên thành một cổng cập nhật (update gate) duy nhất, đồng thời sử dụng cổng thiết lập lại (reset gate) để kiểm soát lượng thông tin trong quá khứ cần giữ lại hay loại bỏ.

\
#figure(
  image("../figures/GRU_architect.png", width: 100%),
  caption: [Kiến trúc mô hình Gated Recurrent Units (GRU)],
)
\

- Cổng thiết lập lại sẽ kiểm soát mức độ thông tin từ quá khứ sẽ bị bỏ qua hoặc giữ lại khi xử lý dữ liệu đầu vào mới. Nhờ cơ chế này, trạng thái tế bào của GRU có thể được sửa đổi hoặc gạt bỏ sạch trí nhớ cũ nếu chúng không còn liên quan đến ngữ cảnh hiện tại. Công thức tính của cổng thiết lập lại được biểu diễn như sau:

#text(size: 15pt)[
  $
    r_t = sigma(W_"rh" dot h_"t-1" + W_"rx" dot x_t + b_r)
  $
]

Với $W_"rh"$ và $W_"rx"$ là ma trận trọng số của cổng thiết lập lại, được mô hình tự động tinh chỉnh trong quá trình huấn luyện để học được các đặc trưng quan trọng, còn $b_r$ là vector độ lệch giúp điều chỉnh ngưỡng kích hoạt của hàm Sigmoid. Thông qua hàm Sigmoid, các tham số này tạo ra một bộ lọc có giá trị từ 0 đến 1 để đánh giá mức độ quan trọng của thông tin. Kết quả của cổng thiết lập lại sẽ được nhân với trạng thái ẩn trước đó $h_"t-1"$ để loại bỏ có chọn lọc các thông tin không cần thiết.

- Trong khi đó, cổng cập nhật được tạo ra bằng cách gộp chung chức năng của cổng đầu vào và cổng quên từ mô hình LSTM thành một cổng duy nhất. Nhiệm vụ chính của cổng cập nhật là quyết định tỷ lệ pha trộn giữa lượng thông tin mới và bộ nhớ từ quá khứ để xác định trạng thái đầu ra cuối cùng tại bước thời gian hiện tại.
Công thức cổng cập nhật được biểu diễn như sau:

#text(size: 15pt)[
  $
    z_t = sigma(W_"zh" dot h_"t-1" + W_"zx" dot x_t + b_z)
  $
]

Tương tự như cổng thiết lập lại, hàm Sigmoid ($sigma$) sẽ đánh giá dữ liệu đầu vào $X_t$ và bộ nhớ $H_"t-1"$ thông qua các ma trận trọng số tương ứng $W_"zh"$,$W_"zx"$ và độ lệch $b_z$ để xuất ra một tỷ lệ nằm trong khoảng 1 hoặc 0 dùng cho bước chốt hạ cuối cùng.

- Bước tiếp theo, mô hình sẽ tính toán trạng thái ứng viên $hat(h)_t$ tạo ra một vector chứa lượng thông tin mới tiềm năng. Tại bước này, bộ lọc của cổng thiết lập lại sẽ được sử dụng bằng cách nhân trực tiếp với bộ nhớ cũ $h_"t-1"$ để lọc xem nên lấy bao nhiêu ngữ cảnh quá khứ để ghép với đặc trưng thông tin đầu vào hiện tại $x_t$. Công thức tính trạng thái ứng viên được biểu diễn như sau:

#text(size: 15pt)[
  $
    hat(h)_t = tanh(W_"ch" dot (r_t dot h_"t-1") + W_"cx" dot x_t + b_h)
  $
]

Hàm Hyperbolic Tangent, Tanh, giúp định cỡ các thông tin mới này về giá trị nằm trong khoảng [-1, 1], đảm bảo rằng các giá trị này có thể được thêm vào trạng thái ẩn một cách có kiểm soát, tránh làm việc biên độ dao động quá lớn hoặc quá nhỏ, làm mất ổn định quá trình học. Trong đó $W_"ch"$ và $W_"cx"$ là các ma trận trọng số được cập nhật trong quá trình huấn luyện, còn $b_h$ là vector độ lệch giúp điều chỉnh ngưỡng kích hoạt của hàm Tanh. Nhờ cơ chế này, trạng thái ứng viên $hat(h)_t$ sẽ chứa các đặc trưng quan trọng từ dữ liệu đầu vào hiện tại và thông tin ngữ cảnh từ quá khứ đã được lọc qua cổng thiết lập lại.

- Tại mỗi bước thời gian $t$, trạng thái ẩn của lớp Gated Recurrent Unit sẽ được tính toán dựa trên ba thành phần chính: trạng thái ứng viên mới $hat(h)_"t-1"$, hai cổng là cổng cập nhật $z_t$ và cổng thiết lập lại $r_t$. Cổng cập nhật sẽ quyết định tỷ lệ thông tin từ trạng thái ẩn trước đó và thông tin mới từ đầu vào hiện tại sẽ được giữ lại. Đây chính là bước chốt hạ để tạo ra trạng thái đầu ra của GRU tại bước thời gian $t$ (tương đương vớxi việc cập nhật Cell State ở LSTM).

Quá trình tính toán trạng thái ẩn mới $h_t$ trong GRU diễn ra theo công thức sau:

#text(size: 15pt)[
  $
    h_t = (1 - z_t) dot h_"t-1" + z_t dot hat(h)_t
  $
]

Toán tử $1 - z_t$ và $z_t$ sẽ xác định tỷ lệ thông tin từ trạng thái ẩn trước đó và trạng thái ứng viên mới sẽ được giữ lại. Nếu giá trị của cổng cập nhật $z_t$ tiến gần về 1, mô hình sẽ ưu tiên giữ lại thông tin mới từ trạng thái ứng viên $hat(h)_t$, trong khi nếu giá trị tiến gần về 0, mô hình sẽ giữ lại nhiều thông tin từ trạng thái ẩn trước đó $h_"t-1"$. Nhờ cơ chế này, GRU có khả năng nắm bắt các phụ thuộc dài hạn trong chuỗi dữ liệu mà không cần đến một bộ nhớ dài hạn riêng biệt như LSTM @17 @16.

\
#figure(
  image("../figures/GRU_state.png", width: 70%),
  caption: [Cổng cập nhật trong mô hình GRU],
)
\

Điểm khác biệt quan trọng của GRU so với LSTM là nhờ cổng thiết lập lại này, trạng thái của mạng có thể được sửa đổi hoàn toàn tại mỗi vòng lặp và cập nhật bằng các thông tin ngắn hạn mới, trong khi LSTM luôn có cơ chế giới hạn mức độ thay đổi @13.

Sự tinh gọn trong kiến trúc này giúp GRU nắm bắt xuất sắc cả các phụ thuộc ngắn hạn lẫn dài hạn trong chuỗi thời gian với ít tham số toán học hơn, từ đó đẩy nhanh tốc độ huấn luyện.


Để xử lý thành công lượng dữ liệu chuỗi thời gian khổng lồ, một cấu trúc GRU tiêu chuẩn thường đòi hỏi sự kết hợp chặt chẽ của nhiều lớp mạng. Ở bước đầu tiên, luồng dữ liệu thời gian bắt buộc phải đi qua một lớp chuẩn hóa để ép dải giá trị biên độ rộng về mức phân phối ổn định, giúp các hàm kích hoạt bên trong mạng không bị bão hòa. Tiếp theo, dữ liệu sẽ lần lượt đi qua các khối GRU xếp chồng lên nhau. Khối GRU thứ nhất làm nhiệm vụ trích xuất đặc trưng theo từng bước thời gian, trong khi khối GRU thứ hai chắt lọc thông tin và chỉ trả về trạng thái ẩn của bước thời gian cuối cùng để tóm gọn lại toàn bộ đặc trưng của chuỗi. Ở phần cuối kiến trúc, dữ liệu được truyền qua các lớp kết nối đầy đủ để phân loại kết quả, kết hợp cùng các lớp Dropout xen kẽ nhằm vô hiệu hóa ngẫu nhiên một số nơ-ron, ép mô hình phải khái quát hóa thay vì ghi nhớ cục bộ.

== Triển khai thực tế

=== Cách thức hoạt động chung của kiến trúc
Vì đầu vào là ma trận Mel-spectrogram có kích thước $300 times 300$ (300 bước thời gian, 300 đặc trưng Mel), đây là dữ liệu chuỗi thời gian nguyên bản. Cả GRU và LSTM đều được thiết kế để quét qua từng bước thời gian và cập nhật trạng thái ẩn nhằm ghi nhớ ngữ cảnh @3. Điểm đột phá trong cấu trúc của dự án là việc thiết lập mạng hai chiều. Thay vì chỉ đọc bài hát từ đầu đến cuối, mô hình sẽ quét song song theo hai hướng: từ quá khứ đến hiện tại và từ tương lai ngược về quá khứ. Điều này rất quan trọng vì cách một ca sĩ kết thúc một câu hát sẽ cung cấp manh mối để nhận dạng chính xác toàn bộ câu hát trước đó @13.

*Mô hình GRU:* Sử dụng hai cổng là Cổng thiết lập lại và Cổng cập nhật @6. Cổng thiết lập lại giúp mô hình quyết định quên đi bao nhiêu thông tin cũ, trong khi Cổng cập nhật quyết định tỷ lệ pha trộn giữa thông tin cũ và mới. Ưu điểm của GRU là ít tham số hơn LSTM, giúp huấn luyện nhanh hơn mà vẫn giữ được độ chính xác xuất sắc cho bài toán này.

*Mô hình LSTM:* Phức tạp hơn với ba cổng (Cổng quên, Cổng đầu vào, Cổng đầu ra) và một ô nhớ dài hạn riêng biệt. Cổng quên giúp mạng loại bỏ các thông tin nhiễu, cổng đầu vào chọn lọc các đặc trưng cốt lõi để lưu trữ, và cổng đầu ra quyết định việc trích xuất đặc trưng giọng hát để đưa vào bộ phân loại.


=== Các cơ chế hỗ trợ và chuẩn hóa
Để các kiến trúc GRU và LSTM hoạt động ổn định và không bị học vẹt, quá khớp, mô hình được trang bị một hệ thống các cơ chế hỗ trợ cực kỳ chặt chẽ:

*Cơ chế Chuẩn hóa (Layer Normalization):* Mô hình sử dụng Layer Normalization. Lớp này được đặt ở ngay đầu vào và sau bước Mean Pooling. Nó chuẩn hóa dữ liệu dựa trên giá trị trung bình và phương sai của 300 dải tần Mel trong chính một mẫu âm thanh duy nhất. Điều này không chỉ giúp ổn định biên độ khổng lồ của âm thanh mà còn đóng vai trò như một cơ chế điều chuẩn nhẹ ngăn chặn hiện tượng bùng nổ đạo hàm.

*Khối phân loại (Dense/Linear và ReLU):* Sau khi dữ liệu chuỗi được gộp lại thành một vector đặc trưng duy nhất, nó được đưa qua các lớp kết nối đầy đủ. Lớp đầu tiên nén dữ liệu xuống 128 chiều, sau đó áp dụng hàm kích hoạt phi tuyến ReLU. Hàm ReLU cho phép mô hình học được các ranh giới quyết định phức tạp giữa giọng của các ca sĩ khác nhau trước khi đưa ra dự đoán cuối cùng ở lớp Dense 10 chiều (đại diện cho 10 ca sĩ).

*Cơ chế chống quá khớp (Dropout & Weight Decay):* Với hàng trăm ngàn tham số, mạng rất dễ rơi vào tình trạng quá khớp. Mô hình giải quyết việc này bằng hai phương pháp chính:
- *Dropout*: Được chèn vào giữa các lớp mạng nơ-ron hồi quy, sau lớp chuẩn hóa và sau hàm ReLU. Trong quá trình huấn luyện, Dropout sẽ ngẫu nhiên vô hiệu hóa 25% số nơ-ron, ép mô hình không được phụ thuộc vào bất kỳ một nơ-ron cụ thể nào mà phải học các đặc trưng mang tính tổng quát của giọng hát.
- *Weight Decay* (L2 Regularization): Trừng phạt các trọng số có giá trị quá lớn, được tích hợp trực tiếp vào bộ tối ưu hóa. Đối với GRU, bộ tối ưu Adam được sử dụng, trong khi LSTM sử dụng AdamW vì nó có thể bóc tách việc giảm trọng số tốt hơn, giúp L2 Regularization hoạt động đúng bản chất. Cả hai đều sử dụng tốc độ học khởi tạo an toàn là $10^{-4}$.

*Cơ chế optimizer:* Bộ tối ưu là thành phần điều chỉnh bước cập nhật trọng số dựa trên đạo hàm của hàm mất mát. AdamW là một biến thể của gradient descent có bộ nhớ động: nó lưu trữ trung bình momen bậc nhất và moment bậc hai, từ đó tự động điều chỉnh tốc độ học cho từng tham số. Điều này giúp mạng hội tụ nhanh hơn và ổn định hơn với các dữ liệu chuỗi dài như Mel-spectrogram. AdamW cải tiến thêm một bước nữa bằng cách tách biệt hoàn toàn phần weight decay khỏi phép cập nhật moment, tránh làm sai lệch hướng tối ưu và cho phép giảm trọng số trở nên hiệu quả hơn khi kết hợp với các gradient động.

*Cơ chế tính toán sai số (CrossEntropyLoss):* Mô hình sử dụng hàm CrossEntropyLoss, là sự kết hợp của LogSoftmax và Negative Log-Likelihood trong cùng một bước. Hàm này chuyển đổi các giá trị thô ở lớp cuối cùng thành một phân phối xác suất. Nếu mô hình dự đoán sai với độ tự tin cao, hàm Loss sẽ sinh ra giá trị cực lớn, tạo ra một luồng đạo hàm mạnh mẽ để ép mạng cập nhật trọng số quyết liệt. Ngược lại, nếu dự đoán đúng, đạo hàm sẽ nhỏ lại để duy trì sự ổn định.



