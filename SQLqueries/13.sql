/*get not finished, specific books data*/

/*findAllByBookIdAndEndDateIsNotNullAndDeletedAtIsNull*/
SELECT * FROM reads_user_book WHERE deleted_at is null and book_id =:bookId and end_date is not null