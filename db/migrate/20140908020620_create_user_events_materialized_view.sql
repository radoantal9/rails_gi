select *, least(round(pages_completed*100.0/course_page_count, 0), 100) as percent_completed from 
(
	(
		select users.email as email, users.id, 'Yes' as registered, initcap(first_name) as first_name, initcap(last_name) as last_name, 
	  users.org_id,
	  'Enrolled' as status,  
	   courses.id as course_id, courses.title,  
	   -- Get # of content_page_end we have for the user (numerator), will be 0 if no pages
	   (
	   select count(*) from user_events 
	   where 
	    user_events.user_id = users.id and
	    user_events.course_id = courses.id and
	    user_events.event_type = 'content_page_end'
	   ) as pages_completed,

	  to_char(age(users.updated_at), 'FMDDD')::int as days_since_last_activity,
	  users.updated_at at time zone 'UTC' at time zone 'EST' as last_activity_timestamp_EST

	from users
	 left join user_events on (users.id = user_events.user_id) 
	 left join users_courses on users_courses.user_id = users.id
	 left join courses on courses.id = users_courses.course_id
	 join orgs on users.org_id = orgs.id and orgs.is_active in( 'true')

	group by
	 users.email, users.id, first_name, last_name,  users.org_id, 
	 courses.id, courses.title,
	 days_since_last_activity,
	 users.updated_at
	)
	
	UNION
	(
	-- All unaccepted invitations... As accepted ones are already accounted for in the user
	-- table above.  Note, the user may be in user table without having gone through
	-- invitation process.  Direct registration.
	select invitation_email as email, invitations.id, 'No' as registered, null as first_name, null as last_name, 
	 orgs_courses.org_id,
	 invitation_state || ' ' || sent_count || 'x' as status,
	 courses.id as course_id, courses.title, 
	 0 as pages_completed,

	  to_char(age(invitations.created_at), 'FMDDD')::int as days_since_last_activity,
	  invitations.updated_at as last_activity_timestamp_EST
	from invitations
	 left join orgs_courses on orgs_course_id = orgs_courses.id
	 left join courses on courses.id = orgs_courses.course_id
	 left join orgs on orgs.id = orgs_courses.org_id

	where 
	 invitation_state not in ('invitation_accepted')

	order by email
	)
)
 
as user_events_view
left join 
 -- Get # of pages in the course
 (
	   -- Get total number of pages in the course (denominator)
	   select courses.id as courses_id, courses.title as course_title, count(*) as course_page_count 
	   from course_pages, courses
	   where
	    course_pages.page_type='ContentPage' and 
	    courses.id = course_pages.course_id
	   group by
	    courses.id
	  ) 
	as t_course_pages on user_events_view.course_id = t_course_pages.courses_id


