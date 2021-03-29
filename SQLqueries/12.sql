/*get group by group's mentor id*/

/*findByMentorIdAndDeletedAtIsNull*/
SELECT * FROM reads_group WHERE deleted_at is null and mentor_id  =: mentorId