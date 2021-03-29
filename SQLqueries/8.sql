/*findByIdAndDeletedAtIsNull*/
SELECT * FROM reads_contanct_us WHERE deleted_at is null and id =: id