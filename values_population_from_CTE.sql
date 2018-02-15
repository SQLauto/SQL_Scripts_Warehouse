;WITH cte AS (
    SELECT * FROM (
        VALUES
            (1, 2, 3),
            (2, 3, 4)
        ) AS a (col1, col2, col3)
    )
select *
from cte