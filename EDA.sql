# PART 2: EDA

## 1. Basic Descriptive Statistics: Query to get the avg, mean, median, minimum, and maximum of the Lifeexpectancy for each Country.

### Calculating the Mode of Life Expectancy 

WITH frequecy_table AS (
	SELECT Country
		, Lifeexpectancy
		, COUNT(*) AS frequency
	FROM worldlifeexpectancy
	GROUP BY Country, Lifeexpectancy
)
, max_frequecy_table AS (
	SELECT Country
		, MAX(frequency) AS max_frequency
	FROM frequecy_table
	GROUP BY Country
) 
SELECT ft.Country
	, ft.Lifeexpectancy
    , ft.frequency 
FROM frequecy_table ft
JOIN max_frequecy_table mft 
    ON ft.Country = mft.Country 
    AND ft.frequency = mft.max_frequency;

-- Các giá trị về tuổi thọ trung bình là các biến liên tục phân bổ rải rác, không có giá trị nào lặp lại quá nhiều lần (hầu hết là 1, 2 lần) không có quá nhiều insight nên focus vào các giá trị như mean hoặc median thay vì mode

### Calculating the Median, Average, Maximum, and Minimum of Life Expectancy

SELECT country
    , COUNT(*) AS total_rows
FROM worldlifeexpectancy
GROUP BY country;

-- Số cột mỗi country là chẵn 16 -> trung vị bằng trung bình cộng của 2 giá trị chính giữa

WITH rankedlifeexpactancy AS (
	SELECT country
		, Lifeexpectancy
		, ROW_NUMBER() OVER(PARTITION BY Country ORDER BY Lifeexpectancy) AS ranked
	FROM worldlifeexpectancy
) 
, median_table AS (
	SELECT country
		, AVG(Lifeexpectancy) AS median_lifeexpectancy
	FROM rankedlifeexpactancy
	WHERE ranked IN (8, 9)
	GROUP BY country
)
, statistics_table AS (
	SELECT Country
		, AVG(Lifeexpectancy) AS avg_lifeexpectancy
		, MAX(Lifeexpectancy) AS max_lifeexpectancy
		, MIN(Lifeexpectancy) AS min_lifeexpectancy
	FROM worldlifeexpectancy
	GROUP BY Country
)
SELECT st.country
	, avg_lifeexpectancy
    , median_lifeexpectancy
    , max_lifeexpectancy
    , min_lifeexpectancy
FROM statistics_table as st
LEFT JOIN median_table AS mt
	ON st.country = mt.country; 

## 2. Trend Analysis: Query to find the trend of Lifeexpectancy over the years for a specific country (e.g., Afghanistan).

SELECT Country
	, Year
	, Lifeexpectancy
FROM worldlifeexpectancy
WHERE Country = 'Afghanistan'
ORDER BY Country, Year;

-- Tuổi thọ có xu hướng tăng dần ở Afghanistan

## 3. Comparative Analysis: Query to compare the average Lifeexpectancy between Developed and Developing countries for the latest available year.

SELECT year
	, Status
	, AVG(Lifeexpectancy)
FROM worldlifeexpectancy
GROUP BY Status, year
HAVING Year = 2022;

-- Tuổi thọ trung bình ở các nước đang phát triển trong năm 2022 là 69.69, trong khi ở các nước phát triển là 80.7

## 4. Mortality Analysis: Query to calculate the correlation between AdultMortality and Lifeexpectancy for all countries.

SELECT (COUNT(*) * SUM(xy) - SUM(x) * SUM(y)) / (SQRT((COUNT(*) * SUM(xx) - SUM(x) * SUM(x)) * (COUNT(*) * SUM(yy) - SUM(y) * SUM(y)))) AS correlation
FROM (
	SELECT AdultMortality AS x 
		, Lifeexpectancy AS y 
		, AdultMortality * Lifeexpectancy AS xy
		, AdultMortality * AdultMortality AS xx
		, Lifeexpectancy * Lifeexpectancy AS yy
	FROM worldlifeexpectancy
) AS derived_table;

-- Hệ số tương quan là -0.6796, mối tương quan giữa AdultMortality và Lifeexpectancy là âm và có cường độ tương đối mạnh. Điều này có nghĩa là khi tỷ lệ tử vong ở người lớn (AdultMortality) tăng, thì tuổi thọ trung bình (Lifeexpectancy) có xu hướng giảm, và ngược lại.

