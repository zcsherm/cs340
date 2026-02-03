-- Write your queries to insert data here
INSERT INTO client (first_name, last_name, email)
VALUES
(
('Sara', 'Smith', 'smiths@hello.com'),
('Miguel', 'Cabrera', 'mc@hello.com'),
('Bo', "Chan'g", 'bochang@hello.com')
);

INSERT INTO employee (first_name, last_name, start_date, email)
VALUES (
    ('Ananya', 'Jaiswal', '2008-04-10','ajaiswal@hello.com'),
    ('Michael', 'Fern', '2015-07-19', 'michaelf@hello.com'),
    ('Abdul', 'Rehman','2018-02-27','rehman@hello.com')
)

INSERT INTO project (cid, title, comments) 
VALUES (
    ((SELECT id FROM client WHERE first_name = 'Sara' AND last_name ='Smith'), 'Diamond', 'Should be done by Jan 2019'),
    ((SELECT id FROM client WHERE first_name = 'Bo' AND last_name = "Chan'g"),"Chan'g", "Ongoing Maintenance"),
    ((SELECT id FROM client WHERE first_name = 'Miguel' AND last_name ='Cabrera'), 'The Robinson Project',NULL)
);

INSERT INTO works_on (eid, pid, due_date)
VALUES (
    ((SELECT cid FROM employee WHERE first_name = 'Sara' AND last_name ='Smith'), 'Diamond', 'Should be done by Jan 2019'),
    ((SELECT cid FROM employee WHERE first_name = 'Bo' AND last_name = "Chan'g"),"Chian'g", "Ongoing Maintenance"),
    ((SELECT cid FROM employee WHERE first_name = 'Miguel' AND last_name ='Cabrera'), 'The Robinson Project',NULL)
);