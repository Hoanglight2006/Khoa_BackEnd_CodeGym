# Báo Cáo Phân Tích: Lựa Chọn COUNT(o.order_id) Thay Vì COUNT(*)

Trong phép `LEFT JOIN`, tất cả bản ghi từ bảng gốc `Customers` đều được giữ lại. Với khách hàng chưa từng mua hàng (như Charlie), các cột tương ứng từ bảng `Orders` sẽ nhận giá trị `NULL`.

- `COUNT(*)` đếm tổng số dòng vật lý được tạo ra sau kết nối, bất kể dòng đó có chứa giá trị `NULL` hay không. Do đó, Charlie dù không có đơn hàng vẫn tạo ra 1 dòng trống và bị tính sai lệch thành `total_orders = 1`.
- `COUNT(o.order_id)` chỉ đếm các giá trị khác `NULL` trên cột khóa chính `order_id` của bảng `Orders`. Khi Charlie không có đơn hàng (`order_id IS NULL`), hàm tự động bỏ qua và trả về chính xác `0`.

Vì vậy, bắt buộc sử dụng `COUNT(o.order_id)` để đảm bảo số liệu trung thực cho chiến dịch Marketing.
