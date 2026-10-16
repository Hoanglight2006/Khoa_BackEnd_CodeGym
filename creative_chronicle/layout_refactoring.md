# Phân Tích Kiến Trúc: Tác Hại Của Absolute Positioning & Giải Pháp CSS Grid

Trong thiết kế đáp ứng (Responsive Design), lạm dụng `position: absolute` cho bố cục là một sai lầm nghiêm trọng. Thuộc tính này nhổ bật phần tử ra khỏi luồng tài liệu tự nhiên (Document Flow), khiến thẻ cha bị rút cạn chiều cao (Height Collapse). Để chống chế, người cũ đã gán chiều cao cứng (`height: 400px`). Khi xem trên thiết bị di động, các phần tử con không thể co giãn tương ứng, dẫn tới hiện tượng đè nát nội dung văn bản bên dưới.

CSS Grid chính là giải pháp cứu cánh hoàn hảo: vừa bảo toàn dòng chảy tài liệu, vừa kiểm soát đồng thời 2 chiều (2D). Thông qua `grid-template-columns: 2fr 1fr` và `grid-row: span 2`, các ô ảnh khảm tự động co giãn linh hoạt mà không cần fix cứng pixel, giải quyết triệt để lỗi tràn vỡ giao diện.
