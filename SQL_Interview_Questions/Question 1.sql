

select *
from Anytable
where exists (select 1%0 from AnotherAnyTable)


select *
from Anytable
where exists (select 1%0)