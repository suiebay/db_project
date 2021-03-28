/* findAllByDeletedAtIsNull*/
SELECT * FROM reads_books WHERE deleted_at is null

/*findAllByCategoryAndDeletedAtIsNull*/
SELECT * FROM reads_books WHERE deleted_at is null and category =: category

/*findAllByTitleIgnoreCaseContainsOrAuthorIgnoreCaseContainsAndDeletedAtIsNull*/
SELECT * FROM reads_books WHERE deleted_at is null and lower(title) =: lower(title) and lower(author) =:  lower(author)

/*findByIdAndDeletedAtIsNull*/
SELECT * FROM reads_books WHERE deleted_at is null and id =: id

/*findById*/
SELECT * FROM reads_books WHERE  id =: id

/*findByTitleAndDeletedAtIsNull*/
SELECT * FROM reads_books WHERE  title := title and deleted_at is null

/*findAllByDeletedAtIsNull*/
SELECT * FROM reads_contanct_us WHERE  deleted_at is null

/*findByIdAndDeletedAtIsNull*/
SELECT * FROM reads_contanct_us WHERE deleted_at is null and id =: id

/*findByDescriptionAndDeletedAtIsNull*/
SELECT * FROM reads_contanct_us WHERE deleted_at is null and description =:description

/*findAllByDeletedAtIsNullOrderByTitle*/
SELECT * FROM reads_group WHERE deleted_at is null order by title

/*findByIdAndDeletedAtIsNull*/
SELECT * FROM reads_group WHERE deleted_at is null and id =: id

/*findByTitleAndDeletedAtIsNull*/
SELECT * FROM reads_group WHERE deleted_at is null and title =: title

/*findByMentorIdAndDeletedAtIsNull*/
SELECT * FROM reads_group WHERE deleted_at is null and mentor_id  =: mentorId 

/*findAllByProfileIdAndEndDateIsNotNullAndDeletedAtIsNull*/
SELECT * FROM reads_user_book WHERE deleted_at is null and profile_id =:profileId and end_date is not null

/*findAllByBookIdAndEndDateIsNotNullAndDeletedAtIsNull*/
SELECT * FROM reads_user_book WHERE deleted_at is null and book_id =:bookId and end_date is not null\

/*findByProfileIdAndEndDateIsNullAndDeletedAtIsNull*/
SELECT * FROM reads_user_book WHERE deleted_at is null and profile_id =:profileId and end_date is null


