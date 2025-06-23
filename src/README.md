# Description of R- and R-markdown programs at <path>/src

## Introduction

This document provides an overview and instructions for the R-Markdown files and package management in the `src` folder. They should be run in the specified order to ensure correct results.

## R Version

The code was run using R version 4.4.2 implemented in R Studio running in Microsoft Windows 11 Enterprise Version 23H2.

## File Descriptions

-   **`packages.R`**:

    -   Contains all the necessary R packages required for this project. Running this script will ensure that all dependencies are installed.

    -   Ensure this file is sourced in each script that requires these packages:

        ``` r
        source("src/packages.R")
        ```

    -   The code used the following R-packages.

        | Package   | Used for                                     |
        |-----------|----------------------------------------------|
        | knitr     | Processing R-markdown                        |
        | tidyverse | Data processing and graphing                 |
        | here      | Finding files                                |
        | janitor   | Cleaning data for analysis                   |
        | writexl   | Saving outputs to Excel files                |
        | readxl    | Reading Excel files                          |
        | viridis   | Color palettes                               |
        | fmsb      | Creating spider charts                       |
        | plotly    | Creating charts and plots                    |
        | reshape2  | Reshaping data between wide and long formats |

-   **`functions.R`**:

    -   Contains utility functions used throughout the project. These functions include:

        -   `create_state_year_sectoral`: Create sectoral-reference data for all states
        -   `create_state_year_specific_sectoral_plot`: Create state-year specific sectoral plot
        -   `create_and_save_plots`: Create and save plots from tibbles
        -   `create_delta`: Perform subtraction on matching columns
        -   `lookup_category`: Lookup category by sector

    -   Ensure this file is sourced in each script that requires these functions:

        ``` r
        source("src/functions.R")
        ```

-   **`01_emisinoutpopgdp_calculations.Rmd`**:

    -   The first step in the decomposition analysis involves using R code to merge each input data into one matrix and then calculate CO<sub>2</sub> emissions by each factor in each scenario. Once the CO<sub>2</sub> emissions are decomposed by the five factors, following the Kaya equation described in the main page, wedge factors are calculated to illustrate the impact of these factors on emission reductions for each state up to 2050.

-   **`02_sectoral_ref_calculations.Rmd`** and **`02_a_sectoral_deepcarbo_calculations.Rmd`**:

    -   The second step guides us in ranking sectors and technologies within each state based on their contribution to CO<sub>2</sub> emission reduction or growth.

-   **`03_a_SO2_calculations.Rmd`**, **`03_b_NOX_calculations.Rmd`**, and **`03_c_PM25_calculations.Rmd`**:

    -   The third step provides optional processes to calculate decomposition factors for other pollutants such as SO<sub>2</sub>, NOx, or PM<sub>2.5</sub>.

-   **`04_delta_calculations.Rmd`**:

    -   The fourth step is necessary to calculate emission differences between reference scenario and the alternative policy scenario. The delta is used to visualize sectoral comparisons of CO<sub>2</sub> emission reductions by sector.

-   **`05_visualization.Rmd`**:

    -   Lastly, the final step employs plot functions that are used to visualize the decomposition analysis for each state. The calculation process can be replicated for other emissions or air pollutants such as SO<sub>2</sub>, NOx, or PM<sub>2.5</sub>.
