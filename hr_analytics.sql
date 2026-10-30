-- Q1: Cədvəlin yaradılması və binary Attrition Flag sütununun əlavə olunması
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    Age INT,
    Attrition VARCHAR(10),
    BusinessTravel VARCHAR(50),
    DailyRate INT,
    Department VARCHAR(50),
    DistanceFromHome INT,
    Education INT,
    EducationField VARCHAR(50),
    EmployeeCount INT,
    EmployeeNumber INT PRIMARY KEY,
    EnvironmentSatisfaction INT,
    Gender VARCHAR(10),
    HourlyRate INT,
    JobInvolvement INT,
    JobLevel INT,
    JobRole VARCHAR(50),
    JobSatisfaction INT,
    MaritalStatus VARCHAR(50),
    MonthlyIncome INT,
    MonthlyRate INT,
    NumCompaniesWorked INT,
    Over18 VARCHAR(5),
    OverTime VARCHAR(5),
    PercentSalaryHike INT,
    PerformanceRating INT,
    RelationshipSatisfaction INT,
    StandardHours INT,
    StockOptionLevel INT,
    TotalWorkingYears INT,
    TrainingTimesLastYear INT,
    WorkLifeBalance INT,
    YearsAtCompany INT,
    YearsInCurrentRole INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT
);

-- Attrition Yes olduqda 1, No olduqda 0 dəyəri veririk
ALTER TABLE employees ADD COLUMN attrition_flag INT;
UPDATE employees SET attrition_flag = CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END;

-- Q2: Bazada unikal işçi sayını, null deyerlerin olub-olmamasini ve umumi ayrilma faizini tapiriq
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT EmployeeNumber) AS unique_employees,
    SUM(CASE WHEN EmployeeNumber IS NULL THEN 1 ELSE 0 END) AS null_employee_numbers,
    SUM(attrition_flag) AS total_attritions,
    ROUND(AVG(attrition_flag) * 100, 2) AS overall_attrition_rate_pct
FROM employees;

-- Q3: Şirkətdən ayrılan və qalan işçilərin KPI müqayisəsi
SELECT 
    Attrition AS attrition_status,
    COUNT(*) AS headcount,
    SUM(attrition_flag) AS total_attritions,
    ROUND(AVG(MonthlyIncome), 2) AS avg_monthly_income,
    ROUND(AVG(YearsAtCompany), 2) AS avg_years_at_company,
    ROUND(AVG(JobSatisfaction), 2) AS avg_job_satisfaction
FROM employees
GROUP BY Attrition;

-- Q4: Şöbələr üzrə Attrition Rate
SELECT -- Hansı şöbədə işdən çıxma riskinin daha yüksək olduğunu müəyyən etmək.
    Department,
    COUNT(*) AS headcount,
    SUM(attrition_flag) AS attritions,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY Department
ORDER BY attrition_rate_pct DESC;


-- Q5: Vəzifələr üzrə Attrition Rate (İşçi sayı >= 30 olanlar)
SELECT 
    JobRole,
    COUNT(*) AS headcount,
    SUM(attrition_flag) AS attritions,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY JobRole
HAVING COUNT(*) >= 30
ORDER BY attrition_rate_pct DESC;


-- Q6: Müxtəlif sosial və iş faktorları üzrə göstəricilər
SELECT 'OverTime' AS dimension, OverTime AS category, COUNT(*) AS headcount, SUM(attrition_flag) AS attritions, ROUND(SUM(attrition_flag)*100.0/COUNT(*),2) AS attrition_rate FROM employees GROUP BY OverTime
UNION ALL
SELECT 'MaritalStatus', MaritalStatus, COUNT(*), SUM(attrition_flag), ROUND(SUM(attrition_flag)*100.0/COUNT(*),2) FROM employees GROUP BY MaritalStatus
UNION ALL
SELECT 'BusinessTravel', BusinessTravel, COUNT(*), SUM(attrition_flag), ROUND(SUM(attrition_flag)*100.0/COUNT(*),2) FROM employees GROUP BY BusinessTravel
UNION ALL
SELECT 'Gender', Gender, COUNT(*), SUM(attrition_flag), ROUND(SUM(attrition_flag)*100.0/COUNT(*),2) FROM employees GROUP BY Gender
ORDER BY dimension, attrition_rate DESC;


