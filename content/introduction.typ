#import "/utils/todo.typ": TODO

=  TỔNG QUAN  ĐỀ  TÀI

== Giới thiệu bài toán
Hiện nay việc chụp ảnh và quay video trở thành một phần không thể thiếu trong cuộc sống hàng ngày của con người. Thay cho camera kỹ thuật số truyền thống, điện thoại thông minh với khả năng chụp ảnh và quay video với chất lượng cao đã trở thành thiết bị phổ biến và quen thuộc hơn với người dùng. Cùng với sự phát triển của mạng xã hội và các nền tảng chia sẻ hình ảnh như Facebook, Instagram,... nhu cầu chụp ảnh của con người ngày càng tăng cao. Để có được những bức ảnh đẹp tự nhiên hòa với phong cảnh, chúng ta luôn cần phải có một người hỗ trợ cầm máy ảnh để giúp chúng ta căn góc và bấm nút chụp hoặc quay video. Hoặc trong trường hợp chúng ta muốn chụp ảnh nhóm, chúng ta không muốn phải nhờ người lạ chụp hộ hoặc không thể nhờ được ai mà vẫn muốn có những bức ảnh đầy đủ, đẹp với bố cục hài hòa. Chính vì vậy, việc phát triển một hệ thống hỗ trợ người dùng trong việc chụp ảnh và quay video thông qua các thiết bị di động là rất cần thiết và hữu ích. 


== Mục tiêu của đề tài
Đề tài này nhằm mục đích triển khai một hệ thống điều khiển camera từ xa thông qua các thiết bị di động, giúp người dùng có thể dễ dàng chụp ảnh và quay video mà không cần phải trực tiếp cầm thiết bị camera.

- Áp dụng kết nối TCP socket server cho việc sử dụng các điện thoại di động khác kết nối và điều khiển máy đích.

== Phạm vi nghiên cứu của đề tài
=== Phạm vi dữ liệu và ngôn ngữ
Ngôn ngữ nghiên cứu: Văn bản tiếng Việt, với đặc điểm ngữ pháp đơn lập và biểu hiện cảm xúc phong phú, ngầm định.

Nguồn dữ liệu: Chủ yếu sử dụng tập dữ liệu UIT-VSMEC gồm 6.927 câu, gán nhãn theo 7 lớp cảm xúc (vui vẻ, buồn bã, tức giận, sợ hãi, ngạc nhiên, ghê tởm, và khác).

Bổ sung dữ liệu: Có thể mở rộng sang các tập khác như UIT-VSFC hoặc các corpus cảm xúc công khai khác.

=== Yêu cầu về kiến trúc và triển khai
- Sử dụng ngôn ngữ Kotlin để phát triển ứng dụng di động trên nền tảng Android.

- Thiết kế giao diện người dùng thân thiện, dễ sử dụng.

- Tích hợp các chức năng điều khiển camera từ xa như chụp ảnh, quay video, thay đổi chế độ chụp.

== Kết luận chương
Chương này đã trình bày tổng quan về bối cảnh, mục tiêu, và phạm vi nghiên cứu của đề tài "Hệ thống điều khiển camera từ xa trên thiết bị di động". Trong các chương tiếp theo, chúng ta sẽ đi sâu vào các khía cạnh kỹ thuật và triển khai cụ thể của hệ thống này.
