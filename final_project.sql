# E commerce and web Analysis- to extracting and analysing data to generate insights.

USE MAVENFUZZYFACTORY;
SELECT * FROM WEBSITE_SESSIONS WHERE WEBSITE_SESSION_ID =1059;
SELECT * FROM WEBSITE_PAGEVIEWS WHERE WEBSITE_SESSION_ID =1059;
SELECT * FROM ORDERS WHERE WEBSITE_SESSION_ID =1059;

#TASK 1.1. TRAFFIC SOURCE ANALYSIS USING WEBSITE SESSIONS, PAGEVIEWS AND ORDERS- OFTEN DONE BY MARKETING ANALYST IN ANY COMPANY

-- Tracking parameter to measure paid marketing activity- UTM (Urchin Tracking module).
-- Using the UTM parameters stored in the DB to identify the paid website sessions.
-- From the session data, we can link to our order data to understand how much revenue our paid campaigns are driving.

SELECT 
    website_sessions.utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_coversionrate
FROM
    website_sessions
        LEFT JOIN
    orders ON orders.website_session_id = website_sessions.website_session_id
WHERE
    website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY website_sessions.utm_content
ORDER BY sessions DESC;

#INFERENCE
-- PERCENTAGE OF SESSION THAT CONVERTS TO THE PROFIT , 3.59% REVENUE FROM EACH SESSION IN utm_content g_ad_1.

# TASK 1.2. TOP TRAFFIC SOURCE ANALYSIS - USING WEBSITE SESSION WITH BREAKDOWN BY UTM SOURCE, CAMPAIGN, AND REFERRING DOMAIN.

SELECT 
    UTM_SOURCE,
    UTM_CAMPAIGN,
    HTTP_REFERER,
     COUNT(DISTINCT WEBSITE_SESSION_ID) AS NO_OF_SESSIONS
FROM
    WEBSITE_SESSIONS
WHERE
    CREATED_AT < '2012-04-12'
GROUP BY UTM_SOURCE , UTM_CAMPAIGN , HTTP_REFERER
ORDER BY NO_OF_SESSIONS DESC;

# BASED ON LAST OUTPUT, DIG DEEPER INTO THE GSEARCH NONBRAND CAMPAIGN TRAFFIC TO EXPLORE MORE
# CALCULATE THE CONVERSION RATE FROM SESSION TO ORDER IF IT IS ATLEAST 4%, OTHERWISE INCREASE BIDS FOR MORE VOLUME.
SELECT 
    COUNT(DISTINCT WEBSITE_SESSIONS.WEBSITE_SESSION_ID) AS SESSIONS,
	COUNT(DISTINCT ORDERS.ORDER_ID) AS ORDRES,
    COUNT(DISTINCT ORDERS.ORDER_ID)/ COUNT(DISTINCT WEBSITE_SESSIONS.WEBSITE_SESSION_ID) AS SESSION_TO_ORDER_CONVERSION_RATE
FROM
    WEBSITE_SESSIONS
        LEFT JOIN
    ORDERS ON ORDERS.WEBSITE_SESSION_ID = WEBSITE_SESSIONS.WEBSITE_SESSION_ID
WHERE
    WEBSITE_SESSIONS.CREATED_AT < '2012-04-14'
        AND UTM_SOURCE = 'gsearch'
        AND UTM_CAMPAIGN = 'nonbrand';

# INFERENCE- SESSION TO ORDER CONVERSION RATE IS LESS THAN 4% WHICH IS LESS THAN EXPECTED

# TASK 3- BID OPTIMIZATION
#ANSLYZE THE IMPACT OF BID REDUCTION, ANALYSE PERFORMANCE TRENDING BY DEVICE TYPE IN ORDER TO REFINE BIDDING STRATEGY.


/*Understanding various segments of paid traffic, to optimize the marketing budget
to figure out right amount of bid for various segments  (mobile / laptop) based on ho much revenue it makes*/

SELECT 
    YEAR(CREATED_AT),
    WEEK(CREATED_AT),
    MIN(DATE(CREATED_AT)) AS WEEK_START,
    COUNT(DISTINCT WEBSITE_SESSION_ID) AS SESSIONS
