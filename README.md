# 🛒 GROCERY MART - ỨNG DỤNG MUA SẮM THỰC PHẨM & QUẢN LÝ ĐƠN HÀNG THÔNG MINH

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/GetX-State_Management-8A2BE2?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Node.js-Express-339933?style=for-the-badge&logo=node.js&logoColor=white" />
  <img src="https://img.shields.io/badge/MySQL-Database-4479A1?style=for-the-badge&logo=mysql&logoColor=white" />
</p>

---

## 📖 Giới thiệu Đề tài

**Grocery Mart** là giải pháp phần mềm thương mại điện tử hoàn chỉnh phục vụ nhu cầu mua sắm thực phẩm sạch trực tuyến kết hợp bảng điều khiển quản trị (Admin Dashboard) thời gian thực. Dự án được thiết kế và xây dựng theo mô hình **Client - Server (Fullstack)** với kiến trúc phân tầng chuyên nghiệp:

* **Frontend:** Ứng dụng đa nền tảng viết bằng **Flutter & GetX**, hỗ trợ mượt mà trên Mobile (Android/iOS) và Web/Desktop.
* **Backend:** RESTful API xây dựng trên **Node.js (Express framework)**.
* **Database:** Hệ quản trị cơ sở dữ liệu quan hệ **MySQL** lưu trữ dữ liệu thực tế.

---

## ✨ Tính năng Nổi bật

### 1. Phân hệ Khách hàng (Customer App)
* 🔐 **Xác thực tài khoản:** Đăng ký, đăng nhập bảo mật với phiên lưu trữ qua SharedPreferences / JWT.
* 🥬 **Danh mục & Sản phẩm:** Xem danh sách thực phẩm tươi sống, flash sale, sản phẩm nổi bật, tìm kiếm tức thì theo từ khóa.
* 🔍 **Bộ lọc & Chi tiết:** Lọc theo phân loại, xem đánh giá sao, bảng dinh dưỡng, hướng dẫn bảo quản.
* 🛒 **Giỏ hàng thông minh:** Thêm/bớt số lượng, chọn xóa sản phẩm, tính toán tự động phụ phí và tạm tính.
* 💳 **Thanh toán & Đặt hàng (Checkout):** Chọn địa chỉ giao hàng, áp dụng Voucher giảm giá, hỗ trợ phương thức COD / Chuyển khoản, thêm ghi chú cho đơn hàng.
* 📦 **Lịch sử đơn hàng:** Theo dõi trạng thái đơn hàng theo thời gian thực (*Chờ xác nhận*, *Chuẩn bị*, *Đang giao*, *Đã giao*, *Đã hủy*).
* 🤖 **Trợ lý AI:** Chatbot tư vấn thực đơn và gợi ý sản phẩm tự động.
* 🔔 **Hệ thống thông báo:** Cập nhật biến động trạng thái đơn hàng và các chương trình khuyến mãi.

### 2. Phân hệ Quản trị viên (Admin Dashboard)
* 📊 **Thống kê doanh thu thời gian thực:** Doanh thu thuần, số lượng đơn phát sinh, AOV (giá trị đơn trung bình), tổng sản phẩm bán ra.
* 📈 **Biểu đồ xu hướng 7 ngày:** Biểu đồ cột tự động tính toán từ các đơn hàng thực tế phát sinh trong tuần.
* 📑 **Quản lý đơn hàng:** Xem danh sách đơn, chi tiết từng món hàng, cập nhật trạng thái đơn (Xác nhận, Đóng gói, Giao hàng, Hoàn tất).
* 🏷️ **Quản lý danh mục & Sản phẩm:** Thêm món mới, cập nhật giá tiền, hình ảnh và tồn kho.
* 👥 **Quản lý khách hàng & Khuyến mãi:** Danh sách người dùng hệ thống và thiết lập mã Voucher ưu đãi.

---

## 🏛️ Kiến trúc Hệ thống (System Architecture)

```
[ Flutter Client (Web / Mobile) ]
           │
           │  HTTP RESTful API (JSON)
           ▼
[ Node.js + Express Server (Port: 3000) ]
           │
           │  MySQL Connection Pool
           ▼
[ MySQL Database: grocery_db (XAMPP / MariaDB) ]
```

---

## 🗄️ Cấu trúc Cơ sở Dữ liệu (MySQL Schema)

Cơ sở dữ liệu **`grocery_db`** gồm các bảng quan hệ chính:

1. **`users`**: Quản lý tài khoản, mật khẩu, họ tên, email, số điện thoại, vai trò (`role`: `customer` / `admin`).
2. **`categories`**: Danh mục thực phẩm (Trái cây, Rau củ, Thịt trứng, Hải sản...).
3. **`products`**: Thông tin sản phẩm, đơn giá, hình ảnh, đơn vị tính, số lượng tồn kho.
4. **`orders`**: Thông tin đơn đặt hàng, tổng tiền, phí vận chuyển, địa chỉ nhận hàng, phương thức thanh toán, trạng thái đơn, thời gian tạo.
5. **`order_items`**: Chi tiết từng mặt hàng và số lượng nằm trong đơn hàng.
6. **`notifications`**: Thông báo gửi đến người dùng hệ thống.

