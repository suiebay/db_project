/*search for groups by title*/

/*findAllByDeletedAtIsNullOrderByTitle*/
SELECT * FROM reads_group WHERE deleted_at is null order by title