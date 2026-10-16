// ==========================================================================
// TƯƠNG TÁC CHUYỂN ĐỔI VIDEO VÀ TÌM KIẾM CHO TRANG WEB PHIM HOẠT HÌNH
// ==========================================================================

document.addEventListener('DOMContentLoaded', () => {
    const playlistItems = document.querySelectorAll('.playlist-item');
    const html5PlayerBox = document.getElementById('html5PlayerBox');
    const youtubePlayerBox = document.getElementById('youtubePlayerBox');
    const mainVideoPlayer = document.getElementById('mainVideoPlayer');
    const mainYoutubeIframe = document.getElementById('mainYoutubeIframe');

    const videoTitle = document.getElementById('videoTitle');
    const videoViews = document.getElementById('videoViews');
    const videoDesc = document.getElementById('videoDesc');
    const searchInput = document.getElementById('searchInput');

    // 1. Xử lý khi click chọn video trong menu Left Content
    playlistItems.forEach(item => {
        item.addEventListener('click', () => {
            // Cập nhật class active
            playlistItems.forEach(i => i.classList.remove('active'));
            item.classList.add('active');

            const type = item.getAttribute('data-type');
            const src = item.getAttribute('data-src');
            const poster = item.getAttribute('data-poster');
            const title = item.getAttribute('data-title');
            const views = item.getAttribute('data-views');
            const desc = item.getAttribute('data-desc');

            // Cập nhật thông tin chi tiết phim
            if (videoTitle) videoTitle.textContent = title;
            if (videoViews) videoViews.textContent = `👁️ ${views}`;
            if (videoDesc) videoDesc.textContent = desc;

            // Xử lý chuyển đổi giữa thẻ <video> và <iframe> YouTube
            if (type === 'html5') {
                // Tắt YouTube iframe
                if (mainYoutubeIframe) mainYoutubeIframe.src = '';
                if (youtubePlayerBox) youtubePlayerBox.style.display = 'none';

                // Kích hoạt HTML5 Video
                if (html5PlayerBox) html5PlayerBox.style.display = 'block';
                if (mainVideoPlayer) {
                    mainVideoPlayer.poster = poster || '';
                    mainVideoPlayer.src = src;
                    mainVideoPlayer.load();
                    mainVideoPlayer.play().catch(() => {
                        // Tránh chặn autoplay của trình duyệt
                    });
                }
            } else if (type === 'youtube') {
                // Tạm dừng video HTML5
                if (mainVideoPlayer) {
                    mainVideoPlayer.pause();
                }
                if (html5PlayerBox) html5PlayerBox.style.display = 'none';

                // Kích hoạt YouTube iframe
                if (youtubePlayerBox) youtubePlayerBox.style.display = 'block';
                if (mainYoutubeIframe) {
                    mainYoutubeIframe.src = src;
                }
            }

            // Tự động cuộn mượt lên khung phát video khi ở trên điện thoại
            if (window.innerWidth <= 1024) {
                window.scrollTo({
                    top: 0,
                    behavior: 'smooth'
                });
            }
        });
    });

    // 2. Chức năng tìm kiếm phim hoạt hình theo tên trong danh sách
    if (searchInput) {
        searchInput.addEventListener('input', (e) => {
            const keyword = e.target.value.toLowerCase().trim();
            playlistItems.forEach(item => {
                const titleText = item.querySelector('.item-title')?.textContent.toLowerCase() || '';
                if (titleText.includes(keyword)) {
                    item.style.display = 'flex';
                } else {
                    item.style.display = 'none';
                }
            });
        });
    }
});
