--test data preparation
/*

	CREATE TABLE #test (id INT, kol INT, num INT)

	INSERT #test
	VALUES (290, 1, 32),(290, 5, 33),(300, 2, 34)
	
*/

--with casting from int to varchar
select id,
  res = stuff((SELECT ', ' + cast(num AS varchar) + '-' + cast(kol as varchar)
               from #test
               where id = t.id
               for xml path('')               
              ),1,1,' ')
from #test t
group by id

--with using concat 
select id,
  res = stuff((SELECT concat(', ', num, '-', kol)
               from #test
               where id = t.id for xml path('')               
              ),1,1,' ')
from #test t
group by id

--withput leading spaces and a little bit compicated
SELECT id,
REVERSE(STUFF(REVERSE((SELECT 
						CAST(num AS NVARCHAR(10))+'-'+CAST(kol AS NVARCHAR(10)) + ', ' 
						FROM #test t2
						WHERE t1.id = t2.id
						FOR XML PATH('')
					)),1,2,''
		)) [res]
FROM #test t1
GROUP BY id


--drop table #test