FROM
    WEBSITE_SESSIONS	
WHERE
    WEBSITE_SESSION_ID BETWEEN 100000 AND 115000
GROUP BY 1 , 2;

#To check how many times an item is purchased

SELECT 
    PRIMARY_PRODUCT_ID,
    COUNT(DISTINCT CASE
            WHEN ITEMS_PURCHASED = 1 THEN ORDER_ID
            ELSE NULL
        END) AS COUNT_SINGLE_ITEM_ORDERS,
    COUNT(DISTINCT CASE
            WHEN ITEMS_PURCHASED = 2 THEN ORDER_ID
            ELSE NULL
        END) AS COUNT_TWO_ITEM_ORDERS
FROM
    ORDERS
WHERE
    ORDER_ID BETWEEN 31000 AND 32000
GROUP BY 1;

# TASK 4- TRAFFIC SOURCE TRENDING- to pull gsearch nonbrand trended session volume, by week.
SELECT 
    YEAR(CREATED_AT) AS YR,
    WEEK(CREATED_AT) AS WK,
    MIN(DATE(CREATED_AT)) AS WEEK_STARTED_AT,
    COUNT(DISTINCT WEBSITE_SESSION_ID) AS SESSIONS
FROM
    WEBSITE_SESSIONS
WHERE
    CREATED_AT < '2012-05-10'
        AND UTM_SOURCE = 'GSEARCH'
        AND UTM_CAMPAIGN = 'NONBRAND'
GROUP BY 1 , 2;

#TASK 5- SESSION TO ORDER CONVERSION RATES FROM SESSION TO ORDER, BY DEVICE TYPE.

SELECT 
    WEBSITE_SESSIONS.DEVICE_TYPE,
    COUNT(DISTINCT (WEBSITE_SESSIONS.WEBSITE_SESSION_ID)) AS SESSIONS,
    COUNT(DISTINCT (ORDERS.ORDER_ID)) AS ORDERS,
    COUNT(DISTINCT (ORDERS.ORDER_ID)) / COUNT(DISTINCT (WEBSITE_SESSIONS.WEBSITE_SESSION_ID)) AS CONV_RT
FROM
    WEBSITE_SESSIONS
        LEFT JOIN
    ORDERS ON ORDERS.WEBSITE_SESSION_ID = WEBSITE_SESSIONS.WEBSITE_SESSION_ID
WHERE
    WEBSITE_SESSIONS.CREATED_AT < '2012-05-11'
        AND UTM_SOURCE = 'GSEARCH'
        AND UTM_CAMPAIGN = 'NONBRAND'
GROUP BY 1;

# TASK 6- WEEKLY TRENDS FOR BOTH DESKTOP AND MOBILE 
	use mavenfuzzyfactory;
SELECT 
	-- YEAR(CREATED_AT) AS YR,
    -- WEEK(CREATED_AT) AS WK,
    MIN(DATE(CREATED_AT)) AS WEEK_START_DATE,
    COUNT(DISTINCT CASE
            WHEN DEVICE_TYPE = 'DESKTOP' THEN WEBSITE_SESSION_ID
            ELSE NULL
        END) AS DESKTOP_SESSIONS,
    COUNT(DISTINCT CASE
           WHEN DEVICE_TYPE = 'MOBILE' THEN WEBSITE_SESSION_ID
            ELSE NULL
        END) AS MOBILE_SESSIONS
    -- COUNT(DISTINCT WEBSITE_SESSION_ID) AS TOTAL_SESSIONS
FROM
    WEBSITE_SESSIONS
WHERE
    WEBSITE_SESSIONS.CREATED_AT< '2012-06-09'
        AND WEBSITE_SESSIONS.CREATED_AT> '2012-04-15'
        AND UTM_SOURCE = 'GSEARCH'
        AND UTM_CAMPAIGN = 'NONBRAND'
GROUP BY YEAR(CREATED_AT), WEEK(CREATED_AT); 
		#Website performance Analysis


