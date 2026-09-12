-- Data profiling and validation

SELECT
    COUNT(*) AS total_rows,
    MIN(Year) AS first_year,
    MAX(Year) AS last_year,
    COUNT(DISTINCT Month) AS total_months,
    COUNT(DISTINCT EFPG_code) AS food_categories,
    COUNT(DISTINCT Metroregion_code) AS regions,
    COUNT(DISTINCT Attribute) AS attributes
FROM raw_fmap;


-- Review available measures

SELECT DISTINCT
    Attribute
FROM raw_fmap
ORDER BY Attribute;


-- Check for duplicate rows at the expected data grain

SELECT
    Year,
    Month,
    EFPG_code,
    Metroregion_code,
    Attribute,
    COUNT(*) AS row_count
FROM raw_fmap
GROUP BY
    Year,
    Month,
    EFPG_code,
    Metroregion_code,
    Attribute
HAVING COUNT(*) > 1;


-- Check for missing values in key fields

SELECT *
FROM raw_fmap
WHERE Year IS NULL
   OR Month IS NULL
   OR EFPG_code IS NULL
   OR Metroregion_code IS NULL
   OR Attribute IS NULL
   OR Value IS NULL;


-- Validate EFPG codes against the category lookup table

SELECT DISTINCT
    rf.EFPG_code
FROM raw_fmap rf
LEFT JOIN dim_efpg de
    ON rf.EFPG_code = de.EFPG_code
WHERE de.EFPG_code IS NULL;


-- Validate region codes against the region lookup table

SELECT DISTINCT
    rf.Metroregion_code
FROM raw_fmap rf
LEFT JOIN dim_metroregion dm
    ON rf.Metroregion_code = dm.Metroregion_code
WHERE dm.Metroregion_code IS NULL;


-- Validate restaurant ingredient mappings

SELECT
    ri.ingredient_id,
    ri.ingredient_name,
    ri.EFPG_code
FROM restaurant_ingredients ri
LEFT JOIN dim_efpg de
    ON ri.EFPG_code = de.EFPG_code
WHERE de.EFPG_code IS NULL;


-- Calculate 2017 national averages used as the budget baseline

SELECT
    ri.ingredient_id,
    ri.ingredient_name,
    AVG(rf.Value) AS avg_actual_2017
FROM restaurant_ingredients ri
INNER JOIN raw_fmap rf
    ON ri.EFPG_code = rf.EFPG_code
WHERE rf.Year = 2017
  AND rf.Metroregion_code = 0
  AND rf.Attribute = 'Unit_value_mean_wtd'
GROUP BY
    ri.ingredient_id,
    ri.ingredient_name
ORDER BY
    ri.ingredient_id;


-- Validate ingredient budget mappings

SELECT
    ib.ingredient_id
FROM ingredient_budget ib
LEFT JOIN restaurant_ingredients ri
    ON ib.ingredient_id = ri.ingredient_id
WHERE ri.ingredient_id IS NULL;


-- Supporting analysis for Business Questions 1 and 2
-- Monthly actual ingredient costs compared with budget

SELECT
    ri.ingredient_id,
    ri.ingredient_name,
    rf.Month,
    rf.Value AS actual_unit_cost,
    ib.budget_unit_cost,
    rf.Value - ib.budget_unit_cost AS variance_amt,
    (rf.Value - ib.budget_unit_cost) / ib.budget_unit_cost AS variance_pct
FROM raw_fmap rf
INNER JOIN restaurant_ingredients ri
    ON rf.EFPG_code = ri.EFPG_code
INNER JOIN ingredient_budget ib
    ON ri.ingredient_id = ib.ingredient_id
WHERE rf.Year = 2018
  AND rf.Metroregion_code = 0
  AND rf.Attribute = 'Unit_value_mean_wtd'
ORDER BY
    ri.ingredient_id,
    rf.Month;


