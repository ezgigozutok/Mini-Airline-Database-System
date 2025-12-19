/* =========================================================
   05_triggers.sql
   Triggers for Mini Airline DB (SQL Server)
   ========================================================= */

SET NOCOUNT ON;
GO

/* =========================================================
   1) tr_CheckIn_CreateBoardingPass
   Amaç:
   - CheckIns tablosuna 'CheckedIn' kaydı eklenince
     otomatik olarak BoardingPasses kaydı üretmek.
   Neden trigger?
   - Uygulama (frontend) boarding pass oluşturmayı unutsa bile
     DB seviyesinde garanti sağlanır (data integrity).
   ========================================================= */
GO
CREATE OR ALTER TRIGGER tr_CheckIn_CreateBoardingPass
ON CheckIns
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    /*
    inserted: trigger'ın çalıştığı anda eklenen yeni satır(lar)
    Not: Çoklu insert olabilir, o yüzden set-bazlı işlem yapıyoruz.
    */

    INSERT INTO BoardingPasses(ticket_id, issued_at, token)
    SELECT
        i.ticket_id,
        GETDATE(),
        NEWID()
    FROM inserted i
    WHERE i.status = 'CheckedIn'
      AND NOT EXISTS (
            SELECT 1
            FROM BoardingPasses bp
            WHERE bp.ticket_id = i.ticket_id
      );

    /*
    NOT EXISTS ile:
    - aynı ticket_id için ikinci boarding pass üretimini engelleriz.
    - BoardingPasses tablosundaki UNIQUE(ticket_id) kuralıyla da uyumludur.
    */
END
GO


/* =========================================================
   2) tr_FlightStatus_CompensateMembers
   Amaç:
   - Flight_Status tablosuna yeni bir durum kaydı eklendiğinde
     (özellikle Delayed veya Cancelled),
     o uçuşa ait BİLETLER içindeki ÜYELERE telafi puanı eklemek.
   
   Neden trigger?
   - Operasyon personeli uçuşu "Delayed" işaretlediği anda
     müşteri memnuniyeti otomatik devreye girsin.
   - Bu gerçek sistem davranışına benzer ve raporda çok iyi görünür.

   Telafi kuralı (basit demo):
   - Delayed: 100 puan
   - Cancelled: 300 puan
   Not: İstersen delay_minutes'a göre dinamik yaparız.
   ========================================================= */
GO
CREATE OR ALTER TRIGGER tr_FlightStatus_CompensateMembers
ON Flight_Status
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    /*
    Bu trigger sadece yeni eklenen status kayıtlarına bakar.
    inserted içinde birden çok flight_id gelebilir.
    */

    -- Telafi puanlarını durum bazında belirleyelim
    ;WITH NewEvents AS (
        SELECT
            i.flight_id,
            i.status,
            CASE 
                WHEN i.status = 'Delayed' THEN 100
                WHEN i.status = 'Cancelled' THEN 300
                ELSE 0
            END AS comp_points,
            i.updated_at
        FROM inserted i
        WHERE i.status IN ('Delayed', 'Cancelled')
    ),
    AffectedMembers AS (
        /*
        Etkilenen üyeler:
        - aynı flight_id'ye ait Tickets
        - ticket_status = Active (iptal bilet için tekrar telafi vermeyelim)
        - member_id IS NOT NULL (üyeler)
        */
        SELECT DISTINCT
            t.member_id,
            ne.flight_id,
            ne.status,
            ne.comp_points,
            ne.updated_at
        FROM NewEvents ne
        JOIN Tickets t ON t.flight_id = ne.flight_id
        WHERE t.ticket_status = 'Active'
          AND t.member_id IS NOT NULL
          AND ne.comp_points > 0
    )
    -- 1) Üyelerin puanını artır
    UPDATE m
    SET m.points = m.points + am.comp_points
    FROM Members m
    JOIN AffectedMembers am ON am.member_id = m.member_id;

    -- 2) Puan hareket kaydı (audit)
    INSERT INTO MemberPointsTransactions(member_id, txn_time, txn_type, points, description)
    SELECT
        am.member_id,
        GETDATE(),
        'EARN',
        am.comp_points,
        CONCAT('Compensation for flight ', am.flight_id, ' status: ', am.status)
    FROM AffectedMembers am;

END
GO
