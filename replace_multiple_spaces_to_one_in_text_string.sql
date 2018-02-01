declare @string AS varchar(4000)
SET @string = '<span class="p-title">Вес </span><span class="p-value"> 140</li>          <li><span>Area di stampa </span>65</li>          <li><span>Misura</span> 50</li>'
SELECT @string

SELECT REPLACE(
           REPLACE(
               REPLACE(
                   LTRIM(RTRIM((@string)))
               ,'  ',' '+CHAR(7) )  
           ,CHAR(7)+' ','')        
       ,CHAR(7),'') AS ClearedString
