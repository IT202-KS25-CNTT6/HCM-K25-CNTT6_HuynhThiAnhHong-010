DROP DATABASE IF EXISTS hackthon;
CREATE DATABASE hackthon;
USE hackthon;

CREATE TABLE customers (
    customers_id  VARCHAR(10)  PRIMARY KEY,
    full_name     VARCHAR(150) NOT NULL,
    phone_number  VARCHAR(10)  NOT NULL UNIQUE,
    email         VARCHAR(100) NOT NULL,
    join_date     DATE   NOT NULL DEFAULT (CURRENT_DATE)
);

CREATE TABLE insurance_packages (
    package_id    VARCHAR(10)    PRIMARY KEY,
    package_name  VARCHAR(150)   NOT NULL,
    max_limit     DECIMAL(15,2)  NOT NULL CHECK (max_limit > 0),
    base_premium  DECIMAL(15,2)  NOT NULL CHECK (base_premium > 0)
);

CREATE TABLE policies (
    policy_id    VARCHAR(10) PRIMARY KEY,
    customer_id  VARCHAR(10) NOT NULL,
    package_id   VARCHAR(10) NOT NULL,
    start_date   DATE        NOT NULL,
    end_date     DATE        NOT NULL CHECK (end_date > start_date),
    p_status     VARCHAR(20) NOT NULL CHECK (p_status IN ('Active','Expired','Cancelled')),
    FOREIGN KEY (customer_id) REFERENCES customers(customers_id),
    FOREIGN KEY (package_id)  REFERENCES insurance_packages(package_id)
);

CREATE TABLE claims (
    claims_id     VARCHAR(10)   PRIMARY KEY,
    policy_id     VARCHAR(10)   NOT NULL,
    claim_date    DATE          NOT NULL DEFAULT (CURRENT_DATE),
    claim_amount  DECIMAL(15,2) NOT NULL CHECK (claim_amount > 0),
    c_status      VARCHAR(20)   NOT NULL DEFAULT 'Pending'
                                CHECK (c_status IN ('Pending','Approved','Rejected')),
    FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
);

CREATE TABLE claim_processing_log (
    log_id        VARCHAR(10) PRIMARY KEY,
    claim_id      VARCHAR(10) NOT NULL,
    action_detail TEXT        NOT NULL,
    recorded_at   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processor     VARCHAR(100) NOT NULL,
    FOREIGN KEY (claim_id) REFERENCES claims(claims_id)
);

-- ============================================================
-- INSERT
-- ============================================================
INSERT INTO customers VALUES
('C001','Nguyen Hoang Long','0901112223','long.nh@gmail.com','2024-01-15'),
('C002','Tran Thi Kim Anh','0988877766','anh.tk@yahoo.com','2024-03-10'),
('C003','Le Hoang Nam','0903334445','nam.lh@outlook.com','2024-05-20'),
('C004','Pham Minh Duc','0355556667','duc.pm@gmail.com','2024-08-12'),
('C005','Hoang Thu Thao','0779998881','thao.ht@gmail.com','2024-01-01');

INSERT INTO insurance_packages VALUES
('PKG01','Bảo hiểm Sức Khỏe Gold',  500000000,  5000000),
('PKG02','Bảo hiểm Ô tô Liberty',   1000000000, 15000000),
('PKG03','Bảo hiểm Nhân thọ An Bình', 2000000000, 5000000),
('PKG04','Bảo hiểm Du lịch Quốc tế',  100000000,  1000000),
('PKG05','Bảo hiểm Tai nạn 24/7',     200000000,  2500000);

INSERT INTO policies VALUES
('POL101','C001','PKG01','2024-01-15','2025-01-15','Expired'),
('POL102','C002','PKG02','2024-03-10','2026-03-10','Active'),
('POL103','C003','PKG03','2025-05-20','2035-05-20','Active'),
('POL104','C004','PKG04','2025-08-12','2025-09-12','Expired'),
('POL105','C005','PKG01','2026-01-01','2027-01-01','Active');

INSERT INTO claims VALUES
('CLM901','POL102','2024-06-15',12000000,'Approved'),
('CLM902','POL103','2025-10-20',50000000,'Pending'),
('CLM903','POL101','2024-11-05',5500000,'Approved'),
('CLM904','POL105','2026-01-15',2000000,'Rejected'),
('CLM905','POL102','2025-02-10',120000000,'Approved');

