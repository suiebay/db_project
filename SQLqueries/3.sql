/*search for books by title and author*/

/*findAllByTitleIgnoreCaseContainsOrAuthorIgnoreCaseContainsAndDeletedAtIsNull*/
SELECT * FROM reads_books WHERE deleted_at is null and lower(title) =: lower(title) and lower(author) =:  lower(author)