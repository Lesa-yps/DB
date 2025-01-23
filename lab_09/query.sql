-- выборка топ-10 читаемых книг
select book_id, count(*) as count_readers
from Rentals R
group by book_id
order by count(*) desc 
limit 10;