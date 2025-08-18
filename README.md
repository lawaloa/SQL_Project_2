# SQL PROJECT 2 | 💧 Maji Ndogo Water Services – SQL Data Analysis & Integrity Validation
---

## 📑 Table of Contents
---

1. [📘 Introduction – Setting the stage for our data exploration journey](#-introduction--setting-the-stage-for-our-data-exploration-journey)  
2. [🗂️ Cleaning Our Data – Updating employee data](#️-cleaning-our-data--updating-employee-data)  
3. [🙌 Honouring the Workers – Finding our best](#-honouring-the-workers--finding-our-best)  
4. [🌍 Analysing Locations – Understanding where the water sources are](#-analysing-locations--understanding-where-the-water-sources-are)  
5. [💦 Diving into the Sources – Seeing the scope of the problem](#-diving-into-the-sources--seeing-the-scope-of-the-problem)  
6. [🛠️ Start of a Solution – Thinking about how we can repair](#️-start-of-a-solution--thinking-about-how-we-can-repair)  
7. [📊 Analysing Queues – Uncovering when citizens collect water](#-analysing-queues--uncovering-when-citizens-collect-water)  
8. [📝 Reporting Insights – Assembling our insights into a story](#-reporting-insights--assembling-our-insights-into-a-story)  

---

## 📘 Introduction – Setting the stage for our data exploration journey
This project seeks to confront the pressing **Maji Ndogo water crisis** through the lens of **SQL analysis**.  
Rather than treating our dataset as disconnected numbers, we view it as a living story — each row and column carrying the experiences of citizens, workers, and communities.  

 Our mission is to:  
- Begin by **cleaning our data**, making sure employee records are accurate and complete.   
- Use clustering and aggregation to reveal systemic narratives.  
- Treat data with integrity by validating, auditing, and ensuring trustworthiness.  
- Provide both granular insights (individual sources, employees, queues) and a panoramic overview (locations, quality, availability).  

By weaving together details and broad patterns, this project aims not only to **understand the scope of the problem** but also to **inspire actionable solutions**.  

Skills Applied: SQL · Data Exploration · Data Cleaning & Integrity Validation · Aggregation & Filtering · Conditional Logic · Clustering & Pattern Detection · Insight Reporting
---

## 🗂️ Cleaning Our Data – Updating employee data
---

This was one of my favorite parts of the project because it reminded me that **data tells stories only when it’s clean and reliable**. In this section, I focused on improving the integrity of the **employee table** in our database.  

When I first pulled it up, I noticed something was missing: **email addresses**. Since we’ll need to send workers reports and figures, I had to generate the emails in a consistent format. Luckily, the convention for our department is straightforward: `first_name.last_name@ndogowater.gov`


### 🔧 My Approach  

To build these emails, I:  
- Selected the `employee_name` column.  
- Replaced the space in names with a full stop (`.`).  
- Converted everything to lowercase.  
- Concatenated it with `@ndogowater.gov`.  

Before updating the database permanently, I first tested the format with a `SELECT` query.  

```sql
-- Preview email format before updating
SELECT
    CONCAT(
        LOWER(REPLACE(employee_name, ' ', '.')),
        '@ndogowater.gov'
    ) AS new_email
FROM md_water_services.employee;
```

Once I confirmed the format, I updated the table:

```sql
SET SQL_SAFE_UPDATES = 0;

UPDATE md_water_services.employee
SET email = CONCAT(
    LOWER(REPLACE(employee_name, ' ', '.')),
    '@ndogowater.gov'
);
```

### 📱 Cleaning Phone Numbers

While reviewing the table, I also found another issue: **phone numbers**.
They should have been stored as 12 characters (`+99` + 9 digits), but when I checked with `LENGTH()`, they returned **13 characters** — meaning there was an extra space.

```sql
-- Check length of phone numbers
SELECT
    LENGTH(phone_number)
FROM md_water_services.employee;
```

To fix this, I applied the `TRIM()` function to remove unnecessary spaces and updated the records:

```sql
-- Remove unwanted spaces
UPDATE md_water_services.employee
SET phone_number = TRIM(phone_number);
```
✅ With these fixes, the employee table is now **clean, consistent, and ready** for the next stage of analysis.

---

## 🙌 Honouring the Workers – Finding our best
---

This part of the project was meaningful for me because it reminded me that behind every dataset are **real people** who made it possible.  
Before diving deeper into water analysis, I wanted to take a moment to **acknowledge our field workers** — the backbone of this survey.  

### 🏠 Where Do Our Employees Live?  
I started by exploring the `employee` table to see the distribution of employees across towns.  

```sql
SELECT
    town_name,
    COUNT(town_name) AS num_of_employees
FROM md_water_services.employee
GROUP BY town_name;
```

**Result sample:**

| town_name | num_of_employees |
|-----------|------------------|
| Ilanga    | 3                |
| Rural     | 29               |
| Lusaka    | 4                |
| Zanzibar  | 4                |
| Dahabu    | 6                |
| Kintampo  | 1                |
| Harare    | 5                |

➡️ A large share of our workers live in **smaller rural communities**, often far from central offices, yet they played a crucial role in gathering data under tough conditions.

### 🏅 Recognizing Top Field Surveyors

President Naledi personally asked that we recognize those who worked tirelessly in the field. To do this, I looked into the visits table to find the top 3 field surveyors based on the number of visits recorded.

```sql
SELECT
    assigned_employee_id,
    COUNT(visit_count) AS num_of_visits
FROM md_water_services.visits
GROUP BY assigned_employee_id
ORDER BY num_of_visits DESC
LIMIT 3;
```
**Result table:**

| assigned_employee_id | number_of_visits |
|-----------------------|------------------|
| 1                      | 3708             |
| 30                     | 3676             |
| 34                     | 3539             |


### 📧 Gathering Contact Info for Recognition

With the top surveyors identified, I then pulled their details from the `employee` table so that we could share their achievements and send congratulatory messages.

```sql
SELECT
    assigned_employee_id,
    employee_name,
    phone_number,
    email
FROM md_water_services.employee
WHERE assigned_employee_id IN (1, 30, 34);
```

**Result table:**

| assigned_employee_id | employee_name | phone_number  | email                        |
|-----------------------|---------------|---------------|------------------------------|
| 1                     | Bello Azibo   | +99643864786  | bello.azibo@ndogowater.gov   |
| 30                    | Pili Zola     | +99822478933  | pili.zola@ndogowater.gov     |
| 34                    | Rudo Imani    | +99046972648  | rudo.imani@ndogowater.gov    |

---

## 🌍 Analysing Locations – Understanding where the water sources are
Mapping the distribution of water sources, identifying underserved areas, and highlighting clusters that demand urgent attention.  

---

## 💦 Diving into the Sources – Seeing the scope of the problem
Analyzing the quality, reliability, and accessibility of each water source, while quantifying the true extent of the crisis.  

---

## 🛠️ Start of a Solution – Thinking about how we can repair
Exploring interventions such as infrastructure repairs, improved allocation, or resource optimization — modeled through SQL insights.  

---

## 📊 Analysing Queues – Uncovering when citizens collect water
Investigating collection patterns, peak demand times, and the stress they place on both citizens and infrastructure.  

---

## 📝 Reporting Insights – Assembling our insights into a story
Transforming raw queries into meaningful narratives that stakeholders can understand.  
Our final deliverable is not just a dataset, but a **story of resilience, challenge, and possibility**.  

---
