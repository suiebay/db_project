/*get user's not finished books*/

/*findByProfileIdAndEndDateIsNullAndDeletedAtIsNull*/
SELECT * FROM reads_user_book WHERE deleted_at is null and profile_id =:profileId and end_date is null