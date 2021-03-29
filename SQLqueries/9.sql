/*get user issues by description*/

/*findByDescriptionAndDeletedAtIsNull*/
SELECT * FROM reads_contanct_us WHERE deleted_at is null and description =:description