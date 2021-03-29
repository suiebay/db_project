/*search for groups by title*/

/*findByTitleAndDeletedAtIsNull*/
SELECT * FROM reads_group WHERE deleted_at is null and title =: title


