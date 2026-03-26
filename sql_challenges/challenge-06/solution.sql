

CREATE TABLE pet_care_log (
    product_id NUMBER NOT NULL,
    log_datetime DATE NOT NULL,
    created_by_user VARCHAR2(30),
    log_text VARCHAR2(500),
    last_update_datetime DATE,
    CONSTRAINT pk_pet_care_log PRIMARY KEY (product_id, log_datetime)
);

CREATE OR REPLACE TRIGGER trg_pet_care_log_bi
BEFORE INSERT ON pet_care_log
FOR EACH ROW
BEGIN
    :NEW.last_update_datetime := SYSDATE;
    :NEW.created_by_user := USER;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Error inserting into PET_CARE_LOG: ' || SQLERRM
        );
END;
/

CREATE OR REPLACE TRIGGER trg_pet_care_log_bu
BEFORE UPDATE ON pet_care_log
FOR EACH ROW
BEGIN
    IF :OLD.created_by_user != USER THEN
        RAISE_APPLICATION_ERROR(
            -20002,
            'You can only update your own records.'
        );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(
            -20003,
            'Error updating PET_CARE_LOG: ' || SQLERRM
        );
END;
/


CREATE OR REPLACE TRIGGER trg_pet_care_log_bd
BEFORE DELETE ON pet_care_log
FOR EACH ROW
BEGIN
    IF USER != 'JOEMANAGER' THEN
        RAISE_APPLICATION_ERROR(
            -20004,
            'Only JOEMANAGER can delete records.'
        );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(
            -20005,
            'Error deleting from PET_CARE_LOG: ' || SQLERRM
        );
END;
/

--Pruebas--

INSERT INTO pet_care_log (product_id, log_datetime, log_text)
VALUES (1, SYSDATE, 'Initial pet care log');

UPDATE pet_care_log
SET log_text = 'Updated log'
WHERE product_id = 1
AND log_datetime = (SELECT MAX(log_datetime) FROM pet_care_log WHERE product_id = 1);

DELETE FROM pet_care_log
WHERE product_id = 1;

-- Simulación conceptual
-- CONNECT JOEMANAGER/password;

DELETE FROM pet_care_log
WHERE product_id = 1;
