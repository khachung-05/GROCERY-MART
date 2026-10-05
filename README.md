# Hệ thống Quản lý Vận hành Siêu thị Thực phẩm (Grocery Mart)

Hệ thống hỗ trợ vận hành một siêu thị và chuỗi bán lẻ thực phẩm từ danh mục hàng hóa, kiểm kê tồn kho, xử lý đơn bán tại chỗ đến tiếp nhận và điều phối đơn mua sắm trực tuyến. Mục tiêu của hệ thống là đưa các hoạt động kinh doanh hằng ngày về một **luồng dữ liệu tập trung (Single Source of Truth)**, giúp người quản lý theo dõi sát sao vòng đời hàng hóa, trạng thái đơn hàng, doanh thu thực tế và hiệu suất vận hành theo thời gian thực.

> **Lưu ý:** Tài liệu README này phản ánh phạm vi nghiệp vụ và chức năng hiện hữu trong mã nguồn của hệ thống. Đây là tài liệu tổng quan phục vụ kỹ thuật và quy trình vận hành, không thay thế hệ thống kế toán tài chính chuyên sâu, chuẩn mực hóa đơn điện tử hoặc quy chế nội bộ của một doanh nghiệp cụ thể.

---

## 1. Bài toán nghiệp vụ

Trong mô hình kinh doanh siêu thị và thực phẩm tươi sống, các khó khăn phổ biến bao gồm:
* Hàng hóa, giá niêm yết và số lượng tồn kho bị phân mảnh giữa quầy bán lẻ và kênh online.
* Đơn hàng trực tuyến phát sinh cần được điều phối nhanh chóng (xác nhận, đóng gói, giao hàng) để đảm bảo độ tươi của thực phẩm.
* Khó kiểm soát chênh lệch doanh thu giữa các kênh thanh toán (tiền mặt COD, chuyển khoản, thẻ).
* Thiếu số liệu tổng hợp trực quan để đánh giá mặt hàng bán chạy, xu hướng tiêu dùng và hiệu quả vận hành hằng ngày.

**Hệ thống tập trung giải quyết các nhu cầu cốt lõi:**
1. Duy trì **một danh mục sản phẩm duy nhất** (tên, giá bán, hình ảnh, đơn vị tính, số lượng tồn kho) dùng chung cho toàn bộ hoạt động bán hàng và quản trị.
2. Quản lý **trọn vẹn vòng đời đơn hàng**, đặc biệt là đơn trực tuyến từ lúc khách đặt, xác nhận đóng gói, vận chuyển đến khi hoàn tất hoặc hủy.
3. Cung cấp nền tảng **tự phục vụ (Self-service) cho khách hàng**: Tìm kiếm, giỏ hàng, áp mã giảm giá, đặt hàng, theo dõi lộ trình đơn và tương tác với Trợ lý AI.
4. Cung cấp **Bảng điều hành quản trị (Admin Console)**: Theo dõi doanh thu theo thời gian thực, biểu đồ xu hướng 7 ngày, quản lý danh mục và điều phối đơn hàng.

---

## 2. Phạm vi chức năng hiện tại

| Phân hệ | Nghiệp vụ được hỗ trợ |
| :--- | :--- |
| **Danh mục hàng hóa** | Quản lý danh mục (Trái cây, Rau củ, Thịt trứng, Hải sản...), thêm/sửa/xóa sản phẩm, cập nhật giá bán, hình ảnh, đơn vị tính (`kg`, `hộp`, `gói`) và số lượng tồn. |
| **Bán hàng trực tuyến** | Giỏ hàng thời gian thực, kiểm tra số lượng, áp dụng voucher khuyến mãi, checkout địa chỉ nhận hàng, chọn phương thức thanh toán (COD / Chuyển khoản). |
| **Xử lý đơn hàng** | Tiếp nhận đơn mới, theo dõi trạng thái đơn hàng: *Chờ xác nhận*, *Chuẩn bị*, *Đang giao*, *Đã giao*, *Đã hủy*; xem chi tiết danh sách món hàng trong đơn. |
| **Tài khoản & Phân quyền** | Đăng ký tài khoản, đăng nhập phân quyền theo vai trò (`customer` vs `admin`), lưu phiên làm việc an toàn (`LocalStorage`), cập nhật thông tin cá nhân. |
| **Báo cáo & Điều hành** | Dashboard thống kê doanh thu (Hôm nay, Tuần này, Tháng này, Toàn thời gian), số lượng đơn phát sinh, giá trị đơn trung bình (AOV), tổng sản lượng bán ra, biểu đồ xu hướng 7 ngày tính từ dữ liệu thật. |
| **Trợ lý AI & Thông báo** | Chatbot AI thông minh tư vấn thực đơn, gợi ý sản phẩm phù hợp; hệ thống thông báo trạng thái đơn hàng và chương trình ưu đãi. |

