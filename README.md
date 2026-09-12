# USDA Food Price Benchmark & Restaurant Cost Analysis

## Overview

This project analyzes USDA food price data to evaluate restaurant ingredient cost performance, budget variance, pricing trends, year-over-year changes, and menu cost impact.

The analysis uses the USDA Economic Research Service Food-at-Home Monthly Area Prices (F-MAP) dataset as an external food price benchmark. The original dataset contains more than 1 million records across multiple years, geographic areas, food categories, and pricing measures.

SQL was used to profile, validate, and analyze the source data, while Power BI was used to build an interactive 3-page report focused on 2018 cost performance.

To simulate a restaurant finance and cost-analysis workflow, the project also includes internally modeled ingredient mappings, annual budgets, recipes, menu items, and selling prices.

[View the full Power BI report PDF](restaurant_cost_analysis.pdf)
---

## Business Questions

1. Which ingredients had the largest unfavorable and favorable cost variances in 2018?
2. How did ingredient costs change throughout 2018?
3. Which food categories experienced the most pricing pressure?
4. How did 2018 ingredient costs compare with both budget and 2017 prices?
5. How did ingredient cost changes affect menu item food costs and food cost percentages?

---

## Tools Used

- **SQL / SQLite** — data profiling, validation, joins, aggregations, and variance analysis
- **Power BI** — data modeling, DAX measures, and dashboard development
- **Power Query** — filtering and preparing USDA data for the Power BI model
- **GitHub** — project documentation and version control

---

## Data Source

Source data comes from the USDA Economic Research Service **Food-at-Home Monthly Area Prices (F-MAP)** dataset.

[View the USDA F-MAP dataset](https://www.ers.usda.gov/data-products/food-at-home-monthly-area-prices)

The source contains monthly food price benchmark data from 2012–2018 across multiple food categories and geographic areas.

The original raw dataset contains approximately **1,020,600 rows** and is not included in this repository. The original USDA documentation is included for reference.

The Power BI model focuses on:

- 2018
- National-level pricing
- Weighted mean unit value
- 15 food categories mapped to simulated restaurant ingredients

> F-MAP represents retail food-at-home pricing data and is used here as an external market benchmark. It does not represent restaurant distributor invoice or procurement data.

---

## Simulated Restaurant Data

To model a restaurant cost-analysis workflow, several supporting datasets were created for this project:

- `restaurant_ingredients.csv` — maps restaurant ingredients to USDA food categories
- `ingredient_budget.csv` — modeled 2018 ingredient budgets
- `recipe_ingredients.csv` — ingredient quantities used in each menu item
- `menu_items.csv` — simulated menu items and selling prices

The 2018 budget was modeled using the **2017 national average unit price plus a 3% planning increase**.

The recipe, menu, selling-price, and budget data are simulated and are included to demonstrate cost analysis and financial modeling techniques.

---

## SQL Analysis

The SQL portion of the project includes:

- Source data profiling and validation
- Duplicate and null checks
- Ingredient-to-USDA category mapping validation
- 2017 baseline cost calculations
- 2018 actual vs budget variance analysis
- Monthly pricing trend analysis
- Ingredient price volatility
- Category-level variance analysis
- 2017 vs 2018 year-over-year comparisons
- Menu item food-cost calculations

---

## 2017 vs 2018 Cost Comparison

A separate SQL analysis compared average 2017 ingredient costs with 2018 actual costs and the 2018 modeled budget.

This comparison helped show whether an ingredient was rising year over year, whether it finished above or below budget, and whether a budget variance was being driven by broader market price movement.

### Notable Year-over-Year Changes

- Lettuce increased by approximately **7.35%**
- Potato increased by approximately **6.71%**
- Tomato increased by approximately **6.71%**
- Frozen Beef Patty increased by approximately **6.22%**
- Olive Oil increased by approximately **4.91%**
- Whole Milk decreased by approximately **1.32%**
- Cheddar Cheese decreased by approximately **0.25%**

Across the 15 mapped ingredients, average unit costs increased approximately **3.79% from 2017 to 2018**.

Because the 2018 budget was modeled using the 2017 average plus a 3% planning increase, the year-over-year comparison also helped explain which ingredients exceeded the planning assumption.

For example:

- Lettuce, Potato, Tomato, and Frozen Beef Patty all increased by more than 3% year over year and also finished above budget
- Whole Milk decreased year over year and finished below budget
- Cheddar Cheese remained relatively stable and also finished below budget

This comparison added context to the budget analysis by showing whether unfavorable 2018 variances were connected to broader price increases from the prior year.

---

## Power BI Report

The Power BI report contains three pages.

### Page 1 — Executive Cost Overview

Focuses on overall ingredient cost performance against budget.

**Key metrics include:**

- Average Actual Unit Cost
- Average Budget Unit Cost
- Overall Variance vs Budget
- Ingredients Over Budget
- Average YoY Unit Cost Change

**Key findings:**

- **11 of 15 ingredients finished above budget**
- Overall average unit cost finished **0.69% above budget**
- Average ingredient unit costs increased **3.79% vs 2017**
- Lettuce had the largest unfavorable variance at **+4.22%**
- Whole Milk had the largest favorable variance at **-4.19%**

---

### Page 2 — Pricing Trends & Drivers

Explores monthly pricing changes, volatility, and category-level cost pressure.

**Key findings:**

- December had the highest average monthly variance at **+2.93%**
- May had the lowest average variance at **-0.47%**
- **8 of 12 months** finished above budget
- House Seasoning Blend had the highest price range at approximately **$0.426 per 100g**
- Vegetables had the largest unfavorable category variance at **+3.14%**
- Dairy finished below budget at **-3.67%**

---

### Page 3 — Menu Cost Impact

Connects ingredient cost changes to simulated restaurant menu items.

**Key findings:**

- Average actual food cost was approximately **$1.733**
- Average menu cost variance was **+1.01%**
- All 5 menu items finished slightly above budget
- Classic Burger had the highest food cost percentage at **20.29%**
- Grilled Chicken Plate had the largest menu cost variance at **+1.85%**
- Loaded Fries stayed closest to budget at **+0.16%**

---

## Project Files

- `README.md`
- `restaurant_cost_analysis.sql`
- `restaurant_cost_analysis.pbix`
- `restaurant_cost_analysis.pdf`
- `data/restaurant_ingredients.csv`
- `data/ingredient_budget.csv`
- `data/recipe_ingredients.csv`
- `data/menu_items.csv`
- `data/dim_efpg.csv`
- `data/usda_fmap_readme.txt`

---

## Notes

This project combines real USDA market price benchmark data with simulated restaurant planning data to demonstrate a realistic restaurant cost-analysis workflow.

The restaurant ingredient mapping, budget assumptions, recipes, menu items, and selling prices are simulated and should not be interpreted as actual restaurant operating data.