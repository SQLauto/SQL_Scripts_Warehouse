WITH D AS --dates range parameters
( 
	SELECT '2006-01-01' AS Start_Date, '2018-12-31' AS End_Date 
),
N100 AS --sequence from 0 to 99
( 
	SELECT 0 AS N
	UNION ALL 
	SELECT N100.N + 1 FROM N100
	WHERE N100.N < 99
), 
N10000 AS --sequence from 0 to 9999
(
	SELECT N = N1.N * 100 + N2.N FROM N100 N1, N100 N2
),
DT AS --convert numbers to dates
( 
	SELECT 
		N, 
		DT = CAST(DateAdd(day, N, Start_Date) AS DATE)
	FROM N10000, D
),
C1 AS --dates range filtering
( 
	SELECT CAST(CONVERT(CHAR(8), DT, 112) as INT) [pk_date]
		  ,[DT]
		  ,CONVERT(CHAR(10), DT, 121) [date_name]
		  ,[id_date] = N + 1
	FROM DT, D
	WHERE DT.DT <= D.End_Date
),
C2 AS --calendar attributes genereation step 1
( 
	SELECT 
		 [pk_date]
		,[DT]
		,[date_name]
		,CAST(LEFT(pk_date, 6) AS INT)[id_yearmonth]
		,CAST(LEFT(pk_date, 4) AS INT) [id_year]
		,LEFT(pk_date, 4) [year_name]
		,(MONTH([DT]) - 1) / 3 + 1 [id_quartal]
		,DATEPART(WEEKDAY, [DT]) [id_weekday]
		,DATEPART(week, [DT]) [id_week]
		,MONTH([DT]) [id_month]
		,CASE MONTH([DT])  
			WHEN 1  THEN 'Январь' 
			WHEN 2  THEN 'Февраль' 
			WHEN 3  THEN 'Март' 
			WHEN 4  THEN 'Апрель' 
			WHEN 5  THEN 'Май' 
			WHEN 6  THEN 'Июнь' 
			WHEN 7  THEN 'Июль' 
			WHEN 8  THEN 'Август' 
			WHEN 9  THEN 'Сентябрь' 
			WHEN 10 THEN 'Октябрь' 
			WHEN 11 THEN 'Ноябрь' 
			WHEN 12 THEN 'Декабрь' 
		END [month_name]
		,CASE MONTH([DT])  
			WHEN 1  THEN 'Января' 
			WHEN 2  THEN 'Февраля' 
			WHEN 3  THEN 'Марта' 
			WHEN 4  THEN 'Апреля' 
			WHEN 5  THEN 'Мая' 
			WHEN 6  THEN 'Июня' 
			WHEN 7  THEN 'Июля' 
			WHEN 8  THEN 'Августа' 
			WHEN 9  THEN 'Сентября' 
			WHEN 10 THEN 'Октября' 
			WHEN 11 THEN 'Ноября' 
			WHEN 12 THEN 'Декабря' 
		END [month_name1]
		,CASE DATEPART(WEEKDAY, [DT]) 
			 when 1 then 'Понедельник'
			 when 2 then 'Вторник'
			 when 3 then 'Среда'
			 when 4 then 'Четверг'
			 when 5 then 'Пятница'
			 when 6 then 'Суббота'
			 when 7 then 'Воскресенье'
		end [weekday_name]
		,[id_date]
		,id_iso_week = datepart(ISO_WEEK, DT)
	FROM C1
),
C3 AS --calendar attributes genereation step 2
(  
	SELECT 
		 [pk_date]
		,[DT]
		,[date_name]
		,[id_yearmonth]
		,CONCAT([year_name], ' ', [month_name]) [year_month_name]
		,[month_name]
		,month_name1
		,[id_year]
		,[year_name]
		,id_year * 100 + id_week [id_yearweek]
		,CONCAT(id_year, ' Неделя ', id_week) [year_week_name]
		,CONCAT('Неделя ', id_week)  [week_name]
		,[id_year] * 10 + [id_quartal] [id_year_quartal]
		,[id_quartal]
		,CONCAT(id_year, ' Квартал ', [id_quartal]) [Year_Quartal_Name]
		,CONCAT('Квартал ', [id_quartal])  [Quartal_Name]
	--	,id_year * 1000 + id_week * 10 + [id_week] [id_week_weekday] 
		,id_year * 1000 + id_week * 10 + [id_weekday] [id_week_weekday]
		,CONCAT(id_year, ' - Нед. ', id_week, ' - ', [weekday_name]) [year_week_weekday_name]
		,[id_weekday]
		,[weekday_name]
		,[id_week]
		,[id_month]
		,ROW_NUMBER() OVER (PARTITION BY [id_yearmonth] ORDER BY DT) [id_day_of_month]
		,ROW_NUMBER() OVER (PARTITION BY [id_year], [id_quartal] ORDER BY DT) [id_day_of_quartal]
		,DENSE_RANK() OVER (PARTITION BY [id_year], [id_quartal] ORDER BY id_month) [id_month_of_quartal]
		,[id_year] * 1000 + [id_quartal] * 100 + id_month [id_year_Quartal_Month]
		,[id_date]
		,id_year * 10000 + id_month * 100 + id_week [id_year_month_week]
		,id_iso_week 
		,id_iso_year = 
			CASE 
				WHEN id_iso_week = 1 AND id_month = 12 THEN id_year + 1 
				WHEN id_iso_week > 51 AND id_month = 1 THEN id_year - 1
				ELSE id_year 
			END 
	FROM C2
), 
C4 AS -- calendar attributes genereation step 3
( 
	SELECT 
		 [pk_date]
		,[DT]
		,[date_name]
		,CONCAT([id_day_of_month], ' ', LOWER(month_name1), ' ', id_year) [date_name1]
		,[id_yearmonth]
		,[year_month_name]
		,[month_name]
		,[month_name1]
		,[id_year]
		,[year_name]
		,[id_yearweek]
		,[year_week_name]
		,[week_name]
		,[id_year_quartal]
		,[id_quartal]
		,[Year_Quartal_Name]
		,[Quartal_Name]
		,[id_week_weekday]
		,[year_week_weekday_name]
		,[id_weekday]
		,[weekday_name]
		,[id_week]
		,[id_month]
		,[id_day_of_month]
		,[id_day_of_quartal]
		,id_month_of_quartal * 10 + id_quartal as [id_month_of_quartal]
		,CONCAT(id_month_of_quartal, ' Месяц ', id_quartal, ' Квартала') [month_of_quartal_name]
		,[id_year_Quartal_Month]
		,CONCAT(id_year, ' Квартал ', id_quartal, ' ', month_name) [year_Quartal_Month_Name]
		,MIN(dt) OVER (PARTITION BY [id_year]) [Year_Value]
		,MIN(dt) OVER (PARTITION BY [id_year], [id_quartal]) [Quartal_Value]
		,MIN(dt) OVER (PARTITION BY [id_year], id_month) [Month_Value]
		,MIN(dt) OVER (PARTITION BY [id_year], id_week) [Week_Value]
		,[id_date]
		,MIN(dt) OVER (PARTITION BY [id_year], id_week) [id_First_Day_Of_Week]
		,[id_year_month_week]
		,id_iso_week
		,iso_week_name = CONCAT('Неделя ', id_iso_week)
		,id_iso_year
		,id_iso_year_week = id_iso_year * 100 + id_iso_week
	FROM C3
) -- calendar result
SELECT TOP 1000000
	 [pk_date]
	,[DT]
	,[date_name]
	,[id_yearmonth]
	,[year_month_name]
	,[month_name]
	,[id_year]
	,[year_name]
	,[id_yearweek]
	,[year_week_name]
	,[week_name]
	,[id_year_quartal]
	,[id_quartal]
	,[Year_Quartal_Name]
	,[Quartal_Name]
	,[id_week_weekday]
	,[year_week_weekday_name]
	,[id_weekday]
	,[weekday_name]
	,[id_week]
	,[id_month]
	,[id_day_of_month]
	,[id_day_of_quartal]
	,[id_month_of_quartal]
	,[month_of_quartal_name]
	,[id_year_Quartal_Month]
	,[year_Quartal_Month_Name]
	,[Year_Value]
	,[Quartal_Value]
	,[Month_Value]
	,[Week_Value]
	,[id_date]
	,[id_year_month_week]
	,[date_name1]
	,[month_name1]
	,[id_First_Day_Of_Week]
	,FIRST_VALUE([date_name1]) OVER (PARTITION BY [id_First_Day_Of_Week] ORDER BY [pk_date]) [First_Day_Of_Week_Name]
	,id_iso_week 
	,iso_week_name
	,id_iso_year
	,id_iso_year_week
	,iso_year_week_name = CONCAT(id_iso_year, ' ', LOWER(iso_week_name))
FROM C4
ORDER BY id_date