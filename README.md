# SQL Portfolio Project: Data Cleaning & Data Exploration (Using MySQL)

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

**9. Under-five Mortality:**
Query to analyze the trend of under-fivedeaths over the years for a specific country.

**10. Gender-based Mortality:**
Query to compare AdultMortality rates between genders for each country.

**11. HIV/AIDS Impact:**
Query to find the correlation between the prevalence of HIVAIDS and Lifeexpectancy.

**12. Economic vs. Health Expenditure:**
Query to analyze the relationship between GDP and percentageexpenditure on healthcare.

**13. Infant Mortality and Healthcare:**
Query to determine the impact of healthcare expenditure (percentageexpenditure) on infantdeaths.

**14. Diphtheria and Polio Impact:**
Query to compare the impact of Diphtheria and Polio on Lifeexpectancy.
