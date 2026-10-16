# Chiến Lược Bố Cục: CSS Grid & Flexbox

CSS Grid là hệ thống bố cục 2 chiều (2D), kiểm soát đồng thời cả hàng và cột từ khung bao ngoài (Layout-first). Do đó, Grid là lựa chọn tối ưu để định hình khung xương tổng thể trang web và các bố cục dashboard bất đối xứng (như Bento Box) với cấu trúc DOM phẳng.

Ngược lại, Flexbox là hệ thống dàn trang 1 chiều (1D), tự động co giãn linh hoạt theo kích thước thực tế của nội dung (Content-first). Điều này khiến Flexbox lý tưởng cho các component chi tiết (như thanh Navbar co giãn theo độ dài chữ, nhóm nút bấm, hay căn giữa biểu tượng và văn bản bên trong thẻ).

Quy tắc kiến trúc chuẩn: Sử dụng CSS Grid để dựng khung layout tổng quan 2D, và ứng dụng Flexbox để điều hướng, căn chỉnh các thành phần con 1D bên trong.