USE MAVENFUZZYFACTORY;
SELECT * FROM WEBSITE_PAGEVIEWS WHERE WEBSITE_PAGEVIEW_ID < 1000;

# TASK 1- ANALYSING TOP WEBSITE PAGES- MOST VIEWED PAGES

SELECT PAGEVIEW_URL, COUNT(DISTINCT WEBSITE_PAGEVIEW_ID) AS PAGEVIEW
FROM WEBSITE_PAGEVIEWS WHERE WEBSITE_PAGEVIEW_ID < 1000
GROUP BY PAGEVIEW_URL
ORDER BY PAGEVIEW DESC;

# TASK 2- TOP ENTRY PAGES
CREATE TEMPORARY TABLE FIRST_PAGEVIEW
SELECT 
    WEBSITE_SESSION_ID, MIN(WEBSITE_PAGEVIEW_ID) AS MIN_PV_ID
FROM
    WEBSITE_PAGEVIEWS
WHERE
    WEBSITE_PAGEVIEW_ID < 1000
GROUP BY WEBSITE_SESSION_ID;


SELECT 
    WEBSITE_PAGEVIEWS.PAGEVIEW_URL AS LANDING_PAGE,
    COUNT(DISTINCT FIRST_PAGEVIEW.WEBSITE_SESSION_ID) AS SESSIONS_HITTING_THIS_LANDER
FROM
    FIRST_PAGEVIEW
        LEFT JOIN
    WEBSITE_PAGEVIEWS ON FIRST_PAGEVIEW.MIN_PV_ID = WEBSITE_PAGEVIEWS.WEBSITE_PAGEVIEW_ID
GROUP BY WEBSITE_PAGEVIEWS.PAGEVIEW_URL;

# TAST 3- MOST VIEWED WEBSITE PAGES RANKED BY SESSION VOLUME

SELECT PAGEVIEW_URL, COUNT(DISTINCT WEBSITE_PAGEVIEW_ID) AS PVS
FROM WEBSITE_PAGEVIEWS WHERE CREATED_AT < '2012-06-09'
GROUP BY PAGEVIEW_URL
ORDER BY PVS DESC;

#TASK 4- PULL ALL ENTRY PAGES AND RANK THEM ON ENTRY VOLUME.
--  Step 1: Find the first pageview for each session
-- Step 2: Find the url the customer saw on that first pageview

CREATE TEMPORARY TABLE FIRST_PV_PER_SESSION
SELECT 
    WEBSITE_SESSION_ID, MIN(WEBSITE_PAGEVIEW_ID) AS FIRST_PV
FROM
    WEBSITE_PAGEVIEWS
WHERE
    CREATED_AT < '2012-06-12'
GROUP BY WEBSITE_SESSION_ID;

SELECT 
    WEBSITE_PAGEVIEWS.PAGEVIEW_URL AS LANDING_PAGE_URL,
    COUNT(DISTINCT FIRST_PV_PER_SESSION.WEBSITE_SESSION_ID) AS SESSIONS_HITTING_PAGE
FROM
    FIRST_PV_PER_SESSION
        LEFT JOIN
    WEBSITE_PAGEVIEWS ON FIRST_PV_PER_SESSION.FIRST_PV = WEBSITE_PAGEVIEWS.WEBSITE_PAGEVIEW_ID
GROUP BY WEBSITE_PAGEVIEWS.PAGEVIEW_URL;

#LANDING PAGE PERFORMANCE & TESTING- Performance of key landing page and then testing to improve the results

/* 
A/B Testing--- helps to compare the performance of 2 versions of website (eg) and helps to optimize business.
Home (PAGE A)---> CART----> checkout (85% of ppl)
Home (PAGE B)---> CART----> checkout (92% of ppl)
To find first pageview for relevant sessions, associate that pageview with url seen, then analyse whether that session has additional pageviews.
if only 1 page view ( bounced), multiple pageview (non bouncesd)
*/

