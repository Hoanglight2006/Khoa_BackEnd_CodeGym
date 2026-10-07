# Báo cáo đối chiếu nghiệp vụ và thiết kế CSDL HealthSync

Qua đối chiếu giữa Activity Diagram của BA và cấu trúc CSDL ban đầu (Legacy DB), em nhận thấy 3 điểm vênh nghiêm trọng sau:

1. **Sai lệch mô hình trạng thái cuộc hẹn:** Hệ thống cũ dùng cột `is_active` kiểu BOOLEAN chỉ biểu diễn được 2 trạng thái (đúng và sai). Trong khi thực tế quy trình trải qua 5 trạng thái liên tiếp: PENDING, CONFIRMED, CHECKED_IN, COMPLETED và CANCELLED. Việc này khiến hệ thống không thể theo dõi tiến trình khám của bệnh nhân.

2. **Thiếu hụt dữ liệu về tài chính và hủy hẹn:** Nghiệp vụ quy định bệnh nhân phải đặt cọc khi tạo lịch và bị phạt cọc nếu hủy sau khi đã xác nhận. Bản thiết kế cũ hoàn toàn không có các cột `deposit_amount`, `penalty_fee` và `cancel_reason`. Do đó hệ thống không thể ghi nhận dòng tiền, không tính được tiền phạt và không có lý do hủy để đối soát doanh thu.

3. **Thiếu hoàn toàn thực thể Đơn thuốc:** Sau khi khám xong, bác sĩ phải kê đơn thuốc đi kèm lịch hẹn. CSDL cũ không có bảng `Prescriptions` hay bất kỳ liên kết nào để lưu đơn thuốc, làm đứt gãy giai đoạn cuối của toàn bộ quy trình khám chữa bệnh.
