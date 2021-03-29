/*search for books by category*/

/*findAllByCategoryAndDeletedAtIsNull*/
SELECT * FROM reads_books WHERE deleted_at is null and category =: category