DECLARE @table TABLE (YourStrangeDate VARCHAR(100));
INSERT INTO @table VALUES('Tue Nov 8 06:14:57 GMT 2016');

WITH Splitted AS
(
    SELECT CAST('<x>' + REPLACE(YourStrangeDate,' ','</x><x>') + '</x>' AS XML) AS Casted
    FROM @table 
)
SELECT
CAST(
             Casted.value('/x[3]','nvarchar(2)') --third part = "8" 
     + ' ' + Casted.value('/x[2]','nvarchar(3)') --second part = "Nov"
     + ' ' + Casted.value('/x[6]','nvarchar(4)') --6th part = "2016"
     + ' ' + Casted.value('/x[4]','nvarchar(8)') --4th part = Time
     AS DATETIME)
FROM Splitted;