-- STEP 1 : Find the first website_pageview_id for relevaht sessions
-- STEP 2 : Identify the landing page for each session
-- STEP 3: Counting pageviews for each session, to identify "bounces" if there is more than 1 page visited
-- STEP 4: Summarizing the total session and bonced sessions.


-- Finding the minimum website pageview id associated with each session we care 
SELECT 
    WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID,
    MIN(WEBSITE_PAGEVIEWS.WEBSITE_PAGEVIEW_ID) AS MIN_PAGEVIEW_ID
FROM
    WEBSITE_PAGEVIEWS
INNER JOIN WEBSITE_SESSIONS 
ON WEBSITE_SESSIONS.WEBSITE_SESSION_ID = WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID
AND WEBSITE_SESSIONS.CREATED_AT BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID;	

-- same querry as above but creating a temporary table
CREATE TEMPORARY TABLE FIRST_PAGEVIEWS_DEMO
SELECT 
    WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID,
    MIN(WEBSITE_PAGEVIEWS.WEBSITE_PAGEVIEW_ID) AS MIN_PAGEVIEW_ID
FROM
    WEBSITE_PAGEVIEWS
INNER JOIN WEBSITE_SESSIONS 
ON WEBSITE_SESSIONS.WEBSITE_SESSION_ID = WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID
AND WEBSITE_SESSIONS.CREATED_AT BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID;


SELECT * FROM FIRST_PAGEVIEWS_DEMO;

# TO PULL THE BOUNCE RATE FOR TRAFFIC LANDING ON HOMEPAGE. (OP- SESSION, BOUNCED_SESSION, BOUNCE_RATE)


#CONVERSION FUNNELS- ANALYZING AND TESTING
# Understanding and analysing each step of user experience on their journey toward purchasing the products;
/*
-- Identify most common paths customers take before purchasing products.
-- Identlfy how many customers drop out at what step and ho many custiners reach final stage.
-- optimizing critical point where users are abondoning and improving busines by converting more users and selling more products.
*/

SELECT website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at AS pageview_created_at, 
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- random timeframe for demo
AND website_pageviews.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
ORDER BY
website_sessions.website_session_id, website_pageviews.created_at;


# To tell the story of the comoany growth using trended performance data.
# Analyse current performance and use available data to assess upcoming opportunities.


# TASK 1- Monthly trends for gsearch sessions and orders to show growth.

SELECT
YEAR (website_sessions. created_at) AS yr,
MONTH (website_sessions. created_at) AS mo,
COUNT(DISTINCT website_sessions. website_session_id) AS
sessions,
COUNT(DISTINCT
orders. order_id) AS orders
FROM website_sessions
LEFT JOIN orders
ON orders. website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
GROUP BY 1,2;

# TASK 2- Splitting out branded and non branded campaigns separately.

SELECT
YEAR(website_sessions.created_at) AS yr,
MONTH(website_sessions.created_at) AS mo,
COUNT(DISTINCT CASE WHEN utm_Campaign = 'nonbrand'THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders. order_id ELSE NULL END) AS nonbrand_orders,
COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders. order_id ELSE NULL END) AS brand_orders
FROM website_sessions
LEFT JOIN orders
ON orders. website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
GROUP BY 1,2;

# TASK 3- Montly sessions and orders split by device type.

SELECT
	YEAR(website_sessions.created_at) AS yr, 
    MONTH(website_sessions.created_at) AS mo, 
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions, 
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions, 
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders
FROM website_sessions
	LEFT JOIN orders 
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1,2;

# TASK 4- Montly trend for GSearch, alongside monthly trends for each of our other channels.

SELECT DISTINCT 
	utm_source,
    utm_campaign, 
    http_referer
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27';


SELECT
	YEAR(website_sessions.created_at) AS yr, 
    MONTH(website_sessions.created_at) AS mo, 
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_sessions
FROM website_sessions
	LEFT JOIN orders 
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

# TASK 5- Session to order conversion rate by months.

SELECT
	YEAR(website_sessions.created_at) AS yr, 
    MONTH(website_sessions.created_at) AS mo, 
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions, 
    COUNT(DISTINCT orders.order_id) AS orders, 
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate    
FROM website_sessions
	LEFT JOIN orders 
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;


