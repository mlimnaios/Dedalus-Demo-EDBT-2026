SELECT 
    e.name AS employee_name,
    d.name AS department_name,
    p.name AS project_name,
    mgr.name AS manager_name,
    p.budget
FROM employees e
JOIN departments d ON e.dept_id = d.id
JOIN works_on w ON e.id = w.emp_id
JOIN projects p ON w.proj_id = p.id
JOIN employees mgr ON mgr.dept_id = e.dept_id AND mgr.age > e.age
WHERE p.budget > 60000
  AND e.age > 25
  AND d.name <> 'HR'
