/*get users whose are silver graded(points between (300, 750) and finished books between(20, 50)*/

/*findSilverReaders*/
SELECT * FROM profiles  AS u
INNER JOIN users_roles ON u.id = users_roles.user_id
INNER JOIN roles ON users_roles.role_id = roles.id
WHERE u.reads_point >= 300 AND u.reads_finished_books >= 20
AND u.reads_reviews_number >= 20
AND (u.reads_point < 750 OR u.reads_finished_books < 50 OR u.reads_reviews_number < 50)
AND roles.name = :role AND u.deleted_at IS NULL
ORDER BY u.reads_point DESC, u.id
