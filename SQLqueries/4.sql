/*get books by id*/

/*findByIdAndDeletedAtIsNull*/
SELECT * FROM reads_books WHERE deleted_at is null and id =: id