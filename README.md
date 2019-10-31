# Big Data Solution for Stock Prices and Tweet Collections

This project is currently in progress.
The [project outline](https://github.com/sjmiller8182/DBMS_Proj/blob/master/Project_Outline.md) provides a list of [projected milestones](https://github.com/sjmiller8182/DBMS_Proj/blob/master/Project_Outline.md#milestones-and-status) for completion of the project.

## Problem Statement

We want to build a large-scale data framework that will enable us to store and analyze financial market data and drive future predictions for inverstment.

For this project, we will use the following types of data

* Daily stock prices for all companies traded on the NYSE and the NASDAQ.
* Intra-day values for all companies traded on the NYSE and the NASDAQ.
  * Prices: high, low, open, close,
  * Supporting Values: Brollinger Bands, stochastic oscillators, and moving average CD
  * Intra-day values are at 15 minute intervals
* Tweets from over [100 investment related twitter accounts](https://github.com/sjmiller8182/DBMS_Proj/blob/master/scrape_utils/python/twitter_handles.txt)

## Overview of the Big Data Solution

![Overview of Solution](https://github.com/sjmiller8182/DBMS_Proj/blob/master/reports/support/images/Overview_of_Solution.png)

## Data Warehouse Overview

The dataware house will be created with Hive HQL in an AWS EMR cluster.

An effective schema of the normalized dataware house is shown below. 

![Normalized_Schema](https://github.com/sjmiller8182/DBMS_Proj/blob/master/reports/support/images/Warehouse_Schema_Normalized.png)

This schema was created with MySQL WorkBench the schema design can be accessed [here](https://github.com/sjmiller8182/DBMS_Proj/tree/master/reports/support).

## Big Data Solution Implementation

The big data solution is build on AWS.

![Big_data_solution_AWS](https://github.com/sjmiller8182/DBMS_Proj/blob/master/reports/support/images/Big_Data_Solution_AWS.png)

## Results

## Analysis

## Conclusion

## Reports

These reports were created during the course of this project.

* [Project Proposal](https://github.com/sjmiller8182/DBMS_Proj/blob/master/reports/Proposal.pdf): Initial proposal regarding the problem and the proposed solution for investigation.
* [Initial Project Presentation](https://github.com/sjmiller8182/DBMS_Proj/blob/master/reports/Initial_Presentation.pdf): A high level overview of the project idea and current status.