## 5. Impact of GDP: Query to find the average Lifeexpectancy of countries grouped by their GDP ranges (e.g., low, medium, high which is you decided).

WITH gdp_ranges_table AS (
	SELECT Country
		, Lifeexpectancy
		, GDP
		, CASE WHEN GDP < 20000 THEN 'Low'
			WHEN GDP < 50000 THEN 'Medium'
			ELSE 'High'
			END AS gdp_ranges
	FROM worldlifeexpectancy
)
SELECT gdp_ranges
	, AVG(Lifeexpectancy)
FROM gdp_ranges_table
GROUP BY gdp_ranges
;

-- Các nước nằm trong nhóm GDP cao thường có tuổi thọ lớn hơn so với các nước có GPD thấp

## 6. Disease Impact: Query to analyze the impact of Measles and Polio on Lifeexpectancy. Calculate average life expectancy for countries with high and low incidence rates of these diseases.

### Average life expectancy with Measles disease

WITH avg_table AS (
	SELECT country
		, AVG(Lifeexpectancy) AS avg_lifeexpectancy
		, AVG(Measles) AS avg_measles
	FROM worldlifeexpectancy
	GROUP BY country
)
, label_table AS (
	SELECT *
		, CASE WHEN avg_measles > 50000 THEN 'High'
			WHEN avg_measles < 1000 THEN 'Low'
			ELSE 'Medium' 
			END AS Measles_incidence_rate
	FROM avg_table
)
SELECT Measles_incidence_rate
	, AVG(avg_lifeexpectancy)
FROM label_table
GROUP BY Measles_incidence_rate;

-- Với các nước có ca nhiễm bệnh Measles mức cao, tuổi thọ trung bình là 62.8
-- Với các nước có ca nhiễm bệnh Measles mức thấp, tuổi thọ trung bình là 71.3
-- Kết quả này có vẻ hợp lý vì tỷ lệ nhiễm bệnh cao thường đi kèm với tỷ lệ tử vong cao, khiến cho tuổi thọ giảm

### Average life expectancy with Polio disease

WITH avg_table AS (
	SELECT country
		, AVG(Lifeexpectancy) AS avg_lifeexpectancy
		, AVG(Polio) AS avg_polio
	FROM worldlifeexpectancy
	GROUP BY country
)
, label_table AS (
	SELECT *
		, CASE WHEN avg_polio >= 90 THEN 'High'
			WHEN avg_polio < 50 THEN 'Low'
			ELSE 'Medium' 
			END AS Polio_incidence_rate
	FROM avg_table
)
SELECT Polio_incidence_rate
	, AVG(avg_lifeexpectancy)
FROM label_table
GROUP BY Polio_incidence_rate;

-- Với các nước có ca nhiễm bệnh Polio mức cao, tuổi thọ trung bình là 74.75
-- Với các nước có ca nhiễm bệnh Polio mức thấp, tuổi thọ trung bình là 52.49
-- Kết quả này không giống như dự kiến, các nước có tỷ lệ nhiễm bệnh cao lại có tuổi thọ cao hơn các nước có tỷ lệ nhiễm bệnh thấp

/* Research thêm để tìm ra nguyên nhân: 
- Measles (Sởi) thường nghiêm trọng hơn về mặt tỷ lệ tử vong và tốc độ lây lan nhanh chóng, đặc biệt ở những nơi có tỷ lệ tiêm chủng thấp.
- Polio (Bại liệt) nghiêm trọng hơn về mặt biến chứng lâu dài như liệt cơ và hậu quả lâu dài đối với sức khỏe.
--> Nguyên nhân có thể do phần lớn các trường hợp nhiễm Polio không dẫn đến tử vong khiến tuổi thọ không bị ảnh hưởng */

## 7. Schooling and Health: Query to determine the relationship between Schooling and Lifeexpectancy. Find countries with the highest and lowest schooling and their respective life expectancies.

WITH avg_table AS (
	SELECT Country
		, AVG(Schooling) AS avg_schooling
		, AVG(Lifeexpectancy) AS avg_lifeexpectancy
	FROM worldlifeexpectancy
	GROUP BY Country
)
SELECT *
FROM avg_table
WHERE avg_schooling = (SELECT MAX(avg_schooling) FROM avg_table)
	OR avg_schooling = (SELECT MIN(avg_schooling) FROM avg_table);
    