---

## 3. Vai trò và trách nhiệm

Hệ thống phân định quyền hạn theo tài khoản được xác thực từ cơ sở dữ liệu backend, đảm bảo tính an toàn dữ liệu:

| Vai trò (Role) | Trách nhiệm vận hành chính |
| :--- | :--- |
| **Quản trị viên (`admin`)** | Quản lý toàn bộ danh mục và sản phẩm; xem thống kê doanh thu và báo cáo điều hành; tiếp nhận và đổi trạng thái xử lý đơn hàng; quản lý danh sách khách hàng và chính sách khuyến mãi. |
| **Khách hàng (`customer`)** | Đăng ký/đăng nhập tài khoản; tìm kiếm và xem chi tiết sản phẩm; quản lý giỏ hàng; áp dụng voucher; đặt hàng; theo dõi trạng thái đơn hàng của tôi; tương tác cùng Trợ lý AI. |
| **Khách vãng lai (`guest`)** | Xem danh mục sản phẩm, tìm kiếm món ăn; trải nghiệm giỏ hàng và được điều hướng đăng nhập khi thực hiện thanh toán/theo dõi đơn. |

---

## 4. Các đối tượng nghiệp vụ cốt lõi

| Đối tượng | Ý nghĩa trong vận hành | Bảng cơ sở dữ liệu |
| :--- | :--- | :--- |
| **Tài khoản người dùng** | Đại diện cho khách hàng hoặc nhà quản trị, chứa định danh, email, số điện thoại, mật khẩu và vai trò (`role`). | `users` |
| **Danh mục hàng hóa** | Nhóm phân loại thực phẩm để khách hàng dễ dàng tìm kiếm và quản lý kho phân chia khu vực. | `categories` |
| **Sản phẩm** | Thông tin mặt hàng đang kinh doanh: tên, giá niêm yết, đơn vị tính, mô tả, ảnh minh họa và tồn kho. | `products` |
| **Đơn hàng (Order)** | Cam kết giao dịch mua sắm giữa khách hàng và siêu thị, bao gồm người nhận, địa chỉ, tổng tiền, phí ship, trạng thái và ngày đặt. | `orders` |
| **Dòng đơn hàng (Order Items)** | Danh sách chi tiết các sản phẩm, số lượng, đơn giá tại thời điểm đặt thuộc về một mã đơn hàng. | `order_items` |
| **Thông báo** | Bản ghi thông tin cập nhật biến động trạng thái đơn hàng hoặc tin tức khuyến mãi gửi tới người dùng. | `notifications` |

---

## 5. Luồng vận hành chính

```
[ Khách hàng ]                 [ Node.js API ]               [ Quản trị viên ]
      │                                │                               │
      ├──── 1. Xem & Đặt hàng ────────>│                               │
      │    (POST /api/orders)          ├──── 2. Lưu vào MySQL ─────────┤
      │                                │    (Status: 'Chờ xác nhận')   │
      │                                │                               │
      │                                │<─── 3. Xem đơn mới & duyệt ───┤
      │                                │    (PUT /api/orders/:id)      │
      │                                │                               │
      │<─── 4. Cập nhật lộ trình ──────┤                               │
      │    ('Đang giao' -> 'Đã giao')  │                               │
```

### 5.1. Chuẩn bị hàng hóa & Danh mục
1. Quản trị viên đăng nhập vào hệ thống với tài khoản quyền `admin`.
2. Truy cập màn hình **Sản Phẩm & Kho Hàng**, thiết lập danh mục và bổ sung sản phẩm mới (tên sản phẩm, đơn giá, đơn vị tính, hình ảnh).
3. Thông tin sản phẩm được đồng bộ vào database và sẵn sàng hiển thị trên giao diện của khách hàng.

