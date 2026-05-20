-- Enable pg_hint_plan extension
CREATE EXTENSION IF NOT EXISTS pg_hint_plan;

DROP TABLE IF EXISTS departments;
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name TEXT
);

DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name TEXT,
    age INT,
    dept_id INT REFERENCES departments(id)
);

DROP TABLE IF EXISTS projects;
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name TEXT,
    budget INT
);

DROP TABLE IF EXISTS works_on;
CREATE TABLE works_on (
    emp_id INT REFERENCES employees(id),
    proj_id INT REFERENCES projects(id),
    PRIMARY KEY (emp_id, proj_id)
);

INSERT INTO departments (name) VALUES ('Engineering'), ('HR'), ('Marketing');

INSERT INTO employees (name, age, dept_id) VALUES
('Alice', 35, 1),
('Bob', 29, 2),
('Charlie', 40, 1),
('Diana', 32, 3),
('Ethan', 28, 2),
('Fiona', 45, 1),
('George', 38, 3),
('Hannah', 30, 2),
('Ian', 27, 1),
('Jasmine', 33, 3),
('Kevin', 31, 2),
('Laura', 36, 1),
('Mike', 29, 3),
('Nina', 34, 2),
('Oscar', 41, 1),
('Paula', 37, 3),
('Quentin', 26, 2),
('Rachel', 39, 1),
('Steve', 30, 3),
('Tina', 28, 2),
('Uma', 42, 1),
('Vera', 35, 3),
('Will', 31, 2),
('Xena', 29, 1),
('Yara', 34, 3),
('Zane', 38, 2);

INSERT INTO projects (name, budget) VALUES
('Project Alpha', 100000),
('Project Beta', 50000),
('Project Gamma', 75000);

INSERT INTO works_on (emp_id, proj_id) VALUES
(1, 1), (2, 1), (3, 2),
(4, 2), (5, 3), (6, 1),
(7, 3), (8, 2), (9, 1),
(10, 3), (11, 2), (12, 1);

ANALYZE;