# 🏝️ DynamicIsland Tweak (iOS 12.5.8 - iPhone 5s)

Tweak mô phỏng **Dynamic Island** chân thực dành riêng cho **iPhone 5s** (chip Apple A7, iOS 12.5.8, jailbreak Chimera/Electra).

---

## ✨ Tính Năng Nổi Bật

1. **Giao diện Pill nhỏ (Compact State)**:
   - Nằm chính giữa trên cùng màn hình (kích thước chuẩn 112×30 pt cho màn hình 320pt của 5s).
   - Bo tròn mượt mà, bóng đổ nhẹ tinh tế.
   - Touch passthrough: không chặn cảm ứng ở 2 bên thanh trạng thái.

2. **Mở rộng linh hoạt (Expanded State)**:
   - **Thông báo (Notifications)**: Bắt trọn thông báo từ hệ thống, hiện icon app gốc, tên app, tiêu đề và nội dung. Giữ nguyên banner gốc theo yêu cầu của bạn.
   - **Âm nhạc (Now Playing)**: Tương thích cả Apple Music, Spotify, YouTube, SoundCloud... Hiển thị ảnh bìa album (artwork), tên bài hát, ca sĩ và thanh tiến trình.
   - **Cuộc gọi (Call UI)**: Chấm xanh nhấp nháy, hiển thị người gọi, thời lượng cuộc gọi tính bằng giây.
   - **Tương tác**: Chạm vào Island khi đang phát nhạc hoặc có thông báo sẽ tự động mở ứng dụng tương ứng! Chạm vào vùng trống sẽ thu gọn về pill nhỏ.

3. **Bảng Cài Đặt (Settings Panel)**:
   - Tích hợp trực tiếp vào ứng dụng **Cài Đặt (Settings)** của iOS thông qua PreferenceLoader.
   - Bật / tắt riêng từng tính năng: Thông báo, Âm nhạc, Cuộc gọi, Rung (Haptic Feedback).
   - Áp dụng thay đổi tức thì qua Darwin Notification Center.
   - Nút Respring tích hợp sẵn.

4. **An Toàn Tuyệt Đối**:
   - Toàn bộ hook được bảo vệ bằng khối `@try / @catch`.
   - Lọc quy trình `com.apple.springboard` trong plist để không inject bừa bãi vào các app khác.
   - Hỗ trợ đầy đủ Substrate / Substitute Safe Mode (giữ Volume Up khi mở máy để vô hiệu hóa tweak nếu cần).

---

## 📁 Cấu Trúc Dự Án

```
DynamicIsland/
├── .github/workflows/build.yml     # Workflow tự động build .deb trên GitHub Actions (macOS)
├── Makefile                        # Cấu hình Theos cho arm64, target iOS 12.0
├── control                         # Thông tin gói cài đặt .deb
├── DynamicIsland.plist             # Bộ lọc chỉ inject vào SpringBoard
├── Tweak.xm                        # Hook SpringBoard, Banners, Media, Calls, LockScreen
├── layout/
│   ├── DEBIAN/
│   │   ├── control                 # Metadata dpkg
│   │   └── postinst                # Script tự động respring an toàn sau khi cài
│   └── Library/PreferenceLoader/Preferences/
│       └── DynamicIsland.plist     # Đăng ký hiển thị trong Settings của iOS
├── PreferenceBundle/               # Giao diện menu cài đặt trong Settings
│   ├── DynamicIslandPrefsController.h
│   ├── DynamicIslandPrefsController.m
│   └── Resources/
│       ├── Info.plist
│       └── Root.plist
└── src/                            # Mã nguồn Objective-C
    ├── DIActivityManager.h/.m      # Quản lý trạng thái và hàng đợi sự kiện
    ├── DIAnimator.h/.m             # Hiệu ứng lò xo (Spring) và chuyển cảnh
    ├── DICallProvider.h/.m         # Lắng nghe trạng thái cuộc gọi (TUCallCenter + CTCallCenter)
    ├── DICompactView.h/.m          # Giao diện pill nhỏ gọn
    ├── DIExpandedView.h/.m         # Giao diện mở rộng (Notif / Music / Call)
    ├── DIMusicProvider.h/.m        # Lắng nghe âm nhạc từ MediaRemote & MPMusicPlayer
    ├── DINotificationProvider.h/.m # Lắng nghe thông báo (NCNotificationRequest & BBBulletin)
    ├── DIPreferencesManager.h/.m   # Quản lý thiết lập & lắng nghe Darwin notifications
    ├── DIWindowController.h/.m     # Quản lý UIWindow trên cùng với touch passthrough
    └── DynamicIslandView.h/.m      # Container chính của Dynamic Island
```

---

## 🚀 Hướng Dẫn Tải & Cài Đặt (Không Cần Máy Mac)

### Bước 1: Đưa Code Lên GitHub
1. Vào [github.com](https://github.com) tạo một repository mới (đặt tên ví dụ: `DynamicIsland`), chọn **Public**.
2. Tải toàn bộ thư mục `DynamicIsland` này lên repository (bằng cách kéo thả trực tiếp trên trang web GitHub hoặc dùng [GitHub Desktop](https://desktop.github.com/)).

### Bước 2: Nhận File `.deb` Tự Động
1. Sau khi upload, mở tab **Actions** trên GitHub.
2. Bạn sẽ thấy quy trình **Build DynamicIsland Tweak** tự động chạy trên máy chủ macOS của GitHub.
3. Khi hoàn thành (hiện dấu tích xanh ✅), bấm vào bản build và cuộn xuống mục **Artifacts** để tải file zip chứa `.deb` về máy tính.

### Bước 3: Cài Vào iPhone 5s Qua Sileo
1. Giải nén file zip lấy file `com.dev.dynamicisland_1.0.0_iphoneos-arm.deb`.
2. Chuyển file `.deb` vào iPhone (bằng **iFunBox**, **3uTools**, hoặc gửi qua AirDrop/Telegram/Zalo mở bằng **Filza**).
3. Trong **Filza**: Chạm vào file `.deb` → Chọn **Cài đặt (Install)**.
   *(Hoặc trong **Sileo**: Mở tab Tìm kiếm, chọn biểu tượng cài file .deb nội bộ)*.
4. Máy sẽ tự động respring và bạn sẽ thấy Dynamic Island xuất hiện ngay lập tức!
