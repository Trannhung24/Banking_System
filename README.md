Mô tả:
Xây dựng hệ thống quản lý ngân hàng gồm các bảng Customers, Accounts, Transactions, Alerts để mô phỏng các hoạt động giao dịch thực tế, kết hợp trigger phát hiện giao dịch bất thường và truy vấn phân tích dữ liệu.

Các điểm nổi bật:

Thiết kế CSDL quan hệ chuẩn hóa gồm:

Thông tin khách hàng, tài khoản, giao dịch, cảnh báo.

Quan hệ 1-n giữa khách hàng – tài khoản, tài khoản – giao dịch.

Tạo trigger AFTER INSERT phát hiện giao dịch có số tiền lớn hơn 10,000 và tự động lưu vào bảng cảnh báo.

Viết nhiều truy vấn SQL tối ưu:

Truy vấn thông tin cảnh báo kèm chủ tài khoản.

Truy vấn tổng giao dịch theo từng khách hàng/tài khoản.

Sử dụng CTE, ROW_NUMBER() để xác định giao dịch lớn nhất của mỗi tài khoản.

Truy vấn có điều kiện thời gian, GROUP BY, EXISTS, JOIN đa cấp.

Kết hợp kỹ thuật tối ưu truy vấn: lọc sớm, EXISTS thay vì IN, sử dụng hàm tổng hợp thông minh.
