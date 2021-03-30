/* search for users by specific text*/

/* findAllReadersBySearch*/
SELECT * FROM profiles  AS u
INNER JOIN users_roles ON u.id = users_roles.user_id
INNER JOIN roles ON users_roles.role_id = roles.id
WHERE roles.name = :role AND u.deleted_at IS NULL
AND (LOWER (u.first_name) LIKE LOWER (:word)
OR LOWER (u.last_name) LIKE LOWER(:word)
OR LOWER (u.middle_name) LIKE LOWER(:word))
ORDER BY u.reads_point DESC, u.id
