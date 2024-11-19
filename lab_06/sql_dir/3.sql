-- 3. Выполнить запрос с ОТВ(CTE) и оконными функциями
-- книги с наибольшим количеством аренд, ранжировка их
COPY (
    WITH Book_Rentals_CTE AS (
    SELECT
        b.book_id,
        b.title,
        COUNT(r.rental_id) AS count_rentals
    FROM Books b
    LEFT JOIN Rentals r ON b.book_id = r.book_id
    GROUP BY b.book_id
    )
    SELECT
        book_id,
        title,
        count_rentals,
        RANK() OVER (ORDER BY count_rentals DESC) AS rental_rank
    FROM Book_Rentals_CTE
    ORDER BY rental_rank
) TO '/tmp/3.csv' WITH CSV HEADER;