# PRODUCT SALES ANALYSIS- To analyse How each product contribute to the business and how product launches impact the overall portfolio


# TASK 1- PRODUCT LEVEL SALES ANALYSIS.
# To Pull monthly trends to date for a number of sales, total revenue, and total margin generated for the business.

USE mavenfuzzyfactory;
SELECT 
    YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(DISTINCT order_id) AS number_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM
    orders
WHERE
    created_at < '2013-01-04'
GROUP BY YEAR(created_at) , MONTH(created_at);


# TASK 2- ANALYSING PRODUCT LAUNCH IMPACT
/* To pull  monthly order volume, overall conversion rates, revenue per session and a breakdwn of sales by product  till Apr 1,2012
 for a product launched on 6th Jan and the task is .
*/

SELECT 
    YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session,
    COUNT(DISTINCT CASE
            WHEN primary_product_id = 1 THEN order_id
            ELSE NULL
        END) AS product_one_orders,
    COUNT(DISTINCT CASE
            WHEN primary_product_id = 2 THEN order_id
            ELSE NULL
        END) AS product_two_orders
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2013-04-05'
        AND website_sessions.created_at > '2012-04-01'
GROUP BY 1 , 2;

#TASK 3- PRODUCT REFUND ANALYSIS
#Understanding refund rates for products at different prince points.
/* To pull monthly product refund rates by product. */

SELECT 
    YEAR(order_items.created_at) AS yr,
    MONTH(order_items.created_at) AS mo,
    COUNT(DISTINCT CASE
            WHEN product_id = 1 THEN order_items.order_item_id
            ELSE NULL
        END) AS p1_orders,
    COUNT(DISTINCT CASE
            WHEN product_id = 1 THEN order_item_refunds.order_item_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN product_id = 1 THEN order_items.order_item_id
            ELSE NULL
        END) AS p1_refund_rt,
    COUNT(DISTINCT CASE
            WHEN product_id = 2 THEN order_items.order_item_id
            ELSE NULL
        END) AS p2_orders,
    COUNT(DISTINCT CASE
            WHEN product_id = 2 THEN order_item_refunds.order_item_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN product_id = 2 THEN order_items.order_item_id
            ELSE NULL
        END) AS p2_refund_rt,
    COUNT(DISTINCT CASE
            WHEN product_id = 3 THEN order_items.order_item_id
            ELSE NULL
        END) AS p3_orders,
    COUNT(DISTINCT CASE
            WHEN product_id = 3 THEN order_item_refunds.order_item_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN product_id = 3 THEN order_items.order_item_id
            ELSE NULL
        END) AS p3_refund_rt,
    COUNT(DISTINCT CASE
            WHEN product_id = 4 THEN order_items.order_item_id
            ELSE NULL
        END) AS p4_orders,
    COUNT(DISTINCT CASE
            WHEN product_id = 4 THEN order_item_refunds.order_item_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN product_id = 4 THEN order_items.order_item_id
            ELSE NULL
        END) AS p4_refund_rt
FROM
    order_items
        LEFT JOIN
    order_item_refunds ON order_items.order_item_id = order_item_refunds.order_item_id
WHERE
    order_items.created_at < '2014-10-15'
GROUP BY 1 , 2;

# User Analysis -To understand user behaviour and identify some most valueable customers.

 
 #  TASK 1-
 /* To Pull dta on how many of the website visitors come back for another session.*/

CREATE TEMPORARY TABLE sessions_w_repeats
SELECT new_sessions.user_id,
new_sessions.website_session_id AS new_session_id, website_sessions.website_session_id AS repeat_session_id
FROM (
SELECT user_id,
website_session_id
FROM website_sessions
WHERE created_at < '2014-11-01'-- the date of the assignment
AND created_at >= '2014-01-01' -- prescribed date range in assignment
AND is_repeat_session = 0 -- new sessions only
) AS new_sessions
LEFT JOIN website_sessions
ON website_sessions.user_id = new_sessions.user_id
AND website_sessions.is_repeat_session = 1 -- was a repeat session (redundant, but good to illustrate)
AND website_sessions.website_session_id > new_sessions.website_session_id -- session was later than new session
AND website_sessions.created_at < '2014-11-01' -- the date of the assignment
AND website_sessions.created_at > '2014-01-01'; -- prescribed date range in assignment

