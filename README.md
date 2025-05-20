# Welcome to Kaya Decomposition Factor Analysis: R codes for rapid iterative analysis with GCAM-USA modeling output data

We combine energy systems modeling with decomposition analysis methods to investigate changes in emissions of hazardous air pollutants under alternative policy scenarios. The Kaya Identity method provides a robust framework for identifying the driving forces of GHG emissions or air pollutant reductions, so then proposing feasible air pollutant reduction strategies tailored to the specific characteristics of 50 U.S. states. When coupling with emissions projections for U.S. 50 states, it could highlight differences and similarities of strategies with neighboring regions.

## Experimental Design

For this repository, our focus is on using GCAM-USA to simulate alternative policy scenarios compared to the business-as-usual scenario. We run GCAM-USA since it produces state-level results. The decomposition analysis is then applied to the model's results, using the Kaya Identity to break down the factors influencing CO2 emissions into categories such as decreasing the emissions intensity of energy and decreasing the energy intensity of activities.

## Energy Systems Model Specification

-   **Model:** GCAM-USA 7.0 

-   **Modeling Platform:** GLIMPSE v1.01 and v1.2

The GCAM-USA model can be conducted by a graphical user interface, named as [GLIMPSE (GCAM-Long-Term Interactive Multi-Pollutant Scenario Evaluator)](https://www.epa.gov/air-research/glimpse-computational-framework-supporting-state-level-environmental-and-energy). GLIMPSE simulates the co-evolution of the economy, energy system, land use, and climate systems, including how this co-evolution is shaped by policy and other external factors. GLIMPSE allows users to explore or modify GCAM scenario inputs data and to take simulation outputs data through its ModelInterface. GLIMPSE version is constantly updated and the version is indicated in the scenario name.

## Data Sources for Decomposition Analysis

The decomposition analysis uses dataset taken out from GLIMPSE’s ModelInterface. GCAM inputs include population growth, GDP growth, resource availability, and technology development by sector, and its outputs include energy technology penetrations, fuel use, and emissions by technology, which are sources of the decomposition analysis. The data are state-level data for all 50 U.S. states from 2020 to 2050, presented in 5-year intervals. The ModelInterface data we utilized for the decomposition analysis include:

(1) All emissions by technology,

(2) Inputs by technology,

(3) Outputs by technology,

(4) Population by state, and

(5) GDP per capita by state

The (1)-(3) dataset will be provided by two scenarios as discussed below while population and GDP per capita are projected over the period but stay consistent by scenarios.

## Scenario Design

This repository contains data from two scenarios. We project state-level energy inputs and outputs by technologies and emissions in different scenarios. The scenarios were considered including (1) a **“Reference scenario (GLIMPSE v1.01-Reference)”** where there is business as usual, (2) a **“Alternative policy scenario (GLIMPSE v1.01-DeepDecarb)”** where the net-zero CO2 emission constraint is applied by 2050.

Additional technology and policy scenarios can be modeled in GCAM-USA. The decomposition analysis can be performed in R with the results using the Kaya decomposition codes in this repository.

## Decomposition Methodologies

The decomposition analysis, theoretically rooted in the Kaya Identity (Kaya & Keiichi, 1997), begins with breaking down the factors of selective emissions as shown in the following equation Referencing equation below:

$$
C^t = \sum_i^n P^t \cdot \frac{G^t}{P^t} \cdot \frac{E_i^t}{G^t} \cdot \frac{E_o^t}{E_i^t} \cdot \frac{C_i^t}{E_o^t} 
$$

$$
= \sum_i^n P^t \cdot g^t \cdot a_i^t \cdot e_i^t \cdot I_i^t 
$$

where $$C^t$$ represents the total CO2 emissions in a particular year, *t*, $$P^t$$ represents the total population in the *t* year, $$G^t$$ represents the GDP by state in the t year, $$E_i^t$$ represents energy consumption of energy technology *i* in the *t* year, $$E_o^t$$ represents energy service outputs of energy technology *i* in the t year, and $$C_i^t$$ represents the carbon emissions of energy technology *i* in the *t* year.

Each component represents the factors of selective emissions by breaking them down into population growth ($$P^t$$ ), GDP growth per capita ($$g^t$$), energy intensity ($$a_i^t$$), energy efficiency ($$e_i^t$$), and carbon intensity ($$I_i^t$$). The energy intensity can be lowered not only by deploying more efficient technologies, but also by transitioning more energy-intensive industry into the service economy or by adopting behavioral changes to less energy-intensive ways such as higher use of bike rails or recycling. The carbon intensity can be improved by switching fossil fuels to renewable energy or electrification. Also, deploying direct carbon capture and storage technologies is another potential way to reduce carbon intensity.

## R-Coding Design

Given the large volume of the 50 states’ data, kaya.Rmd leads steps to calculate the decomposition factors and to visualize the outputs for single state or for all 50 states. The first step in the analysis involves R coding to merge each dataset into one matrix and then to calculate CO2 emissions by each factor in each scenario. Once the CO2 emissions is decomposed by the five factors, following the Kaya equation above, wedge factors are calculated to illustrate the impact of five factors on emission reductions for each state for each scenario up to 2050. Additionally, we rank sectors and technologies within each state based on their contribution to CO2 emission reduction or growth. Then, plot functions was used to visualize the decomposition analysis for each state. The calculation process is replicated for other emissions or air pollutants such as NOx, PM2.5, or CH4.

## Contact

-   Gyungwon Joyce Kim, U.S. Environmental Protection Agency, [kim.joyce\@epa.gov](mailto:kim.joyce@epa.gov)

-   Farnaz Nojavan Asghari, U.S. Environmental Protection Agency, [nojavanasghari.farnaz\@epa.gov](mailto:nojavanasghari.farnaz@epa.gov)

## Reference

Kaya, Y., & Keiichi, Y. (1997). *Environment, energy, and economy: strategies for sustainability.* United Nations University Press.

## Disclaimer

The United States Environmental Protection Agency (EPA) GitHub project code is provided on an "as is" basis and the user assumes responsibility for its use. EPA has relinquished control of the information and no longer has responsibility to protect the integrity , confidentiality, or availability of the information. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by EPA. The EPA seal and logo shall not be used in any manner to imply endorsement of any commercial product or activity by EPA or the United States Government.
