-- Write the query to create the 4 tables below.

CREATE TABLE client (
  id int(11) NOT NULL AUTO_INCREMENT,
  first_name varchar(255) NOT NULL,
  last_name varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  CONSTRAINT full_name UNIQUE (first_name, last_name),
  PRIMARY KEY (id)
);

CREATE TABLE employee (
    id int(11) NOT NULL AUTO_INCREMENT,
    first_name varchar(255),
    last_name varchar(255),
    start_date date NOT NULL,
    email varchar(255), NOT NULL,
    CONSTRAINT full_name UNIQUE (first_name, last_name),
    PRIMARY KEY (id)
);

CREATE TABLE project (
    id int(11) NOT NULL AUTO_INCREMENT,
    title varchar(255) NOT NULL UNIQUE,
    comments TEXT,
    cid int(11),
    FOREIGN KEY (cid) REFERENCES client(id),
    PRIMARY KEY id
);

CREATE TABLE works_on (
    pid int(11),
    eid int(11),
    due_date date NOT NULL,
    FOREIGN KEY (pid) REFERENCES project(id),
    FOREIGN KEY (eid) REFERENCES employee(id),
    PRIMARY KEY (pid, eid)
);