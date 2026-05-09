SELECT * FROM appointments;
SELECT * FROM employees;

DELIMITER //

CREATE TRIGGER trg_CheckDoubleBooking_Insert
BEFORE INSERT ON Appointments
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Appointments 
        WHERE doctor_id = NEW.doctor_id 
          AND appointment_date = NEW.appointment_date 
          AND status <> 'Cancelled'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Bác sĩ đã có lịch hẹn vào khung giờ này';
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER trg_CheckDoubleBooking_Update
BEFORE UPDATE ON Appointments
FOR EACH ROW
BEGIN
    -- chỉ kiểm tra nếu bác sĩ hoặc thời gian hoặc trạng thái bị thay đổi
    IF EXISTS (
        SELECT 1 FROM Appointments 
        WHERE doctor_id = NEW.doctor_id 
          AND appointment_date = NEW.appointment_date 
          AND status <> 'Cancelled'
          AND appointment_id <> NEW.appointment_id 
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Bác sĩ đã có lịch hẹn vào khung giờ này';
    END IF;
END //

DELIMITER ;

-- doctor_id = NEW.doctor_id: Kiểm tra đúng bác sĩ đó.

-- appointment_date = NEW.appointment_date: Trùng khung giờ.

-- status <> 'Cancelled': Ngoại lệ 1 - Bỏ qua các ca đã hủy.

-- appointment_id <> NEW.appointment_id
INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_date, status)
VALUES (203, 1, 102, '2026-06-15 15:00:00', 'Pending');

INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_date, status)
VALUES (203, 2, 102, '2026-06-15 15:00:00', 'Pending');


UPDATE Appointments 
SET status = 'Completed' 
WHERE appointment_id = 200;
