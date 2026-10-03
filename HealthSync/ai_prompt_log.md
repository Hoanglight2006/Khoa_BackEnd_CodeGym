# Nhật ký tương tác AI (Prompt Log)

### Prompt 1: Lựa chọn kiểu dữ liệu tiền tệ
- **Câu hỏi:** "Khi lưu trữ deposit_amount và penalty_fee trong MySQL, nên dùng FLOAT, DOUBLE hay DECIMAL? Tại sao?"
- **Mục tiêu:** Tìm hiểu về sai số làm tròn số thực (floating-point precision error) trong các hệ thống tính toán tài chính.
- **Kết quả áp dụng:** Sử dụng `DECIMAL(12, 2)` để đảm bảo độ chính xác tuyệt đối, tránh thất thoát hay lệch số liệu khi kế toán thực hiện cộng trừ, đối soát.

### Prompt 2: Biểu diễn vòng đời trạng thái bằng ENUM
- **Câu hỏi:** "Ưu và nhược điểm của việc dùng ENUM so với VARCHAR khi quản lý chuỗi trạng thái (PENDING, CONFIRMED, CHECKED_IN, COMPLETED, CANCELLED) trong MySQL là gì?"
- **Mục tiêu:** Đánh giá tính chất ràng buộc dữ liệu ở cấp độ hệ quản trị CSDL.
- **Kết quả áp dụng:** Dùng `ENUM` giúp giới hạn chính xác tập giá trị hợp lệ ngay từ tầng CSDL, tiết kiệm dung lượng lưu trữ và ngăn chặn việc chèn chuỗi sai lệch từ tầng backend.

### Prompt 3: Chặn hành vi kê đơn khi chưa khám xong ở tầng CSDL
- **Câu hỏi:** "Làm thế nào để chặn việc chèn đơn thuốc (INSERT vào Prescriptions) nếu appointment_id tương ứng chưa có trạng thái COMPLETED?"
- **Mục tiêu:** Tìm giải pháp bảo vệ tính toàn vẹn dữ liệu mà khóa ngoại thông thường không kiểm soát được giá trị cột.
- **Kết quả áp dụng:** Sử dụng `BEFORE INSERT TRIGGER` trên bảng `Prescriptions` để kiểm tra cột `status` của `Appointments`, nếu khác 'COMPLETED' thì dùng `SIGNAL SQLSTATE` để ném lỗi ngăn giao dịch.

### Prompt 4: Thiết kế quan hệ và ràng buộc giữa Appointments và Prescriptions
- **Câu hỏi:** "Quan hệ giữa lịch hẹn và đơn thuốc nên để 1-1 hay 1-n, và nên chọn ON DELETE RESTRICT hay CASCADE?"
- **Mục tiêu:** Xác định cardinality và quy tắc ràng buộc toàn vẹn khi xóa lịch hẹn.
- **Kết quả áp dụng:** Đặt cột `appointment_id` trong `Prescriptions` là `UNIQUE` để thể hiện quan hệ 1-1 cho mỗi lần khám hoàn tất, đồng thời dùng `RESTRICT` để không xóa nhầm dữ liệu lịch hẹn đã có hồ sơ đơn thuốc đi kèm.
