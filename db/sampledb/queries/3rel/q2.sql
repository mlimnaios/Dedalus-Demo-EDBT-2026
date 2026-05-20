SELECT 
    e.name, d.name AS department
FROM employees e
JOIN departments d ON e.dept_id = d.id
JOIN works_on w ON e.id = w.emp_id