SELECT * FROM sessions_W_repeats;

SELECT repeat_sessions,
COUNT(DISTINCT user_id) AS users
FROM 
(
SELECT 
user_id,
COUNT(DISTINCT new_session_id) AS new_sessions,
COUNT(DISTINCT repeat_session_id) AS repeat_sessions
FROM sessions_w_repeats
GROUP BY 1
ORDER BY 3 DESC
) AS user_level
GROUP BY 1;

# TASK 2-
# To analyse the minimum, maximun and average time between the first and second session for customers who come back, analysing 2014 to date.
-- STEP 1: Identify the relevant new sessions
-- STEP 2: User the user_id values form Step 1 to find any repeat sessions those users had
-- STEP 3: Find the created_at times for first and second sessions
-- STEP 4: Find the differences between first and second sessions at a user level
-- STEP 5: Aggregate the user level data to find the average, min, max
use mavenfuzzyfactory;

CREATE TEMPORARY TABLE sessions_w_repeats_for_time_diff
SELECT
new_sessions.user_id,
new_sessions.website_session_id AS new_session_id,
new_sessions. created_at AS new_session_created_at, 
website_sessions.website_session_id AS repeat_session_id, 
website_sessions.created_at AS repeat_session_created_at
FROM
(
SELECT user_id,
website_session_id, created_at
FROM website_sessions
WHERE created_at < '2014-11-03' -- the date of the assignment
AND created_at >= '2014-01-01'-- prescribed date range in assignment
AND is_repeat_session = 0 -- new sessions only
)AS new_sessions
LEFT JOIN website_sessions
ON website_sessions.user_id = new_sessions.user_id
AND website_sessions.is_repeat_session = 1 -- was a repeat session (redundant, but good to illustrate)
AND website_sessions.website_session_id > new_sessions.website_session_id -- session was later than new sessi
AND website_sessions.created_at < '2014-11-03' -- the date of the assignment
AND website_sessions.created_at >= '2014-01-01'; -- prescribed date range in assignment

CREATE TEMPORARY TABLE users_first_to_second
SELECT user_id,
DATEDIFF(second_session_created_at, new_session_created_at) AS days_first_to_second_session
FROM
(
SELECT user_id,
new_session_id, new_session_created_at,
MIN(repeat_session_id) AS second_session_id,
MIN(repeat_session_created_at) AS second_session_created_at
FROM sessions_w_repeats_for_time_diff
WHERE repeat_session_id IS NOT NULL
GROUP BY 1,2,3
) AS first_second;

SELECT * FROM USERS_FIRST_TO_SECOND;

SELECT
AVG(days_first_to_second_session) AS avg_days_first_to_second,
MIN(days_first_to_second_session) AS min_days_first_to_second,
MAX(days_first_to_second_session) AS avg_days_first_to_second					
FROM USERS_FIRST_TO_SECOND;

# TASK 3- To compare new vs repeat sessions by channel.

SELECT
utm_source, utm_campaign, http_referer,
COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM website_sessions
WHERE created_at < '2014-11-05' -- the date of the assignment
AND created_at >= '2014-01-01' -- prescribed date range in assignment
GROUP BY 1,2,3
ORDER BY 4 DESC;

SELECT
CASE
WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bseaIch.com') THEN 'organic_search'
WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
WHEN utm_campaign = 'brand' THEN 'paid_brand'
WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
WHEN utm_source = 'socialbook' THEN 'paid_social'
END AS channel_group,
-- utm_source,
-- utm_ campagn,
-- http_referer,
COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM website_sessions
WHERE created_at < '2014-11-05' -- the date of the assignikent
AND created_at >= '2014-01-01' -- prescribed date range in assignment
GROUP BY 1;