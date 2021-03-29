/*get group by id*/

/*findByIdAndDeletedAtIsNull*/
SELECT * FROM reads_group WHERE deleted_at is null and id =: id