### 5.2. Mua sắm & Đặt hàng trực tuyến
1. Khách hàng lựa chọn sản phẩm, tùy chỉnh số lượng trong giỏ hàng.
2. Tại màn hình **Thanh toán (Checkout)**, khách hàng điền tên người nhận, số điện thoại, địa chỉ giao nhận, chọn phương thức thanh toán và nhập ghi chú.
3. Khi bấm **Xác nhận đặt hàng**, ứng dụng gửi yêu cầu `POST /api/orders` lên Backend.
4. Hệ thống tạo mã đơn hàng duy nhất (`ORD_...`), lưu bản ghi vào bảng `orders` và chi tiết từng món vào `order_items` ở trạng thái ban đầu là **`Chờ xác nhận`**.
5. Giỏ hàng cục bộ được làm sạch, khách hàng chuyển đến màn hình xác nhận đơn hàng thành công.

### 5.3. Xử lý & Điều phối đơn hàng (Phía Quản trị)
1. Đơn hàng mới lập tức xuất hiện trên **Báo cáo & Thống kê** và danh sách **Đơn Hàng & Vận Chuyển** của Admin.
2. Quản trị viên bấm xem chi tiết đơn hàng, kiểm tra địa chỉ và danh sách món cần chuẩn bị.
3. Quản trị viên thực hiện cập nhật trạng thái đơn hàng theo quy trình:
   * **Chờ xác nhận** $\rightarrow$ **Chuẩn bị / Đang đóng gói** $\rightarrow$ **Đang giao** $\rightarrow$ **Đã giao (Hoàn tất)**.
4. Mọi thay đổi trạng thái đều được cập nhật tức thời để khách hàng theo dõi trong mục **Đơn hàng của tôi**.

---

## 6. Nguyên tắc vận hành dữ liệu

* **Một nguồn dữ liệu thống nhất (Single Source of Truth):** Toàn bộ người dùng, sản phẩm, đơn hàng được quản lý tập trung trên cơ sở dữ liệu MySQL (`grocery_db`).
* **Tính toàn vẹn của đơn hàng:** Khi đơn hàng đã đặt, thông tin giá và tên sản phẩm trong `order_items` được lưu cố định tại thời điểm mua, không bị biến động nếu giá sản phẩm trong danh mục thay đổi sau này.
* **Định dạng thời gian chuẩn xác:** Dữ liệu thời gian được xử lý theo múi giờ địa phương Việt Nam (**UTC+7** / `Asia/Ho_Chi_Minh`), đảm bảo thống kê báo cáo và lịch sử đặt hàng chuẩn xác từng phút.
* **Phân định trạng thái rõ ràng:** Đơn hàng tuân thủ quy trình trạng thái nghiêm ngặt (`Chờ xác nhận`, `Chuẩn bị`, `Đang giao`, `Đã giao`, `Đã hủy`).
* **Bảo mật biến môi trường:** Các thông tin nhạy cảm về cơ sở dữ liệu, cổng kết nối và khóa bí mật được lưu tách biệt, không lưu trực tiếp vào mã nguồn công khai.

---

## 7. Báo cáo hỗ trợ điều hành

Bảng điều khiển **Admin Dashboard** cung cấp góc nhìn toàn diện phục vụ quản lý:
* **Doanh thu theo chu kỳ:** Tự động lọc và tổng hợp doanh thu theo Hôm nay, Tuần này, Tháng này và Toàn thời gian.
* **Chỉ số kinh doanh cốt lõi (KPIs):**
  * **Tổng doanh thu thuần:** Doanh thu thực tế sau khi trừ các đơn hủy.
  * **Số lượng đơn phát sinh:** Tổng số đơn đặt trong chu kỳ được chọn.
  * **AOV (Average Order Value):** Giá trị trung bình trên mỗi đơn hàng.
  * **Sản phẩm bán ra:** Tổng sản lượng các món hàng đã tiêu thụ.
* **Biểu đồ xu hướng 7 ngày gần nhất:** Biểu đồ cột trực quan, tính toán tự động từ cơ sở dữ liệu đơn hàng theo từng ngày trong tuần (Thứ 2 $\rightarrow$ Chủ Nhật).