-- Q7: Staj qrupları (Tenure Bands) üzrə analitik baxış
SELECT 
    CASE 
        WHEN YearsAtCompany BETWEEN 0 AND 2 THEN '0-2 years'
        WHEN YearsAtCompany BETWEEN 3 AND 5 THEN '3-5 years'
        WHEN YearsAtCompany BETWEEN 6 AND 10 THEN '6-10 years'
        ELSE '11+ years'
    END AS tenure_band,
    COUNT(*) AS headcount,
    SUM(attrition_flag) AS attritions,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY tenure_band
ORDER BY attrition_rate_pct DESC;


-- Q8: Gəlir kvartilləri (Income Quartiles) üzrə analiz
WITH income_ranked AS (
    SELECT 
        attrition_flag,
        MonthlyIncome,
        NTILE(4) OVER (ORDER BY MonthlyIncome) AS income_quartile
    FROM employees
)
SELECT 
    'Q' || income_quartile AS income_quartile,
    COUNT(*) AS headcount,
    SUM(attrition_flag) AS attritions,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM income_ranked
GROUP BY income_quartile
ORDER BY income_quartile;


-- Q9: Pivot - Department x JobSatisfaction (1-4) Attrition Rate (%)
SELECT 
    Department,
    ROUND(SUM(CASE WHEN JobSatisfaction = 1 THEN attrition_flag * 100.0 ELSE 0 END) / NULLIF(SUM(CASE WHEN JobSatisfaction = 1 THEN 1 ELSE 0 END), 0), 2) AS js_1_rate,
    ROUND(SUM(CASE WHEN JobSatisfaction = 2 THEN attrition_flag * 100.0 ELSE 0 END) / NULLIF(SUM(CASE WHEN JobSatisfaction = 2 THEN 1 ELSE 0 END), 0), 2) AS js_3_rate,
    ROUND(SUM(CASE WHEN JobSatisfaction = 3 THEN attrition_flag * 100.0 ELSE 0 END) / NULLIF(SUM(CASE WHEN JobSatisfaction = 3 THEN 1 ELSE 0 END), 0), 2) AS js_3_rate,
    ROUND(SUM(CASE WHEN JobSatisfaction = 4 THEN attrition_flag * 100.0 ELSE 0 END) / NULLIF(SUM(CASE WHEN JobSatisfaction = 4 THEN 1 ELSE 0 END), 0), 2) AS js_4_rate
FROM employees
GROUP BY Department;


-- Q10: Pivot - Department x WorkLifeBalance (1-4) Attrition Rate (%)
SELECT 
    Department,
    ROUND(SUM(CASE WHEN WorkLifeBalance = 1 THEN attrition_flag * 100.0 ELSE 0 END) / NULLIF(SUM(CASE WHEN WorkLifeBalance = 1 THEN 1 ELSE 0 END), 0), 2) AS wlb_1_rate,
    ROUND(SUM(CASE WHEN WorkLifeBalance = 2 THEN attrition_flag * 100.0 ELSE 0 END) / NULLIF(SUM(CASE WHEN WorkLifeBalance = 2 THEN 1 ELSE 0 END), 0), 2) AS wlb_2_rate,
    ROUND(SUM(CASE WHEN WorkLifeBalance = 3 THEN attrition_flag * 100.0 ELSE 0 END) / NULLIF(SUM(CASE WHEN WorkLifeBalance = 3 THEN 1 ELSE 0 END), 0), 2) AS wlb_3_rate,
    ROUND(SUM(CASE WHEN WorkLifeBalance = 4 THEN attrition_flag * 100.0 ELSE 0 END) / NULLIF(SUM(CASE WHEN WorkLifeBalance = 4 THEN 1 ELSE 0 END), 0), 2) AS wlb_4_rate
FROM employees
GROUP BY Department;
