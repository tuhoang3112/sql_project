![image](https://github.com/user-attachments/assets/0c6cc3bd-1082-452e-b032-3685bd226932)# SQL Portfolio Project: Data Cleaning & Data Exploration (Using MySQL)

Credit to: Self-study Data Discord Group for Dataset provider

## Details about dataset:

**Table: worldlifeexpectancy**

This table contains various health and socioeconomic indicators for different countries across multiple years. Here's a breakdown of the columns:

- **Country:** The name of the country.
- **Year:** The year the data was recorded.
- **Status:** The development status of the country.
- **Lifeexpectancy:** The average life expectancy in the country for the given year.
- **AdultMortality:** The adult mortality rate, which represents the number of deaths of adults per 1,000 people.
- **infantdeaths:** The number of infant deaths per 1,000 live births.
- **percentageexpenditure:** The percentage of total expenditure on healthcare as a proportion of GDP.
- **Measles:** The number of reported measles cases.
- **BMI:** The average Body Mass Index in the country.
- **under-fivedeaths:** The number of deaths of children under five years old per 1,000 live births.
- **Polio:** The number of reported polio cases.
- **Diphtheria:** The number of reported diphtheria cases.
- **HIVAIDS:** The prevalence rate of HIV/AIDS.
- **GDP:** The Gross Domestic Product of the country.
- **thinness-1-19years:** The prevalence of thinness among children and adolescents aged 1-19 years.
- **thinness-5-9years:** The prevalence of thinness among children aged 5-9 years.
- **Schooling:** The average number of years of schooling received by people aged 25 and older.
- **Row_ID:** A unique identifier for each row in the dataset.

## Task 1: Data Cleaning

**1. Handling Missing Values:**
- Identify missing values in the dataset.
- Decide on strategies to handle missing values.

**2. Data Consistency:**
- Check for and correct inconsistencies in categorical columns like Country and Status.

**3. Removing Duplicates:**
- Identify and remove duplicate rows if any.

**4. Outlier Detection and Treatment:**
- Identify and treat outliers in columns like Lifeexpectancy, AdultMortality, and GDP.
- Decide on strategies to handle outlier (e.g., avg).

## Task 2: EDA
Perform exploratory data analysis (EDA) to extract meaningful insights:

**1. Basic Descriptive Statistics:**
Query to get the avg, mean, median, minimum, and maximum of the Lifeexpectancy for each Country.

**2. Trend Analysis:**
Query to find the trend of Lifeexpectancy over the years for a specific country (e.g., Afghanistan).

**3. Comparative Analysis:**
Query to compare the average Lifeexpectancy between Developed and Developing countries for the latest available year.

**4. Mortality Analysis:**
Query to calculate the correlation between AdultMortality and Lifeexpectancy for all countries.

**5. Impact of GDP:**
Query to find the average Lifeexpectancy of countries grouped by their GDP ranges (e.g., low, medium, high which is you decided).

**6. Disease Impact:**
Query to analyze the impact of Measles and Polio on Lifeexpectancy. Calculate average life expectancy for countries with high and low incidence rates of these diseases.

**7. Schooling and Health:**
Query to determine the relationship between Schooling and Lifeexpectancy. Find countries with the highest and lowest schooling and their respective life expectancies.

**8. BMI Trends:**
Query to find the average BMI trend over the years for a particular country.

**9. Infant Mortality:**
Query to find the average number of infantdeaths and under-fivedeaths for countries with the highest and lowest life expectancies.

**10. Rolling Average of Adult Mortality:**
Query to calculate the rolling average of AdultMortality over a 5-year window for each country. This will help in understanding the trend and smoothing out short-term fluctuations.

**11. Impact of Healthcare Expenditure:**
Query to find the correlation between percentageexpenditure (healthcare expenditure) and Lifeexpectancy. Higher healthcare spending might correlate with higher life expectancy.

**12. BMI and Health Indicators:**
Query to find the correlation between BMI and other health indicators like Lifeexpectancy and AdultMortality. Analyze the impact of BMI on overall health.

**13. GDP and Health Outcomes:**
Query to analyze how GDP influences health outcomes such as Lifeexpectancy, AdultMortality, and infantdeaths. Compare high GDP and low GDP countries.

**14. Subgroup Analysis of Life Expectancy:**
Query to find the average Lifeexpectancy for specific subgroups, such as countries in different continents or regions. This can help in identifying regional health disparities.