---

## 8. Giới hạn hiện tại và lưu ý trước khi triển khai

* **Mã hóa mật khẩu:** Mật khẩu trong phiên bản hiện tại đang được lưu trữ trực tiếp; khi đưa vào môi trường sản xuất (Production), cần tích hợp thư viện băm mật khẩu như `bcryptjs`.
* **Cổng thanh toán trực tuyến:** Hệ thống hiện hỗ trợ phương thức COD (tiền mặt khi nhận) và xác nhận đơn chuyển khoản. Việc tích hợp các cổng thanh toán tự động (VNPay, MoMo, ZaloPay) cần đăng ký tài khoản doanh nghiệp và cấu hình khóa bí mật tương ứng.
* **Cấu hình IP thiết bị di động:** Khi chạy ứng dụng trên điện thoại thật hoặc máy ảo Android, cần đổi địa chỉ `localhost:3000` thành IP mạng LAN của máy chạy backend (hoặc `10.0.2.2:3000` đối với Android Emulator).

---

## 9. Kiến trúc kỹ thuật

```
Flutter Client (Web / Android / iOS / Desktop)
        │
        │ HTTP RESTful API (JSON)
        ▼
Node.js + Express API Server (Port: 3000)
        │
        │ MySQL Connection Pool (mysql2)
        ▼
MySQL Database: grocery_db (XAMPP / MariaDB)
```

* **Frontend:** Flutter SDK (Dart ^3.x), GetX State Management, SharedPreferences, http, intl.
* **Backend:** Node.js, Express.js, CORS, mysql2.
* **Database:** MySQL 8.x / MariaDB (XAMPP).

---

## 10. Cài đặt môi trường phát triển

### 10.1. Yêu cầu tiên quyết
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (phiên bản tương thích Dart >= 3.0.0).
* [Node.js](https://nodejs.org/) (phiên bản >= 16.x) & npm.
* [XAMPP](https://www.apachefriends.org/) (Khởi chạy Apache & MySQL).

### 10.2. Chuẩn bị Cơ sở dữ liệu (MySQL)
1. Mở **XAMPP Control Panel** và bấm **Start** dịch vụ MySQL.
2. Truy cập công cụ phpMyAdmin tại `http://localhost/phpmyadmin`.
3. Tạo mới database có tên: **`grocery_db`** (Collation: `utf8mb4_unicode_ci`).
4. Khởi tạo các bảng `users`, `categories`, `products`, `orders`, `order_items`, `notifications`.

### 10.3. Cài đặt và chạy Backend (Node.js)
Mở cửa sổ dòng lệnh tại thư mục backend của dự án:
```bash
cd D:/grocery_server
npm install
node index.js
```
> Khi màn hình xuất hiện:
> ```text
> Server dang chay tai http://localhost:3000
> Đã kết nối thành công database grocery_db
> ```
> Backend đã sẵn sàng phục vụ các yêu cầu API.

### 10.4. Cài đặt và chạy Ứng dụng Flutter
Mở một cửa sổ dòng lệnh mới tại thư mục ứng dụng:
```bash
cd D:/grocery_app
flutter pub get
flutter run -d chrome
```
*(Hoặc chọn thiết bị đích là Android Emulator / Windows Desktop tùy nhu cầu)*.

---

## 11. Hướng phát triển tiếp theo

1. **Bảo mật nâng cao:** Triển khai băm mật khẩu với `bcrypt` và xác thực qua chuẩn `JWT Token`.
2. **Cổng thanh toán tự động:** Tích hợp SDK thanh toán VNPay và quét mã VietQR tự động khớp nội dung chuyển khoản.
3. **Mô-đun Quản lý Kho chuyên sâu:** Bổ sung phiếu nhập kho từ nhà cung cấp, lịch sử điều chỉnh số lượng và cảnh báo khi tồn kho chạm ngưỡng tối thiểu.
4. **Thông báo đẩy (Push Notifications):** Tích hợp Firebase Cloud Messaging (FCM) để gửi thông báo biến động đơn hàng trực tiếp lên thanh trạng thái điện thoại của khách hàng.