-- Business Question 1
-- Which ingredients were the biggest pricing problems in 2018

SELECT
    ri.ingredient_name,
    AVG(rf.Value) AS avg_actual_cost,
    ib.budget_unit_cost,
    AVG(rf.Value) - ib.budget_unit_cost AS variance_amt,
    (AVG(rf.Value) - ib.budget_unit_cost) / ib.budget_unit_cost AS variance_pct,
    SUM(
        CASE
            WHEN rf.Value > ib.budget_unit_cost THEN 1
            ELSE 0
        END
    ) AS months_above_budget,
    SUM(
        CASE
            WHEN rf.Value < ib.budget_unit_cost THEN 1
            ELSE 0
        END
    ) AS months_below_budget
FROM raw_fmap rf
INNER JOIN restaurant_ingredients ri
    ON rf.EFPG_code = ri.EFPG_code
INNER JOIN ingredient_budget ib
    ON ri.ingredient_id = ib.ingredient_id
WHERE rf.Year = 2018
  AND rf.Metroregion_code = 0
  AND rf.Attribute = 'Unit_value_mean_wtd'
GROUP BY
    ri.ingredient_name,
    ib.budget_unit_cost
ORDER BY
    variance_pct DESC;


-- Business Question 2
-- How did ingredient costs change throughout 2018

-- Measure ingredient price volatility

SELECT
    ri.ingredient_name,
    MIN(rf.Value) AS min_cost,
    MAX(rf.Value) AS max_cost,
    MAX(rf.Value) - MIN(rf.Value) AS cost_range
FROM raw_fmap rf
INNER JOIN restaurant_ingredients ri
    ON rf.EFPG_code = ri.EFPG_code
WHERE rf.Year = 2018
  AND rf.Metroregion_code = 0
  AND rf.Attribute = 'Unit_value_mean_wtd'
GROUP BY
    ri.ingredient_name
ORDER BY
    cost_range DESC;


-- Measure monthly pricing pressure compared with budget

SELECT
    rf.Month,
    AVG(
        (rf.Value - ib.budget_unit_cost) / ib.budget_unit_cost
    ) AS avg_variance_pct,
    SUM(
        CASE
            WHEN rf.Value > ib.budget_unit_cost THEN 1
            ELSE 0
        END
    ) AS ingredients_above_budget,
    SUM(
        CASE
            WHEN rf.Value < ib.budget_unit_cost THEN 1
            ELSE 0
        END
    ) AS ingredients_below_budget
FROM raw_fmap rf
INNER JOIN restaurant_ingredients ri
    ON rf.EFPG_code = ri.EFPG_code
INNER JOIN ingredient_budget ib
    ON ri.ingredient_id = ib.ingredient_id
WHERE rf.Year = 2018
  AND rf.Metroregion_code = 0
  AND rf.Attribute = 'Unit_value_mean_wtd'
GROUP BY
    rf.Month
ORDER BY
    rf.Month;


-- Business Question 3
-- Which broader food categories drove the largest favorable and unfavorable variances

SELECT
    de.Tier1_group,
    AVG(
        (rf.Value - ib.budget_unit_cost) / ib.budget_unit_cost
    ) AS avg_variance_pct
FROM raw_fmap rf
INNER JOIN restaurant_ingredients ri
    ON rf.EFPG_code = ri.EFPG_code
INNER JOIN dim_efpg de
    ON ri.EFPG_code = de.EFPG_code
INNER JOIN ingredient_budget ib
    ON ri.ingredient_id = ib.ingredient_id
WHERE rf.Year = 2018
  AND rf.Metroregion_code = 0
  AND rf.Attribute = 'Unit_value_mean_wtd'
GROUP BY
    de.Tier1_group
ORDER BY
    avg_variance_pct DESC;


-- Business Question 4
-- How did 2018 actual costs compare with 2017 and budget expectations