---

## 🚀 Hướng dẫn Cài đặt & Khởi chạy

### 1. Chuẩn bị môi trường
* Đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0.0).
* Đã cài đặt [Node.js](https://nodejs.org/) (>= 16.x).
* Đã cài đặt [XAMPP](https://www.apachefriends.org/) (Khởi động Apache & MySQL).

### 2. Khởi tạo Cơ sở Dữ liệu (MySQL)
1. Mở **phpMyAdmin** tại `http://localhost/phpmyadmin`.
2. Tạo cơ sở dữ liệu mới với tên: `grocery_db`.
3. Import file cấu trúc SQL của dự án vào database `grocery_db`.

### 3. Chạy Backend Server
Mở terminal và di chuyển vào thư mục backend:
```bash
cd D:/grocery_server
npm install
node index.js
```
> Server sẽ lắng nghe tại: `http://localhost:3000`

### 4. Chạy Ứng dụng Flutter
Mở một terminal mới tại thư mục đồ án:
```bash
cd D:/grocery_app
flutter pub get
flutter run -d chrome
```
*(Hoặc chạy trên thiết bị giả lập Android / Windows Desktop)*.

---

## 🔑 Tài khoản Mẫu Trải nghiệm

| Vai trò (Role) | Email | Mật khẩu | Chức năng truy cập |
| :--- | :--- | :--- | :--- |
| **Quản trị viên (Admin)** | `admin@gmail.com` | `adminpassword` | Toàn quyền Dashboard, Thống kê, Quản lý đơn hàng, Kho hàng |
| **Khách hàng (Customer)** | `user@gmail.com` | `password123` | Mua sắm, Đặt hàng, Xem lịch sử đơn hàng cá nhân |

---

## 📁 Cấu trúc Thư mục Mã nguồn (Project Structure)

```
grocery_app/
├── android/                   # Cấu hình nền tảng Android
├── ios/                       # Cấu hình nền tảng iOS
├── web/                       # Cấu hình nền tảng Web
├── assets/                    # Hình ảnh, biểu tượng tĩnh
└── lib/
    ├── app.dart               # Cấu hình GetMaterialApp & Theme
    ├── main.dart              # Điểm khởi chạy ứng dụng
    ├── core/                  # Thành phần dùng chung toàn app
    │   ├── constants/         # Bảng màu, chuỗi văn bản, routes
    │   ├── routes/            # Khai báo GetPages & định tuyến
    │   ├── storage/           # LocalStorage (SharedPreferences)
    │   ├── themes/            # Typography, Style giao diện
    │   └── utils/             # Formatters (tiền tệ VNĐ, ngày giờ)
    ├── data/                  # Tầng dữ liệu (Data Layer)
    │   ├── datasource/        # DatabaseHelper, Mock Data fallback
    │   ├── models/            # ProductModel, OrderModel, UserModel...
    │   └── repositories/      # Gọi API Backend (Auth, Order, Product...)
    ├── features/              # Các phân hệ chức năng (Feature-First)
    │   ├── admin/             # Bảng điều khiển quản trị, biểu đồ thống kê
    │   ├── ai_assistant/      # Trợ lý ảo AI tư vấn
    │   ├── auth/              # Đăng ký, đăng nhập, quên mật khẩu
    │   ├── cart/              # Giỏ hàng mua sắm
    │   ├── checkout/          # Quy trình đặt hàng & thanh toán
    │   ├── home/              # Trang chủ hiển thị sản phẩm
    │   ├── notification/      # Quản lý thông báo
    │   ├── order/             # Theo dõi lịch sử đơn hàng
    │   ├── product/           # Chi tiết sản phẩm, đánh giá
    │   └── profile/           # Hồ sơ cá nhân & cài đặt
    └── shared/                # Widget tái sử dụng (Buttons, Cards, Dialogs)
```

---

## 🛠️ Công nghệ & Thư viện Sử dụng

* **Flutter & Dart:** Ngôn ngữ và framework UI chính.
* **GetX:** Quản lý trạng thái (State Management), Dependency Injection và điều hướng (Route Management).
* **http:** Giao thức truyền tải dữ liệu mạng tới REST API.
* **intl:** Định dạng chuẩn tiền tệ Việt Nam Đồng (VNĐ) và thời gian thực tế.
* **SharedPreferences & Sqflite:** Lưu trữ phiên đăng nhập và bộ nhớ đệm cục bộ.
* **CachedNetworkImage & Shimmer:** Tải hình ảnh mượt mà và hiệu ứng skeleton loading chuyên nghiệp.

---

## 👨‍💻 Tác giả
* **Đồ án môn học / Đồ án liên ngành**
* **Sinh viên thực hiện:** Đồ án Tốt nghiệp / Báo cáo Chuyên ngành Công nghệ Thông tin
* **Giáo viên hướng dẫn: TS. Nguyễn Lệ Thu**
* **Đề tài:** Xây dựng ứng dụng thương mại điện tử mua sắm thực phẩm đa nền tảng