-- Schooling có ảnh hưởng tích cực đến lifeexpectancy, nghĩa là các nước có trình độ học vấn càng cao thì tuổi thọ có xu hướng cao
-- Có một số đắt nước có data về schooling sai: Republic of Korea, UK, US, tuổi thọ cao 78, 80 nhưng schooling được ghi nhận là 0

## 8. BMI Trends: Query to find the average BMI trend over the years for a particular country.

SELECT Country
	, Year
    , BMI
FROM worldlifeexpectancy
WHERE Country = 'Albania'
ORDER BY Country, Year ASC;

-- BMI có xu hướng tăng ở Albania, năm 2013 có 1 outlier 5.8 khả năng cao là nhập thiếu số 0

## 9. Infant Mortality: Query to find the average number of infantdeaths and under-fivedeaths for countries with the highest and lowest life expectancies.

WITH avg_table AS (
SELECT Country
	, AVG(Lifeexpectancy) AS avg_lifeexpectancy
    , AVG(infantdeaths) AS avg_infantdeaths
    , AVG(`under-fivedeaths`) AS avg_underfivedeaths
FROM worldlifeexpectancy
GROUP BY Country
)
SELECT *
FROM avg_table
WHERE avg_lifeexpectancy = (SELECT MAX(avg_lifeexpectancy) FROM avg_table)
	OR avg_lifeexpectancy = (SELECT MIN(avg_lifeexpectancy) FROM avg_table)
;

-- Với đất nước có tuổi thọ trung bình cao nhất Japan - 82.5, avg infant deaths là 2.8 và infant dưới 5 tuổi deaths là 4 / 1000 em bé được sinh ra
-- Với đất nước có tuổi thọ trung bình thấp nhất Sierra Loene - 46.1, avg infant deaths là 27.5 và infant dưới 5 tuổi deaths là 41.8 / 1000 em bé được sinh ra

## 10. Rolling Average of Adult Mortality: Query to calculate the rolling average of AdultMortality over a 5-year window for each country. This will help in understanding the trend and smoothing out short-term fluctuations.

## 11. Impact of Healthcare Expenditure: Query to find the correlation between percentageexpenditure (healthcare expenditure) and Lifeexpectancy. Higher healthcare spending might correlate with higher life expectancy.

SELECT (COUNT(*) * SUM(xy) - SUM(x) * SUM(y)) / (SQRT((COUNT(*) * SUM(xx) - SUM(x) * SUM(x)) * (COUNT(*) * SUM(yy) - SUM(y) * SUM(y)))) AS correlation
FROM (
	SELECT percentageexpenditure AS x 
		, Lifeexpectancy AS y 
		, percentageexpenditure * Lifeexpectancy AS xy
		, percentageexpenditure * percentageexpenditure AS xx
		, Lifeexpectancy * Lifeexpectancy AS yy
	FROM worldlifeexpectancy
) AS derived_table;

-- Tương quan giữa percentageexpenditure (healthcare expenditure) và Lifeexpectancy là 0.38 - mức tương quan tương đối
-- Nghĩa là Higher healthcare spending, thì life expectancy cũng có xu hướng tăng lên, nhưng mức độ tăng không quá rõ ràng, có thể còn có yếu tố khác ảnh hưởng

## 12. BMI and Health Indicators: Query to find the correlation between BMI and other health indicators like Lifeexpectancy and AdultMortality. Analyze the impact of BMI on overall health.

### Tìm mối tương quan giữa BMI và Lifeexpectancy

SELECT (COUNT(*) * SUM(xy) - SUM(x) * SUM(y)) / (SQRT((COUNT(*) * SUM(xx) - SUM(x) * SUM(x)) * (COUNT(*) * SUM(yy) - SUM(y) * SUM(y)))) AS correlation
FROM (
	SELECT BMI AS x 
		, Lifeexpectancy AS y 
		, BMI * Lifeexpectancy AS xy
		, BMI * BMI AS xx
		, Lifeexpectancy * Lifeexpectancy AS yy
	FROM worldlifeexpectancy
) AS derived_table;