WITH yearly_costs AS (
    SELECT
        ri.ingredient_name,
        AVG(
            CASE
                WHEN rf.Year = 2017 THEN rf.Value
            END
        ) AS avg_actual_2017,
        AVG(
            CASE
                WHEN rf.Year = 2018 THEN rf.Value
            END
        ) AS avg_actual_2018,
        ib.budget_unit_cost
    FROM raw_fmap rf
    INNER JOIN restaurant_ingredients ri
        ON rf.EFPG_code = ri.EFPG_code
    INNER JOIN ingredient_budget ib
        ON ri.ingredient_id = ib.ingredient_id
    WHERE rf.Year IN (2017, 2018)
      AND rf.Metroregion_code = 0
      AND rf.Attribute = 'Unit_value_mean_wtd'
    GROUP BY
        ri.ingredient_name,
        ib.budget_unit_cost
)

SELECT
    ingredient_name,
    avg_actual_2017,
    avg_actual_2018,
    budget_unit_cost,
    (avg_actual_2018 - avg_actual_2017) / avg_actual_2017 AS change_pct,
    (avg_actual_2018 - budget_unit_cost) / budget_unit_cost AS budget_variance_pct
FROM yearly_costs
ORDER BY
    budget_variance_pct DESC;


-- Validate recipe menu item mappings

SELECT DISTINCT
    rci.menu_item_id
FROM recipe_ingredients rci
LEFT JOIN menu_items mi
    ON rci.menu_item_id = mi.menu_item_id
WHERE mi.menu_item_id IS NULL;


-- Validate recipe ingredient mappings

SELECT DISTINCT
    rci.ingredient_id
FROM recipe_ingredients rci
LEFT JOIN restaurant_ingredients ri
    ON rci.ingredient_id = ri.ingredient_id
WHERE ri.ingredient_id IS NULL;


-- Business Question 5
-- How did ingredient price changes affect menu item food costs

WITH ingredient_costs AS (
    SELECT
        rci.menu_item_id,
        rci.ingredient_id,
        rci.quantity_grams,
        ib.budget_unit_cost,
        AVG(rf.Value) AS avg_actual_unit_cost,
        (rci.quantity_grams / 100.0) * ib.budget_unit_cost AS budgeted_ing_cost,
        (rci.quantity_grams / 100.0) * AVG(rf.Value) AS actual_ing_cost
    FROM raw_fmap rf
    INNER JOIN restaurant_ingredients ri
        ON rf.EFPG_code = ri.EFPG_code
    INNER JOIN recipe_ingredients rci
        ON ri.ingredient_id = rci.ingredient_id
    INNER JOIN ingredient_budget ib
        ON ri.ingredient_id = ib.ingredient_id
    WHERE rf.Year = 2018
      AND rf.Metroregion_code = 0
      AND rf.Attribute = 'Unit_value_mean_wtd'
    GROUP BY
        rci.menu_item_id,
        rci.ingredient_id,
        rci.quantity_grams,
        ib.budget_unit_cost
)

SELECT
    mi.menu_item_name,
    mi.selling_price,
    SUM(ic.budgeted_ing_cost) AS total_budget_cost,
    SUM(ic.actual_ing_cost) AS total_actual_cost,
    SUM(ic.budgeted_ing_cost) / mi.selling_price AS budget_cost_pct,
    SUM(ic.actual_ing_cost) / mi.selling_price AS actual_cost_pct,
    SUM(ic.actual_ing_cost) - SUM(ic.budgeted_ing_cost) AS variance_amt,
    (
        SUM(ic.actual_ing_cost) - SUM(ic.budgeted_ing_cost)
    ) / SUM(ic.budgeted_ing_cost) AS variance_pct
FROM ingredient_costs ic
INNER JOIN menu_items mi
    ON ic.menu_item_id = mi.menu_item_id
GROUP BY
    ic.menu_item_id,
    mi.menu_item_name,
    mi.selling_price
ORDER BY
    variance_pct DESC;