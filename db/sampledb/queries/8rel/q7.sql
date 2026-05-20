SELECT 
    e.name, d.name AS dept, 
    p.name AS project, 
    mgr.name AS manager, 
    senior.name AS senior_emp, 
    jr.name AS junior_emp, 
    peer.name AS peer_emp 
FROM employees e 
JOIN departments d ON e.dept_id = d.id 
JOIN works_on w ON e.id = w.emp_id 
JOIN projects p ON w.proj_id = p.id 
JOIN employees mgr ON mgr.dept_id = e.dept_id AND mgr.age > e.age 
JOIN employees senior ON senior.dept_id = d.id AND senior.age > mgr.age 
JOIN employees jr ON jr.dept_id = d.id AND jr.age < e.age 
JOIN employees peer ON peer.dept_id = d.id AND peer.age BETWEEN jr.age AND e.age 
WHERE p.budget > 60000 
    AND e.age > 25 
    AND d.name <> 'HR'