INSERT INTO claim_processing_log VALUES
('L001','CLM901','Đã nhận hồ sơ hiện trường', '2024-06-15 09:00:00','Admin_01'),
('L002','CLM901','Chấp nhận bồi thường xe tai nạn', '2024-06-20 12:30:00','Admin_01'),
('L003','CLM902','Đang thẩm định hồ sơ bệnh án', '2025-10-21 10:00:00','Admin_02'),
('L004','CLM904','Từ chối do lỗi cố ý của khách hàng', '2026-01-16 16:00:00','Admin_03'),
('L005','CLM905','Đã thanh toán qua chuyển khoản', '2025-02-15 08:30:00','Accountant_01');


SET SQL_SAFE_UPDATES = 0;

UPDATE insurance_packages
SET base_premium = base_premium * 1.15
WHERE max_limit > 500000000;

-- Câu 2: Xóa log ghi nhận trước '2025-06-20'
DELETE FROM claim_processing_log
WHERE recorded_at < '2025-06-20';


SELECT policy_id, customer_id, package_id, start_date, end_date, p_status
FROM policies
WHERE p_status = 'Active'
  AND YEAR(end_date) = 2026;


SELECT full_name, email
FROM customers
WHERE full_name LIKE '%Hoang%'
  AND YEAR(join_date) >= 2025;

SELECT claims_id, policy_id, claim_amount, c_status
FROM claims
ORDER BY claim_amount DESC
LIMIT 3 OFFSET 1;


SELECT c.full_name,
       ip.package_name,
       p.start_date,
       cl.claim_amount          
FROM policies p
INNER JOIN customers c         ON p.customer_id = c.customers_id
INNER JOIN insurance_packages ip ON p.package_id = ip.package_id
LEFT JOIN claims cl            ON p.policy_id  = cl.policy_id;


SELECT c.full_name,
       SUM(cl.claim_amount) AS total_approved
FROM claims cl
INNER JOIN policies p   ON cl.policy_id  = p.policy_id
INNER JOIN customers c  ON p.customer_id = c.customers_id
WHERE cl.c_status = 'Approved'
GROUP BY c.customers_id, c.full_name
HAVING SUM(cl.claim_amount) > 50000000;


SELECT ip.package_id, ip.package_name,
       COUNT(p.policy_id) AS total_policies
FROM insurance_packages ip
INNER JOIN policies p ON ip.package_id = p.package_id
GROUP BY ip.package_id, ip.package_name
HAVING COUNT(p.policy_id) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(policy_id) AS cnt
        FROM policies
        GROUP BY package_id
    ) sub
);


CREATE INDEX idx_policy_status_date
ON policies (p_status, start_date);


CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT c.full_name,
       COUNT(p.policy_id)        AS total_policies,
       COALESCE(SUM(ip.base_premium), 0) AS total_premium  -- NULL-safe tổng phí
FROM customers c
LEFT JOIN policies p            ON c.customers_id = p.customer_id
LEFT JOIN (
    SELECT package_id, base_premium
    FROM insurance_packages
) ip ON p.package_id = ip.package_id
GROUP BY c.customers_id, c.full_name;

DELIMITER //
CREATE TRIGGER trg_after_claim_approved
AFTER UPDATE ON claims
FOR EACH ROW
BEGIN
    IF NEW.c_status = 'Approved' AND OLD.c_status <> 'Approved' THEN
        INSERT INTO claim_processing_log (log_id, claim_id, action_detail, recorded_at, processor)
        VALUES (
            CONCAT('AUTO-', NEW.claims_id),
            NEW.claims_id,
            'Payment processed to customer',
            NOW(),
            'System'
        );
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_prevent_delete_active_policy
BEFORE DELETE ON policies
FOR EACH ROW
BEGIN
    IF OLD.p_status = 'Active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete an Active policy.';
    END IF;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE sp_check_claim_limit(
    IN  p_claim_id VARCHAR(10),
    OUT p_message  VARCHAR(20)
)
BEGIN
    DECLARE v_claim_amount DECIMAL(15,2);
    DECLARE v_max_limit    DECIMAL(15,2);

    SELECT cl.claim_amount, ip.max_limit
    INTO   v_claim_amount, v_max_limit
    FROM claims cl,
         policies p,
         insurance_packages ip
    WHERE cl.claims_id  = p_claim_id
      AND cl.policy_id  = p.policy_id
      AND p.package_id  = ip.package_id;

    IF v_claim_amount > v_max_limit THEN
        SET p_message = 'Exceeded';
    ELSE
        SET p_message = 'Valid';
    END IF;
END //
DELIMITER ;