-- Tương quan giữa BMI và Lifeexpectancy là 0.57 cho thấy có một mối tương quan trung bình dương giữa hai biến này. 
-- Điều này có nghĩa là khi BMI tăng, tuổi thọ cũng có xu hướng tăng, nhưng mối quan hệ này không hoàn toàn mạnh mẽ. BMI có liên quan đến tuổi thọ, nhưng không phải là yếu tố duy nhất quyết định tuổi thọ 
-- Điều này có thể được giải thích bởi việc: Mặc dù BMI cao có thể liên quan đến nguy cơ mắc các bệnh như tiểu đường, tim mạch, và huyết áp cao, nhưng một số nghiên cứu chỉ ra rằng một BMI vừa phải hoặc cao hơn một chút ở người trưởng thành có thể liên quan đến việc sống lâu hơn trong một số trường hợp. 

### Tìm mối tương quan giữa BMI và AdultMortality

SELECT (COUNT(*) * SUM(xy) - SUM(x) * SUM(y)) / (SQRT((COUNT(*) * SUM(xx) - SUM(x) * SUM(x)) * (COUNT(*) * SUM(yy) - SUM(y) * SUM(y)))) AS correlation
FROM (
	SELECT BMI AS x 
		, AdultMortality AS y 
		, BMI * AdultMortality AS xy
		, BMI * BMI AS xx
		, AdultMortality * AdultMortality AS yy
	FROM worldlifeexpectancy
) AS derived_table;

-- Tương quan giữa BMI và AdultMortality là (-0.38) - mức tương quan âm tương đối yếu
-- Nghĩa là khi BMI tăng (người có xu hướng thừa cân hoặc béo phì), tỷ lệ Adult Mortality có xu hướng giảm, nhưng mối quan hệ này không mạnh và còn nhiều yếu tố khác có thể tác động đến tỷ lệ tử vong ở người lớn ngoài BMI
-- Điều này có thể được giải thích bởi việc: Mặc dù BMI cao có thể liên quan đến nguy cơ mắc các bệnh như tiểu đường, tim mạch, và huyết áp cao, nhưng một số nghiên cứu chỉ ra rằng một BMI vừa phải hoặc cao hơn một chút ở người trưởng thành có thể liên quan đến việc sống lâu hơn trong một số trường hợp. 

## 13. GDP and Health Outcomes: Query to analyze how GDP influences health outcomes such as Lifeexpectancy, AdultMortality, and infantdeaths. Compare high GDP and low GDP countries.

WITH avg_table AS (
	SELECT Country
		, AVG(GDP) AS avg_gdp
		, AVG(Lifeexpectancy) AS avg_lifeexpectancy
        , AVG(AdultMortality) AS avg_adultmortality
        , AVG(infantdeaths) AS avg_infantdeaths
	FROM worldlifeexpectancy
	GROUP BY Country
    HAVING avg_gdp <> 0 -- có một số nước thiếu data về GDP nên để phân tích khách quan hơn lúc phân tích sẽ loại bỏ các nước đó đi
)
, gdp_table AS (
SELECT *
	, CASE 
		WHEN avg_gdp < 10000 THEN 'low'
		WHEN avg_gdp >= 10000 AND avg_gdp < 30000 THEN 'medium'
		ELSE 'high'
	END AS gdp_labled
FROM avg_table
)
SELECT gdp_labled
	, AVG (avg_lifeexpectancy)
    , AVG(avg_adultmortality)
    , AVG(avg_infantdeaths)
FROM gdp_table
GROUP BY gdp_labled;

-- Ở các nước có GDP thấp < 10000, số ca tử vong ở cả người lớn và trẻ em cao hơn hẳn so với các nước có GDP ở mức trung bình và cao. 

## 14. Subgroup Analysis of Life Expectancy: Query to find the average Lifeexpectancy for specific subgroups, such as countries in different continents or regions. This can help in identifying regional health disparities.

