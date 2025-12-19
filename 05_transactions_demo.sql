/* =========================================================
   06_transactions_demo.sql
   Transaction Demo: COMMIT & ROLLBACK (SQL Server)

   Amaç:
   - Bir bilet satın alma işlemi sırasında birden fazla tabloda
     (Tickets + Payments) değişiklik yapıldığını göstermek.
   - İşlem hatalı olursa tüm değişiklikler geri alınsın (ROLLBACK).
   ========================================================= */

SET NOCOUNT ON;

-- ---------------------------------------------------------
-- ÖN KONTROL: Seed data var mı?
-- ---------------------------------------------------------
-- Bu demo için en az 1 flight, 2 passenger, 1 package ve seats olmalı.
SELECT TOP 5 * FROM Flights;
SELECT TOP 5 * FROM Passengers;
SELECT TOP 5 * FROM FarePackages;
SELECT TOP 5 * FROM Seats;

PRINT '=== TRANSACTION DEMO START ===';


/* =========================================================
   A) SUCCESS SCENARIO (COMMIT)
   - Daha önce satılmamış bir koltuk seçilir.
   - Ticket + Payment aynı transaction içinde oluşturulur.
   ========================================================= */

DECLARE @flight_id INT = 1;        -- Seed'de Flight 1 var varsayımı
DECLARE @passenger_id INT = 1;     -- Seed'de Passenger 1 var
DECLARE @package_id INT = 2;       -- PKG_20KG (seed sırası)
DECLARE @seat_id INT = 7;          -- boş bir koltuk seç (ör: 2C)
DECLARE @price DECIMAL(10,2) = 1100.00;
DECLARE @pnr VARCHAR(12) = 'PNR000000010';

BEGIN TRY
    BEGIN TRANSACTION;

    /*
    1) Ticket oluştur
    Not: Aynı flight_id + seat_id daha önce satılmadıysa insert başarılı olur.
    */
    INSERT INTO Tickets(pnr, flight_id, passenger_id, seat_id, package_id, member_id, price_paid, ticket_status)
    VALUES(@pnr, @flight_id, @passenger_id, @seat_id, @package_id, 1, @price, 'Active');

    DECLARE @new_ticket_id INT = SCOPE_IDENTITY();

    /*
    2) Payment oluştur
    Ticket_id üzerinden Payments'a kayıt atılır.
    */
    INSERT INTO Payments(ticket_id, amount, payment_method, status)
    VALUES(@new_ticket_id, @price, 'Online', 'Paid');

    COMMIT TRANSACTION;

    PRINT 'COMMIT SUCCESS: Ticket + Payment created.';
    SELECT 'COMMIT_SUCCESS' AS result, @new_ticket_id AS ticket_id;

    -- Kanıt: kayıtlar oluşmuş mu?
    SELECT * FROM Tickets WHERE ticket_id = @new_ticket_id;
    SELECT * FROM Payments WHERE ticket_id = @new_ticket_id;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'COMMIT FAILED unexpectedly!';
    SELECT 'COMMIT_FAILED' AS result, ERROR_MESSAGE() AS error_message;
END CATCH;


PRINT '---------------------------------------------------------';


/* =========================================================
   B) FAIL SCENARIO (ROLLBACK)
   - Aynı flight_id + seat_id kombinasyonu tekrar satılmaya çalışılır.
   - UNIQUE constraint (UQ_Tickets_FlightSeat) hata verir.
   - Ticket insert başarısız -> transaction rollback -> Payment da oluşmaz.
   ========================================================= */

DECLARE @flight_id2 INT = 1;
DECLARE @passenger_id2 INT = 2;         -- başka yolcu
DECLARE @package_id2 INT = 1;           -- PKG_15KG
DECLARE @seat_id2 INT = 7;              -- ÜSTTE SATILDI (aynı koltuk!)
DECLARE @price2 DECIMAL(10,2) = 900.00;
DECLARE @pnr2 VARCHAR(12) = 'PNR000000011';

-- ROLLBACK kanıtı için: işlem öncesi row count alalım
DECLARE @tickets_before INT = (SELECT COUNT(*) FROM Tickets);
DECLARE @payments_before INT = (SELECT COUNT(*) FROM Payments);

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Tickets(pnr, flight_id, passenger_id, seat_id, package_id, member_id, price_paid, ticket_status)
    VALUES(@pnr2, @flight_id2, @passenger_id2, @seat_id2, @package_id2, NULL, @price2, 'Active');

    DECLARE @new_ticket_id2 INT = SCOPE_IDENTITY();

    INSERT INTO Payments(ticket_id, amount, payment_method, status)
    VALUES(@new_ticket_id2, @price2, 'Credit Card', 'Paid');

    COMMIT TRANSACTION;

    PRINT 'UNEXPECTED: This should have failed but committed.';
    SELECT 'UNEXPECTED_COMMIT' AS result, @new_ticket_id2 AS ticket_id;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ROLLBACK SUCCESS (EXPECTED): Duplicate seat sale prevented.';
    SELECT 'ROLLBACK_SUCCESS_EXPECTED' AS result, ERROR_MESSAGE() AS error_message;
END CATCH;

-- ROLLBACK kanıtı: row count değişmemeli
DECLARE @tickets_after INT = (SELECT COUNT(*) FROM Tickets);
DECLARE @payments_after INT = (SELECT COUNT(*) FROM Payments);

SELECT
    @tickets_before AS tickets_before,
    @tickets_after  AS tickets_after,
    @payments_before AS payments_before,
    @payments_after  AS payments_after;

PRINT '=== TRANSACTION DEMO END ===';
