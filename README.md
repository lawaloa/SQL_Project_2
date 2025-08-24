# SQL PROJECT 2 | 💧 Maji Ndogo Water Services – SQL Data Analysis & Integrity Validation
---

## 📑 Table of Contents
---

1. [📘 Project Overview  – Setting the stage for our data exploration journey](#-project-overview--setting-the-stage-for-our-data-exploration-journey)  
2. [🗂️ Cleaning Our Data – Updating employee data](#️-cleaning-our-data--updating-employee-data)  
3. [🙌 Honouring the Workers – Finding our best](#-honouring-the-workers--finding-our-best)  
4. [🌍 Analysing Locations – Understanding where the water sources are](#-analysing-locations--understanding-where-the-water-sources-are)  
5. [💦 Diving into the Sources – Seeing the scope of the problem](#-diving-into-the-sources--seeing-the-scope-of-the-problem)  
6. [🛠️ Start of a Solution – Thinking about how we can repair](#️-start-of-a-solution--thinking-about-how-we-can-repair)  
7. [📊 Analysing Queues – Uncovering when citizens collect water](#-analysing-queues--uncovering-when-citizens-collect-water)  
8. [📝 Reporting Insights – Assembling our insights into a story](#-reporting-insights--assembling-our-insights-into-a-story)  

---

## 📘 Project Overview  – Setting the stage for our data exploration journey
--- 

This project is personal to me because it goes beyond running SQL queries — it’s about telling the story of the **Maji Ndogo water crisis** through data.  

When I first explored the dataset, I didn’t just see rows and columns. I saw communities waiting in long queues, families depending on unsafe water, and field workers trying their best to bridge a massive gap.  

Here’s how I approached it:  
- I started by **cleaning and validating the data** to make sure the foundation was trustworthy.  
- Then, I used **clustering and aggregation** to uncover the bigger narratives hidden beneath isolated records.  
- I treated each data point as someone’s lived experience — not just a number — which made **integrity checks and auditing** essential.  
- Finally, I zoomed in on both **granular details** (individual sources, employees, queues) and the **big picture** (provincial coverage, quality, and availability).  

For me, this project isn’t just about technical SQL skills. It’s about showing how **data can become a voice** — turning hidden patterns into insights that can guide real-world solutions for the communities who need them most.  


**Skills Applied:** SQL · Data Aggregation · Counting · Grouping · Filtering · Data Validation

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
---

This part of the project was personal for me. I wanted to step into the shoes of the surveyors, to understand **where exactly the water sources are in Maji Ndogo**. By digging into the `location` table and focusing on `province_name`, `town_name`, and `location_type`, I could begin to see the bigger picture of our water distribution.  

---

### 🏘 Records per Town  

To start, I wrote a query to count the number of records for each town:  

```sql
SELECT
	COUNT(town_name) AS records_per_town,
    town_name
FROM md_water_services.location
GROUP BY town_name
ORDER BY records_per_town DESC;
```

**Results sample:**  

| records_per_town | town_name |
|------------------|-----------|
| 23740            | Rural     |
| 1650             | Harare    |
| 1090             | Amina     |
| 1070             | Lusaka    |
| 990              | Mrembo    |
| 930              | Asmara    |
| ...              | ...       |

> At this point, it became clear to me that **the majority of water sources are concentrated in small rural communities**, scattered across Maji Ndogo.


### 🗺 Records per Province

Next, I wanted to zoom out and see the provincial picture.

```sql
SELECT
	COUNT(town_name) AS records_per_province,
    province_name
FROM md_water_services.location
GROUP BY province_name
ORDER BY records_per_province DESC;
```

**Results sample:**  

| records_per_province | province_name |
|-----------------------|---------------|
| 9510                 | Kilimani      |
| 8940                 | Akatsi        |
| 8220                 | Sokoto        |
| 6950                 | Amanzi        |
| 6030                 | Hawassa       |
| ...                   | ...           |

> This showed me that every province is well represented in the dataset — giving me confidence that the survey work was thorough and reliable.

### 📊 Province + Town Breakdown

To go deeper, I combined both `province_name` and `town_name` to see how records were distributed within provinces.

```sql
SELECT
    province_name,
    town_name,
    COUNT(town_name) AS records_per_town
FROM
    md_water_services.location
GROUP BY
    province_name,
    town_name
ORDER BY
    province_name ASC,
    records_per_town DESC;
```

**Results sample:**  

| province_name | town_name | records_per_town |
|---------------|-----------|------------------|
| Akatsi        | Rural     | 6290             |
| Akatsi        | Lusaka    | 1070             |
| Akatsi        | Harare    | 800              |
| Akatsi        | Kintampo  | 780              |
| Amanzi        | Rural     | 3100             |
| Amanzi        | Asmara    | 930              |

> These results reassured me: our field surveyors did an excellent job documenting the country’s water crisis across every province and town.

### 🏞 Location Type Breakdown

Finally, I wanted to compare **urban vs rural sources**.

```sql
SELECT
	COUNT(location_type) AS num_sources,
    location_type
FROM md_water_services.location
GROUP BY location_type;
```

**Results:**  

| num_sources | location_type |
|-------------|---------------|
| 15910       | Urban         |
| 23740       | Rural         |

> Numbers alone don’t always tell the story, so I converted this into percentages:

```sql
SELECT 23740 / (15910 + 23740) * 100;
```

> 👉 **60% of all water sources are in rural communities**.

> 💡 **Insights:**
>  
> - The dataset properly canvassed the entire country, reflecting the situation on the ground.  
> - 60% of water sources are in rural areas — which means any solutions must be designed with these communities in mind.  
> - The even provincial distribution builds confidence in the integrity of the dataset.  
>   
> For me, this analysis was more than just numbers. It showed how data can be transformed into trustworthy narratives about real communities and their struggles.  

---

## 💦 Diving into the Sources – Seeing the scope of the problem
---

The **`water_source`** table is one of the largest in this dataset — and for me, it felt like the heart of the whole project. 🚰  

When I first opened it, I didn’t just see rows and columns — I saw stories of families, communities, and how they access something as basic (yet vital) as water.  

To really understand it, I took some time to **explore the table myself**: scanning through the columns, scribbling notes, and running queries to see what patterns would emerge.  

From this table, I could uncover two powerful pieces of information:  
- The **different types of water sources** available in Maji Ndogo  
- The **number of people depending on each one**  

---

### 🔍 Key Questions I Explored  

1. **How many people were actually surveyed in total?**  
2. **How many wells, taps, and rivers do we have recorded?**  
3. **On average, how many people share each type of water source?**  
4. **And importantly, how many people in total are served by each water source type?**  
---

#### 📝 1. Total Number of People Surveyed  
---

```sql
SELECT 
    SUM(number_of_people_served) AS num_of_surveyed
FROM md_water_services.water_source;
```  
**Result:** ~27 million citizens surveyed across Maji Ndogo.

#### 📝 2. Number of Sources
---

```sql
SELECT
    type_of_water_source,
    COUNT(type_of_water_source) AS num_of_source
FROM md_water_services.water_source
GROUP BY type_of_water_source
ORDER BY num_of_source DESC;
```

**Results Sample:**

| type_of_water_source     | num_of_sources |
|--------------------------|----------------|
| well                     | 17383          |
|  tap_in_home             | 7265           |
| tap_in_home_broken       | 5856           |
| shared_tap               | 5767           |
|   river                  | 3379           |


 #### 📝 3. Average People per Source
---

```sql
SELECT 
    type_of_water_source,
    ROUND(AVG(number_of_people_served)) AS avg_served_per_source
FROM md_water_services.water_source
GROUP BY type_of_water_source;
```

**Results Sample:** Average People per Source

| type_of_water_source   | avg_served_per_source  |
|------------------------|------------------------|
| tap_in_home            | 644                    |
| tap_in_home_broken     | 649                    |
| well                   | 279                    |
| shared_tap             | 2071                   |
| river                  | 699                    |

> [!IMPORTANT]
> **At first glance, this looks strange:**  
> Does a home tap really serve 644 people? Of course not.  
> Here's the catch: surveyors grouped multiple households into a single `tap_in_home` record.  
> With ~6 people per household, one entry of “644 people” actually represents about 100 taps.
>
> 💡 **Lesson Learned**  
> Data isn’t just numbers — its real value comes from interpretation.  
> Presenting raw figures to policymakers without context can be misleading.  
> Imagine being asked, “Why does it say 644 people share one home tap?” Without proper explanation, we’d have no good answer.
>
> ✅ **Clarified Insight**  
> Now the numbers make more sense: wells appear less pressured,  
> but public shared taps are under immense strain — serving over **2,000 people per tap**.

#### 📝 4. Total Population Served by Each Source
---

```sql
SELECT 
    type_of_water_source,
    SUM(number_of_people_served) AS population_served
FROM md_water_services.water_source
GROUP BY type_of_water_source
ORDER BY population_served DESC;
```

💧 **Water Source Coverage:**

<a name="my-table"></a>

| type_of_water_source     | population_served|
|--------------------------|-----------------|
| Shared Tap               | 11945272        |
| Well                     | 4841724         |
| Tap in Home              | 4678880         |
| Tap in Home (Broken)     | 3799720         |
| River                    | 2362544         |

It’s hard to grasp raw totals — so I converted them into percentages.

#### 📝 5. Percentages of People Served
---

```sql
SELECT 
    type_of_water_source,
    SUM(number_of_people_served) AS Total_served_per_source,
    ROUND(
        (SUM(number_of_people_served) * 100.0 / 
            (SELECT SUM(number_of_people_served) 
             FROM md_water_services.water_source))
    ) AS Pct_served_per_source
FROM md_water_services.water_source
GROUP BY type_of_water_source
ORDER BY Pct_served_per_source DESC;
```

💧 **Water Source Distribution by Percentage:**

| type_of_water_source     | Pct_served_per_source |
|--------------------------|-----------------------|
| Shared Tap               | 43%                   |
| Well                     | 18%                   |
| Tap in Home              | 17%                   |
| Tap in Home (Broken)     | 14%                   |
| River                    | 9%                    |

#### 📘 Making Sense of It

- **43%** of people rely on shared taps, with ~2,000 people per tap.  
  This explains the long queues we observed earlier.

- **31%** of people have taps in their homes — but almost half of them don’t work.  
  The issue isn’t the taps themselves, but the infrastructure behind them: treatment plants, pipes, and pumps.

- **18%** of people use wells, but only **28%** are clean — a major public health challenge.

---

##### 💡 Insights

- Shared taps are under the most pressure and should be the top priority for upgrades.

- Broken infrastructure is locking millions out of water access, even where taps exist.

- This dataset doesn’t just give statistics — it reflects the lived reality of communities struggling with water.

> For me, this was more than SQL queries.  
> It was about turning rows of data into a narrative of who gets water, how, and at what cost to their daily lives.

---

## 🛠️ Start of a Solution – Thinking about how we can repair
---

Looking at the water crisis, one thing became clear to me:  
💭 *we can’t fix everything at once.*  

So, I asked myself a simple but important question:  
**Where should we start to make the biggest impact?**  

My guiding principle was:  
👉 **Fix the water sources that serve the most people first.**

That way, every improvement reaches as many lives as possible.  

To do this, I turned to one of my favorite SQL tools: the `RANK()` window function. It allows me to order water sources by the total number of people depending on them.  

---

### 🔹 Step 1: Identify What Matters  

To answer this, I needed three key things:  

- The **type of water source** ✅  
- The **total population served per source type** ✅  
- A **rank that shows priority** 🔑  

---

### 🔹 Step 2: Explore the Data  

Here’s a quick snapshot of what I found:  

See the [table here](#my-table) for more details.

| type_of_water_source  | population_served |
|------------------------|------------------|
| shared_tap             | 11945272        |
| well                   | 4841724         |
| tap_in_home            | 4678880         |
| tap_in_home_broken     | 3799720         |
| river                  | 2362544         |


Right away, **shared taps** stood out as the lifeline for millions of people, followed by **wells** and **broken taps**.  

But since *tap_in_home* already represents the ideal solution, I decided to **exclude it from the ranking**.  

---

### 🔹 Step 3: Ranking with SQL  

Here’s the query I used:  

```sql
SELECT  
    type_of_water_source,  
    SUM(number_of_people_served) AS Total_served_per_source,  
    RANK() OVER (  
        ORDER BY SUM(number_of_people_served) DESC  
    ) AS Rank_by_population  
FROM   
    md_water_services.water_source  
GROUP BY   
    type_of_water_source;
 

---

## 📊 Analysing Queues – Uncovering when citizens collect water
Investigating collection patterns, peak demand times, and the stress they place on both citizens and infrastructure.  

---

## 📝 Reporting Insights – Assembling our insights into a story
Transforming raw queries into meaningful narratives that stakeholders can understand.  
Our final deliverable is not just a dataset, but a **story of resilience, challenge, and possibility**.  

---