WITH region_table AS (
	SELECT *
	  , CASE
		-- Châu Á
		WHEN Country IN ('Afghanistan', 'Armenia', 'Azerbaijan', 'Bangladesh', 'Bhutan', 'Brunei Darussalam', 'Cambodia', 
						 'China', 'Democratic People\'s Republic of Korea', 'India', 'Indonesia', 'Islamic Republic of Iran', 
						 'Iraq', 'Israel', 'Japan', 'Jordan', 'Kazakhstan', 'Kuwait', 'Kyrgyzstan', 'Lao People\'s Democratic Republic', 
						 'Lebanon', 'Malaysia', 'Maldives', 'Mongolia', 'Myanmar', 'Nepal', 'Oman', 'Pakistan', 'Philippines', 
						 'Qatar', 'Republic of Korea', 'Saudi Arabia', 'Singapore', 'Sri Lanka', 'Syrian Arab Republic', 
						 'Tajikistan', 'Thailand', 'Timor-Leste', 'Turkmenistan', 'United Arab Emirates', 'Uzbekistan', 'Viet Nam', 'Yemen', 'Georgia', 'Turkey') THEN 'Asia'
		
		-- Châu Âu
		WHEN Country IN ('Albania', 'Armenia', 'Austria', 'Belarus', 'Belgium', 'Bosnia and Herzegovina', 'Bulgaria', 
						 'Croatia', 'Cyprus', 'Czechia', 'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 
						 'Iceland', 'Ireland', 'Italy', 'Kazakhstan', 'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Moldova', 
						 'Montenegro', 'Netherlands', 'North Macedonia', 'Norway', 'Poland', 'Portugal', 'Romania', 
						 'Russian Federation', 'Serbia', 'Slovakia', 'Slovenia', 'Spain', 'Sweden', 'Switzerland', 'Ukraine', 'United Kingdom of Great Britain and Northern Ireland', 'Republic of Moldova', 'The former Yugoslav republic of Macedonia') THEN 'Europe'

		-- Châu Phi
		WHEN Country IN ('Algeria', 'Angola', 'Benin', 'Botswana', 'Burkina Faso', 'Burundi', 'Cabo Verde', 'Cameroon', 
						 'Central African Republic', 'Chad', 'Comoros', 'Congo', 'Democratic Republic of the Congo', 'Djibouti', 
						 'Egypt', 'Equatorial Guinea', 'Eritrea', 'Eswatini', 'Ethiopia', 'Gabon', 'Gambia', 'Ghana', 'Guinea', 
						 'Guinea-Bissau', 'Ivory Coast', 'Kenya', 'Lesotho', 'Liberia', 'Libya', 'Madagascar', 'Malawi', 'Mali', 
						 'Mauritania', 'Mauritius', 'Morocco', 'Mozambique', 'Namibia', 'Niger', 'Nigeria', 'Rwanda', 'Sao Tome and Principe', 
						 'Senegal', 'Seychelles', 'Sierra Leone', 'Somalia', 'South Africa', 'South Sudan', 'Sudan', 'Togo', 'Uganda', 
						 'United Republic of Tanzania', 'Zambia', 'Zimbabwe', 'Côte d\'Ivoire', 'Swaziland', 'Tunisia') THEN 'Africa'
		
		-- Châu Mỹ (Bắc Mỹ và Nam Mỹ)
		WHEN Country IN ('Antigua and Barbuda', 'Argentina', 'Bahamas', 'Barbados', 'Belize', 'Bolivia', 'Brazil', 'Canada', 
						 'Chile', 'Colombia', 'Costa Rica', 'Cuba', 'Dominican Republic', 'Ecuador', 'El Salvador', 'Grenada', 
						 'Guatemala', 'Guyana', 'Haiti', 'Honduras', 'Jamaica', 'Mexico', 'Nicaragua', 'Panama', 'Paraguay', 
						 'Peru', 'Saint Lucia', 'Saint Vincent and the Grenadines', 'Suriname', 'Trinidad and Tobago', 
						 'United States of America', 'Uruguay', 'Venezuela', 'Plurinational State of Bolivia') THEN 'Americas'
		
		-- Châu Đại Dương
		WHEN Country IN ('Australia', 'Fiji', 'Kiribati', 'Micronesia', 'Nauru', 'New Zealand', 
						 'Palau', 'Papua New Guinea', 'Samoa', 'Solomon Islands', 'Tonga', 'Tuvalu', 'Vanuatu', 'Federated States of Micronesia') THEN 'Oceania'
		
		-- Trung Đông (nếu muốn tách riêng khu vực này)
		WHEN Country IN ('Bahrain', 'Iraq', 'Israel', 'Jordan', 'Kuwait', 'Lebanon', 'Oman', 'Qatar', 'Saudi Arabia', 
						 'Syrian Arab Republic', 'United Arab Emirates', 'Yemen') THEN 'Middle East'

	  END AS Region
	FROM worldlifeexpectancy
)
SELECT Region
	, AVG(Lifeexpectancy)
FROM region_table
GROUP BY Region;

-- Tuổi thọ trung bình ở Châu Phi (Africa) là thấp nhất - 58.61 > còn lại đều trên 70 (Europe là cao nhất 77.4
