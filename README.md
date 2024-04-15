# Expenses Charts

[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/HeatherShein/expense-charts)
[![tests](https://github.com/whitead/paper-qa/actions/workflows/tests.yml/badge.svg)](https://github.com/HeatherShein/expense-charts)

This is a Flutter app to register expenses/incomes in a SQLite database.
There are different graphs and statistics based on different aggregates.
Currently built for Android.

## Table of contents

1. [General info](#general-info)
2. [Installing Project](#installing-project)
3. [Usage](#usage)

## General info

Using this app, you can manually register an expense or income with a specific category. Categories are hard coded for now.
These expenses can also be ingested (or exported) from a .db database or .csv, if fitting correctly.
Expenses can also be extended over a period (i.e., staying a week in a hotel can be considered as paying 1/7th each day).

### Pages available

* Bar chart (Daily, Weekly, Monthly and Yearly aggregates)

![image](assets/docs/graph.jpg)

* Pie chart with total

![image](assets/docs/pie.jpg)

* General statistics (Daily/Period mean, min, max ...)

![image](assets/docs/stats.jpg)

* Details of each expense

![image](assets/docs/details.jpg)

### Tech

* Flutter 3.19.1
* SQFlite 2.3.0
* FL Chart 0.66.2

## Installing Project

Once you downloaded the project, make sure to have flutter installed. You can then launch the project, or just export an .apk.

## Usage

To register an expense, click the "+" button. You can update them in the details page by clicking on it.