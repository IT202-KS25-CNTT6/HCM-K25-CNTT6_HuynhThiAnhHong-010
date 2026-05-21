CREATE DATABASE hackthon;
USE hackthon;

CREATE TABLE customers (
	customers_id VARCHAR(10) PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(10) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    join_date CURRENT_DATE DEFAULT NOT NULL
);

CREATE TABLE insurance_packages (
	package_id VARCHAR(10) PRIMARY KEY,
    package_name NOT NULL,
    max_limit CHECK max_limi > 0 NOT NULL,
    base_premium CHECK base_premium NOT NULL
);

CREATE TABLE policies (
	policy_id VARCHAR(10) PRIMARY KEY,
    customer_id NOT NULL FOREIGN KEY customer(customer_id),
    package_id NOT NULL FOREIGN KEY insurance_packages(package_id),
    start_date DATE NOT NULL,
    end_date CHECK end_date > start_date,
    p_status CHECK IN ('Active', 'Expired', 'Cancelled')
);

CREATE TABLE claims (
	claims_id VARCHAR(10) PRIMARY KEY,
    pollcy_id FOREIGN KEY policies(policy_id) NOT NULL,
    claim_date (CURRENT_DATE) DEFAULT NOT NULL,
    claim_amount CHECK claim_amount > 0 NOT NULL,
    c_status NOT NULL DEFAULT 'pending' CHECK IN ('pending', 'approved', 'rejected')
);
CREATE TABLE claim_processing_log (
	log_id VARCHAR(10) PRIMARY KEY,
    claim_id NOT NULL FOREIGN KEY claims(claim_id),
    action_detail TEXT NOT NULL ,
    recorded_at CURRENT_TIMESTAMP DEFAULT NOT NULL,
    processor NOT NULL
);

INSERT INTO customer VALUES 
('C001', 'Nguyen Hoang Long', '0901112223', 'long.nh@gmail.com', '2024-01-15'),
('C002', 'Tran Thi Kim Anh', '0988877766', 'anh.tk@yahoo.com', '2024-03-10'),
('C003', 'Le Hoang Nam', '0903334445', 'nam.lh@outlook.com', '2024-05-20'),
('C004', 'Pham Minh Duc', '0355556667', 'duc.pm@gmail.com', '2024-08-12'),
('C005', 'Hoang Thu Thao', '0779998881', 'thao.ht@gmail.com', '2024-01-01');

INSERT INTO insurance_packages (package_id, package_name, max_limit, base_premium) VALUES 
('PKG01', 'Bảo hiểm Sức Khỏe Gold', '500000000', '5000000'),
('PKG02', 'Bảo hiểm Ô tô Liberty', '1000000000', '15000000'),
('PKG03', 'Bảo hiểm Nhân thọ An Bình ', '2000000000', '5000000'),
('PKG04', 'Bảo hiểm Du lịch Quốc tế ', '100000000', '1000000'),
('PKG05', 'Bảo hiểm Tai nạn 24/7', '200000000', '2500000');

INSERT INTO policies (policy_id, customer_id, package_id, start_date, end_date, p_status) VALUES
('POL101', 'C001', 'PKG01', '2024-01-15', '2025-01-15', 'Expired'),
('POL102', 'C002', 'PKG02', '2024-03-10', '2026-03-10', 'Active'),
('POL103', 'C003', 'PKG03', '2025-05-20', '2035-05-20', 'Active'),
('POL104', 'C004', 'PKG04', '2025-08-12', '2025-09-12', 'Expired'),
('POL105', 'C005', 'PKG01', '2026-01-01', '2027-01-01', 'Active');

INSERT INTO claims (claims_id, pollcy_id, claim_date, claim_amount, status) VALUES
('CLM901', 'POL102', '2024-06-15', '12000000', 'Approved'),
('CLM902', 'POL103', '2025-10-20', '50000000', 'Pending'),
('CLM903', 'POL101', '2024-11-05', '5500000', 'Approved'),
('CLM904', 'POL105', '2026-01-15', '2000000', 'Rejected'),
('CLM905', 'POL102', '2025-02-10', '120000000', 'Approved');

INSERT INTO claim_processing_log (log_id, claim_id, action_detail, recorded_at, processor) VALUES
('L001', 'CLM901', 'Đã nhận hồ sơ hiện trường', '2024-06-15 09:00', 'Admin_01'),
('L002', 'CLM901', 'Chấp nhận bồi thường xe tai nạn', '2024-06-20 12:30', 'Admin_01'),
('L003', 'CLM902', 'Đang thẩm định hồ sơ bệnh án', '2025-10-21 10:00', 'Admin_02'),
('L004', 'CLM904', 'Từ chối do lỗi cố ý của khách hàng', '2026-01-16 16:00', 'Admin_03'),
('L005', 'CLM905', 'Đã thanh toán qua chuyển khoản', '2025-02-15 08:30', 'Accountant_01');
-- Cập nhật & xóa dữ liệu
-- câu 1: Viết câu lệnh tăng phí bảo hiểm cơ bản (base_premium) thêm 15% cho các gói bảo hiểm có hạn mức chi trả (max_limit) trên 500.000.000 VND
SELECT 

-- Câu 2 viết câu lệnh xóa các nhật ký xử lý bồi thường (claim_processing_log) đuwojc ghi nhận trước ngày '2025-06-20'

-- câu 1: Liệt kê thông tin các hợp đồng có trạng thái" Active" và có ngày kết thúc (end_date) trong năm 2026
-- câu 2: Lấy thông tin khách hàng ( họ tên, email) có tên chứa chữ 'Hoang' và tham gia bảo hiểm từ năm 2025 trở lại đây
-- Câu 3: Sắp xếp claim_amount giảm dần, bỏ qua bản ghi đầu tiên, lấy 3 bảng tiếp theo

-- câu 1: sử dụng LEFT JOIN để hiển thị cả hợp đồng chưa có yêu cầu bồi thường. Kết quả gồm tên khách hàng, tên gói bảo hiểm,ngày bắt đầu hợp đòng, số tiền bồi thường(Null nếu chưa có)
-- câu 2: Thống kê tôrng số tiền bồi thường đã chi trả(status='Approved') cho từng khách hàng. Chỉ hiển thị những người có tổng chi trả trên 50000000 VND
-- câu 3: tìm gói bảo hiểm có số lượng khách hàng đăng ký nhiều nhất



-- Câu 1: tạo composite index tên idx_policy_status_date trên bảng Policies cho hai cột status và start_date
-- câu 2: tạo View tên vw_customer_summary hiển thị: Tên khách hàng, Số lượng hợp đồng đang sở hữu, tổnng phí bảo hiểm định kì phải trả


-- câu 1 viết Trigger tên trg_after_claim_approved
-- Yêu cầ: Khi một yêu cầu bồi thường chuyển trạng thái sang'Approved', tự động thêm một dòng vào Claim_Processing_Log với nội dung:
-- 'Payment processed to customer'
-- Câu 2 Viết Trigger ngăn chặn việc xóa hợp đồng nếu trạng thái của hợp đồng đó đnag là 'Active'
