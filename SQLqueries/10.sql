/*search for users, ordered by got points*/

/*findAllReadersPlace*/
SELECT * FROM profiles AS u
INNER JOIN users_roles ON u.id = users_roles.user_id
INNER JOIN roles ON users_roles.role_id = roles.id
WHERE roles.name = :role AND u.deleted_at IS NULL
ORDER BY u.reads_point DESC, u.id
