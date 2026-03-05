-- Create Database
CREATE DATABASE hr_analytics;
USE hr_analytics;

-- Table for HR_1 Data
CREATE TABLE hr_1 (
    Age int,
    Attrition varchar(10),
    BusinessTravel varchar(50),
    DailyRate int,
    Department varchar(50),
    DistanceFromHome int,
    Education int,
    EducationField varchar(50),
    EmployeeCount int,
    EmployeeNumber int primary key,
    EnvironmentSatisfaction int,
    Gender varchar(20),
    HourlyRate int,
    JobInvolvement int,
    JobLevel int,
    JobRole varchar(50),
    JobSatisfaction int,
    MaritalStatus varchar(20)
);

-- Table for HR_2 Data
CREATE TABLE hr_2 (
    EmployeeID int primary key,
    MonthlyIncome int,
    MonthlyRate int,
    NumCompaniesWorked int,
    Over18 varchar(10),
    OverTime varchar(10),
    PercentSalaryHike int,
    PerformanceRating int,
    RelationshipSatisfaction int,
    StandardHours int,
    StockOptionLevel int,
    TotalWorkingYears int,
    TrainingTimesLastYear int,
    WorkLifeBalance int,
    YearsAtCompany int,
    YearsInCurrentRole int,
    YearsSinceLastPromotion int,
    YearsWithCurrManager int
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/HR_1.csv'
INTO TABLE hr_1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/HR_2.csv'
INTO TABLE hr_2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from hr_1;
select * from hr_2;


----- Join hr_1 and hr_2
CREATE TABLE hr_full AS
SELECT 
    h1.*, 
    -- selecting specific columns from h2 to avoid duplicating the ID
    h2.MonthlyIncome,
    h2.MonthlyRate,
    h2.NumCompaniesWorked,
    h2.Over18,
    h2.OverTime,
    h2.PercentSalaryHike,
    h2.PerformanceRating,
    h2.RelationshipSatisfaction,
    h2.StandardHours,
    h2.StockOptionLevel,
    h2.TotalWorkingYears,
    h2.TrainingTimesLastYear,
    h2.WorkLifeBalance,
    h2.YearsAtCompany,
    h2.YearsInCurrentRole,
    h2.YearsSinceLastPromotion,
    h2.YearsWithCurrManager
FROM hr_1 h1
JOIN hr_2 h2 ON h1.EmployeeNumber = h2.EmployeeID;

select * from hr_full;

USE hr_analytics;
select * from hr_full;

-- KPI 1 Average Attrition rate for all Departments
SELECT 
    Department, 
    ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN 1.0 ELSE 0.0 END) * 100, 2) AS Average_Attrition_Rate
FROM hr_1
GROUP BY Department
ORDER BY Average_Attrition_Rate DESC;

-- KPI 2 Average hourly Rate of Male Research Scientist

SELECT 
COUNT(*) AS Total_Male_RS,
ROUND(AVG(HourlyRate), 2) AS Avg_Hourly_Rate
FROM hr_full
WHERE Gender = 'Male'
AND JobRole = 'Research Scientist';

-- KPI 3 Attrition Rate vs Monthly income Stats

SELECT
CASE
    WHEN MonthlyIncome < 10000 THEN '1-10000'
    WHEN MonthlyIncome BETWEEN 10001 AND 20000 THEN '10001-20000'
    WHEN MonthlyIncome BETWEEN 20001 AND 30000 THEN '20001-30000'
    WHEN MonthlyIncome BETWEEN 30001 AND 40000 THEN '30001-40000'
    WHEN MonthlyIncome BETWEEN 40001 AND 50000 THEN '40001-50000'
    ELSE '50001-60000'
END AS IncomeGroup,
concat(
   ROUND(AVG(CASE WHEN Attrition='Yes' THEN 1.0 ELSE 0.0 END) * 100,2),'%') AS Attrition_Rate
   FROM hr_full
   GROUP BY IncomeGroup
   ORDER BY IncomeGroup;

   -- KPI 4 Average working years for each Department

SELECT 
    Department,
    round(AVG(TotalWorkingYears),2) AS Avg_Working_Years
FROM hr_full
GROUP BY Department;

-- KPI 5 Job Role Vs Work life balance

SELECT 
    hr.JobRole,
    ROUND(AVG(hr.WorkLifeBalance), 2) AS Avg_WorkLifeBalance
FROM hr_full AS hr
GROUP BY hr.JobRole
ORDER BY Avg_WorkLifeBalance DESC;

-- KPI 6 Attrition rate Vs Year since last promotion relation

select max(yearsSincelastpromotion) from hr_full;

SELECT 
    CASE 
        WHEN YearsSinceLastPromotion between 0 and 10 THEN '0-10'
        WHEN YearsSinceLastPromotion BETWEEN 11 AND 20 THEN '11-20'
        WHEN YearsSinceLastPromotion BETWEEN 21 AND 30 THEN '21-30'
        ELSE '31-40' 
    END AS Yrs_since_last_Promotion,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmployeeNumber), 
        2
    ) AS AttritionRatePercentage
FROM 
    hr_full
GROUP BY 
    CASE 
    WHEN YearsSinceLastPromotion between 0 and 10 THEN '0-10'
        WHEN YearsSinceLastPromotion BETWEEN 11 AND 20 THEN '11-20'
        WHEN YearsSinceLastPromotion BETWEEN 21 AND 30 THEN '21-30'
        ELSE '31-40'         
    END
ORDER BY 1;
    

-- KPI 7 Total Attrition by Employee Education

select educationfield,
sum(case when attrition = "yes" then 1 else 0 end)
 * 100.0 / count(employeenumber)
  AS Attrition_rate 
  from HR_full
  group	by 1
  order by 2 asc;

-- KPI 8 Marital Status and Monthly Income vs Attrition Rate
SELECT 
    MaritalStatus,
    CASE 
        WHEN MonthlyIncome <11000 THEN '<11k'
        WHEN MonthlyIncome BETWEEN 11001 AND 21000 THEN '11k-21K'
        WHEN MonthlyIncome BETWEEN 21001 and 31000 then '21k-31k'
        WHEN MonthlyIncome BETWEEN 31001 and 41000 then '31k-41k'
        ELSE '>41k'
    END AS IncomeBracket,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition ="yes" THEN 1 ELSE 0 END) AS AttritionCount,
    ROUND(SUM(CASE WHEN Attrition = "yes" THEN 1 ELSE 0 END) * 100.0 / COUNT(employeenumber), 2) AS AttritionRatePercent
FROM 
    hr_full
GROUP BY 
    MaritalStatus,
    CASE 
		WHEN MonthlyIncome < 11000 THEN "<11k"
		WHEN MonthlyIncome BETWEEN 11001 AND 21000 THEN "11k-21K"
		WHEN MonthlyIncome BETWEEN 21001 and 31000 then "21k-31k"
		WHEN MonthlyIncome BETWEEN 31001 and 41000 then "31k-41k"
		ELSE ">41k"
    END
ORDER BY 
    MaritalStatus asc, 
    IncomeBracket;
    
    # End