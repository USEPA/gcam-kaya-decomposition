#' Create State Sectoral Reference Data
#'
#' This function processes sectoral reference data for specified states and years,
#' filtering and joining relevant datasets based on given parameters for scenario,
#' greenhouse gas type, and units. It returns a list of data frames, each corresponding
#' to a combination of state and year.
#'
#' @param years A vector of years for which the data should be processed (e.g., c(2035, 2050)).
#' @param scenario A string specifying the scenario to filter on (e.g., "GLIMPSEv1.01-Reference").
#' @param ghg A string specifying the greenhouse gas type to filter on (e.g., "CO2").
#' @param units.o A string specifying the units to filter on (e.g., "EJ").
#' @param states A vector of state abbreviations to include in the processing. Defaults to all U.S. state abbreviations (`state.abb`).
#'
#' @return A list of data frames, where each element corresponds to a state-year combination
#' and contains filtered and joined data for that combination.
#'
#' @examples
#' # Default usage with all states
#' result_all_states <- create_state_sectoral_ref(c(2035, 2050), "GLIMPSEv1.01-Reference", "CO2", "EJ")
#'
#' # Usage with a subset of states
#' result_subset_states <- create_state_sectoral_ref(c(2035, 2050), "GLIMPSEv1.01-Reference", "CO2", "EJ", states = c("CA", "TX", "NY"))
#'
create_state_year_sectoral <- function(states = state.abb, 
                                       years, 
                                       scenario,
                                       ghg,
                                       sectoral_data,  
                                       units.o = NULL) {
  # Create an empty list to store data frames
  state_sectoral_ref <- list()
  
  # Loop over each state and year
  for (state in states) {
    for (year in years) {
      # Filter sectoral_data by region and rank for the specific year
      filtered_table1 <- sectoral_data %>%
        filter(region == state, !!sym(paste0("rank_", year)) <= 15)
      
      # Prepare the filter condition for units.o
      filter_condition <- if (!is.null(units.o)) {
        emisinoutpopgdp %>%
          filter(scenario == !!scenario, ghg == !!ghg, units.o == !!units.o)
      } else {
        emisinoutpopgdp %>%
          filter(scenario == !!scenario, ghg == !!ghg)
      }
      
      # Add region_sector column and apply the filter
      filtered_table2 <- filter_condition %>%
        mutate(region_sector = str_c(region, sector, sep = ":"))
      
      # Determine the correct column name based on ghg
      # column_name <- if (ghg == "CO2") {
      #   paste0("co2in", year)
      # } else if (ghg == "NOx") {
      #   paste0("NOxin", year)
      # } else {
      #   stop("Unsupported GHG type")
      # }
      
      supported_ghg <- c("CO2", "NOx", "PM2.5", "CH4", "N2O", "SO2")
      
      if (!(ghg %in% supported_ghg)) {
        stop("Unsupported GHG type")
      }
      
      # column_name <- paste0(ghg, "in", year)
      column_name <- paste0(ifelse(ghg == "CO2", tolower(ghg), ghg), "in", year)  
      
      # Join filtered_table1 with table2 based on region_sector
      
      if(ghg == "CO2"){result_table <- filtered_table1 %>%
        inner_join(filtered_table2, by = "region_sector") %>%
        mutate(Removal = if_else(
          grepl("CO2 removal$", region_sector) & !!sym(column_name) != 0,
          !!sym(column_name),
          0
        )) %>% 
        select(region_sector, !!sym(paste0("rank_", year)), 
               Population = !!sym(paste0("WPop", year)), 
               `GDP/Population` = !!sym(paste0("WGDPperPOP", year)), 
               `Eo/GDP` = !!sym(paste0("WOutperGDP", year)), 
               `Ei/Eo` = !!sym(paste0("WInperOut", year)), 
               `CO2/Ei` = !!sym(paste0("WEmisperIn", year)), 
               Removal,
               !!sym(column_name)) %>%
        arrange(!!sym(paste0("rank_", year)))  # Order by rank for the specific year
      
      # Save the result_table in the list with a key combining state and year
      state_sectoral_ref[[paste0(state, "_", year)]] <- result_table}
      else{result_table <- filtered_table1 %>%
        inner_join(filtered_table2, by = "region_sector") %>%
        # mutate(Removal = if_else(
        #   grepl("CO2 removal$", region_sector) & !!sym(column_name) != 0,
        #   !!sym(column_name),
        #   0
        # )) %>% 
        select(region_sector, !!sym(paste0("rank_", year)), 
               Population = !!sym(paste0("WPop", year)), 
               `GDP/Population` = !!sym(paste0("WGDPperPOP", year)), 
               `Eo/GDP` = !!sym(paste0("WOutperGDP", year)), 
               `Ei/Eo` = !!sym(paste0("WInperOut", year)), 
               `CO2/Ei` = !!sym(paste0("WEmisperIn", year)), 
               # Removal,
               !!sym(column_name)) %>%
        arrange(!!sym(paste0("rank_", year)))  # Order by rank for the specific year
      
      # Save the result_table in the list with a key combining state and year
      state_sectoral_ref[[paste0(state, "_", year)]] <- result_table}
      # result_table <- filtered_table1 %>%
      #   inner_join(filtered_table2, by = "region_sector") %>%
      #   mutate(Removal = if_else(
      #     grepl("CO2 removal$", region_sector) & !!sym(column_name) != 0,
      #     !!sym(column_name),
      #     0
      #   )) %>% 
      #   select(region_sector, !!sym(paste0("rank_", year)), 
      #          Population = !!sym(paste0("WPop", year)), 
      #          `GDP/Population` = !!sym(paste0("WGDPperPOP", year)), 
      #          `Eo/GDP` = !!sym(paste0("WOutperGDP", year)), 
      #          `Ei/Eo` = !!sym(paste0("WInperOut", year)), 
      #          `CO2/Ei` = !!sym(paste0("WEmisperIn", year)), 
      #          Removal,
      #          !!sym(column_name)) %>%
      #   arrange(!!sym(paste0("rank_", year)))  # Order by rank for the specific year
      # 
      # # Save the result_table in the list with a key combining state and year
      # state_sectoral_ref[[paste0(state, "_", year)]] <- result_table
    }
  }
  
  return(state_sectoral_ref)
}

#' @title Create State-Year Specific Sectoral Plot
#'
#' @description This function generates a stacked bar chart for a specified state and year, visualizing sectoral data related to greenhouse gas (GHG) emissions. The chart includes a dynamic ranking and highlights a specific GHG type, such as CO2.
#'
#' @param state_year_sectoral_data A list of data frames containing sectoral data for different states and years. Each data frame should be accessible via a key in the format "State_Year".
#' @param state A character string specifying the state for which the plot should be generated. Defaults to "AK".
#' @param year An integer specifying the year for which the plot should be generated. Defaults to 2035.
#' @param ghg A character string specifying the greenhouse gas type to be highlighted in the plot. Defaults to "CO2".
#' @param type A character string specifying the type. Defaults to "ref"
#'
#' @return A ggplot object representing the stacked bar chart for the specified state, year, and GHG type.
#'
#' @importFrom ggplot2 ggplot aes geom_bar geom_point scale_fill_viridis_d scale_color_manual coord_flip labs theme_minimal guides guide_legend
#' @importFrom tidyr pivot_longer
#' @importFrom viridis scale_fill_viridis_d
#' @export
#'
create_state_year_specific_sectoral_plot <- function(state_year_sectoral_data, 
                                                     state = "AK",
                                                     year = 2035, 
                                                     ghg = "CO2",
                                                     type = "ref") {
  # Construct the key to access the specific data frame
  data_key <- paste(state, year, sep = "_")
  
  # Construct dynamic column names based on the year input
  rank_column <- paste0("rank_", year)
  ghg_column <- paste0(ifelse(ghg == "CO2", tolower(ghg), ghg), "in", year)  
  
  # Reshape data to long format
  data_long <- pivot_longer(
    state_year_sectoral_data[[data_key]],
    cols = -c("region_sector", rank_column, ghg_column),
    names_to = "Variable",
    values_to = "Value"
  )
  
  # Reverse the order of ranks
  data_long$region_sector <- factor(
    data_long$region_sector,
    levels = unique(state_year_sectoral_data[[data_key]]$region_sector[order(-state_year_sectoral_data[[data_key]][[rank_column]])])
  )
  
  # Print reshaped and ordered data
  print(data_long)
  
  # Create stacked bar chart with ordered categories
  if(type =="deepcarbo"){
  plot <- ggplot(data_long, aes(x = region_sector, y = Value, fill = Variable)) +
    geom_bar(stat = "identity", position = "stack") +
   # geom_point(aes(x = region_sector, y = .data[[ghg_column]], color = paste0(ghg, " in ", year)), size = 3, show.legend = TRUE) +
    scale_fill_viridis_d() +
    scale_color_manual(values = setNames("darkgray", paste0(ghg, " in ", year))) +
    coord_flip() +
    labs(
      title = paste("Top 15 Categories for", ghg, "Reduction, Policy Scenario"),
      x = "State:Sector",
      y = "Value",
      fill = "Variables",
      color = paste0(ghg, " Point")
    ) +
    theme_minimal() +
    # theme(axis.text.y = element_text(hjust = 0)) +
    guides(
      fill = guide_legend(order = 1, override.aes = list(shape = NA)),
      color = guide_legend(order = 2)
    )}
  else{
    plot <- ggplot(data_long, aes(x = region_sector, y = Value, fill = Variable)) +
      geom_bar(stat = "identity", position = "stack") +
      geom_point(aes(x = region_sector, y = .data[[ghg_column]], color = paste0(ghg, " in ", year)), size = 3, show.legend = TRUE) +
      scale_fill_viridis_d() +
      scale_color_manual(values = setNames("darkgray", paste0(ghg, " in ", year))) +
      coord_flip() +
      labs(
        title = paste("Top 15 Categories for", ghg, "Reduction, Policy Scenario"),
        x = "State:Sector",
        y = "Value",
        fill = "Variables",
        color = paste0(ghg, " Point")
      ) +
      theme_minimal() +
      # theme(axis.text.y = element_text(hjust = 0)) +
      guides(
        fill = guide_legend(order = 1, override.aes = list(shape = NA)),
        color = guide_legend(order = 2)
      )
    
  }
  
  return(plot)
}


#' Create and Save Plots from Tibbles
#'
#' This function generates and saves plots based on the data provided in tibbles. It is designed to visualize emission reductions by region and sector, specifically focusing on a chosen emission type such as "CO2". The output is saved as PNG files in a specified folder.
#'
#' @param data_list A named list of tibbles, where each tibble contains data for a specific state and year. The names of the list elements should be formatted as "state_year".
#' @param emission_type A character string specifying the type of emission to focus on, default is "CO2".
#' @param output_folder A character string specifying the folder where the plots will be saved, default is "figures".
#'
#' @details The function first ensures the specified output folder exists, creating it if necessary. It then iterates over each tibble in the provided list, extracting relevant data and reshaping it for plotting. The plots are generated using ggplot2, displaying stacked bars for different variables and points for emission values. Plots are saved as PNG files with names corresponding to the tibble names.
#'
#' @return No return value, called for side effects.
#'
#' @examples
#' \dontrun{
#' # Assuming `data_list` is a list of tibbles named "state_year"
#' create_and_save_plots(data_list, emission_type = "CO2", output_folder = "figures")
#' }
#'
#' @import ggplot2
#' @import tidyr
#' @import here
#' @import viridis
#' @export

# Define the function to create and save plots from tibbles
create_and_save_plots <- function(data_list, 
                                  emission_type = "CO2",
                                  output_folder = "output/figures",
                                  type = "ref") {
  # Ensure the output folder exists
  if (!dir.exists(output_folder)) {
    dir.create(here(output_folder))
  }
  
  # Iterate over each tibble in the list
  for (tibble_name in names(data_list)) {
    # Extract the tibble
    tibble_data <- data_list[[tibble_name]]
    
    # Extract state and year from tibble name
    state_year <- unlist(strsplit(tibble_name, "_"))
    state <- state_year[1]
    year <- state_year[2]
    
    # Determine the rank and emission column for the current year
    rank_column <- paste0("rank_", year)
    emission_column <- paste0(ifelse(emission_type == "CO2", tolower(emission_type), emission_type), "in", year)    
    # Reshape data to long format, excluding "Rank"
    data_long <- pivot_longer(tibble_data, cols = -c("region_sector", rank_column, emission_column), names_to = "Variable", values_to = "Value")
    
    # Order categories based on rank
    data_long$region_sector <- factor(data_long$region_sector, levels = unique(tibble_data$region_sector[order(-tibble_data[[rank_column]])]))
    
    emission_label <- paste(emission_type, "in", year)
    
    plot <- if(type == "deepcarbo"){ggplot(data_long, aes(x = region_sector, y = Value, fill = Variable)) +
        geom_bar(stat = "identity", position = "stack") +
        # geom_point(aes(x = region_sector, y = !!sym(emission_column), color = emission_label), size = 3, show.legend = TRUE) +
        scale_fill_viridis_d() +  # Automatically assign different colors to each variable
        scale_color_manual(values = setNames("darkgray", emission_label)) + # Correctly set the color
        coord_flip() +
        labs(
          title = paste("Top 15 Categories for", emission_type, "Reduction, Policy Scenario"),
          x = "State:Sector",
          y = "Value",
          fill = "Variables",  # Label for fill (stacked bar variables)
          color = paste(emission_type, "Point")  # Label for color (point)
        ) +
        theme_minimal() +
        guides(
          fill = guide_legend(order = 1, override.aes = list(shape = NA)),  # Remove point shape from fill legend
          color = guide_legend(order = 2)
        )
    }else{ggplot(data_long, aes(x = region_sector, y = Value, fill = Variable)) +
        geom_bar(stat = "identity", position = "stack") +
        geom_point(aes(x = region_sector, y = !!sym(emission_column), color = emission_label), size = 3, show.legend = TRUE) +
        scale_fill_viridis_d() +  # Automatically assign different colors to each variable
        scale_color_manual(values = setNames("darkgray", emission_label)) + # Correctly set the color
        coord_flip() +
        labs(
          title = paste("Top 15 Categories for", emission_type, "Reduction, Policy Scenario"),
          x = "State:Sector",
          y = "Value",
          fill = "Variables",  # Label for fill (stacked bar variables)
          color = paste(emission_type, "Point")  # Label for color (point)
        ) +
        theme_minimal() +
        guides(
          fill = guide_legend(order = 1, override.aes = list(shape = NA)),  # Remove point shape from fill legend
          color = guide_legend(order = 2)
        )
    }
      
      
      
      # ggplot(data_long, aes(x = region_sector, y = Value, fill = Variable)) +
      # geom_bar(stat = "identity", position = "stack") +
      # geom_point(aes(x = region_sector, y = !!sym(emission_column), color = emission_label), size = 3, show.legend = TRUE) +
      # scale_fill_viridis_d() +  # Automatically assign different colors to each variable
      # scale_color_manual(values = setNames("darkgray", emission_label)) + # Correctly set the color
      # coord_flip() +
      # labs(
      #   title = paste("Top 15 Categories for", emission_type, "Reduction, Policy Scenario"),
      #   x = "State:Sector",
      #   y = "Value",
      #   fill = "Variables",  # Label for fill (stacked bar variables)
      #   color = paste(emission_type, "Point")  # Label for color (point)
      # ) +
      # theme_minimal() +
      # guides(
      #   fill = guide_legend(order = 1, override.aes = list(shape = NA)),  # Remove point shape from fill legend
      #   color = guide_legend(order = 2)
      # )
      # 
    # Save the plot to the output folder
    ggsave(filename = paste0(here(output_folder), "/", tibble_name, ".png"), plot = plot)
  }
}


#' Perform Subtraction on Matching Columns
#'
#' This function takes a dataframe and performs subtraction between columns with matching base names, 
#' specifically those ending in `.x` and `.y`. It returns a new dataframe containing the results 
#' of these subtractions along with specified columns like `region`, `sector`, and `region_sector`.
#'
#' @param data A dataframe containing columns with names ending in `.x` and `.y`. 
#'             These columns should have matching base names for subtraction to occur.
#' @return A dataframe that includes the original `region`, `sector`, and `region_sector` columns 
#'         alongside new columns representing the difference between matching `.x` and `.y` columns.
#'         If either value in the pair is `NA`, the resulting difference is set to 0.
#' @details The function identifies pairs of columns by their base names and performs subtraction 
#'          between `.x` and `.y` columns. It handles `NA` values by replacing them with 0 in the 
#'          resulting difference. The final output includes the original context columns.
#' @importFrom stats setNames
#' @export
create_delta <- function(data) {
  # Extract relevant column names
  x_columns <- grep("\\.x$", names(data), value = TRUE)
  y_columns <- grep("\\.y$", names(data), value = TRUE)
  
  # Initialize an empty list to store new columns
  new_columns <- list()
  
  # Iterate over x_columns to find matching y_columns and perform subtraction
  for (x_col in x_columns) {
    base_name <- sub("\\.x$", "", x_col)
    y_col <- paste0(base_name, ".y")
    
    if (y_col %in% y_columns) {
      # new_columns[[base_name]] <- data[[x_col]] - data[[y_col]]
      new_columns[[base_name]] <- ifelse(is.na(data[[x_col]]) | is.na(data[[y_col]]), 
                                         data[[x_col]], 
                                         data[[x_col]] - data[[y_col]])
      
    }
  }
  
  # Convert the list to a dataframe
  new_data <- as.data.frame(new_columns)
  
  # Add the region, sector, and region_sector columns to the new dataset
  new_data <- cbind(data[, c("region", "sector", "region_sector")], new_data)
  
  return(new_data)
}



#' @title Lookup Category by Sector
#'
#' @description This function identifies the category associated with a given sector by searching through a predefined list of categories.
#'
#' @param sector A character string representing the sector for which the category needs to be identified.
#'
#' @return A character string representing the category name if the sector is found in the categories list; otherwise, returns NA.
#'
#' @importFrom base names
#' @export
#'
# Create a lookup function
lookup_category <- function(sector) {
  for (category in names(categories)) {
    if (sector %in% categories[[category]]) {
      return(category)
    }
  }
  return(NA) # Return NA if no category is found
}



# create_state_year_sectoral <- function(states = state.abb, 
#                                        years, 
#                                        scenario,
#                                        ghg,
#                                        sectoral_data,  
#                                        units.o = NULL) {
#   # Create an empty list to store data frames
#   state_sectoral_ref <- list()
#   
#   # Loop over each state and year
#   for (state in states) {
#     for (year in years) {
#       # Filter sectoral_data by region and rank for the specific year
#       filtered_table1 <- sectoral_data %>%
#         filter(region == state, !!sym(paste0("rank_", year)) <= 15)
#       
#       # Prepare the filter condition for units.o
#       filter_condition <- if (!is.null(units.o)) {
#         emisinoutpopgdp %>%
#           filter(scenario == !!scenario, ghg == !!ghg, units.o == !!units.o)
#       } else {
#         emisinoutpopgdp %>%
#           filter(scenario == !!scenario, ghg == !!ghg)
#       }
#       
#       # Add region_sector column and apply the filter
#       filtered_table2 <- filter_condition %>%
#         mutate(region_sector = str_c(region, sector, sep = ":"))
#       
#       # Determine the correct column name based on ghg
#       # column_name <- if (ghg == "CO2") {
#       #   paste0("co2in", year)
#       # } else if (ghg == "NOx") {
#       #   paste0("NOxin", year)
#       # } else {
#       #   stop("Unsupported GHG type")
#       # }
#       
#       supported_ghg <- c("CO2", "NOx", "PM2.5", "CH4", "N2O")
#       
#       if (!(ghg %in% supported_ghg)) {
#         stop("Unsupported GHG type")
#       }
#       
#       # column_name <- paste0(ghg, "in", year)
#       column_name <- paste0(ifelse(ghg == "CO2", tolower(ghg), ghg), "in", year)  
#       
#       # Join filtered_table1 with table2 based on region_sector
#       result_table <- filtered_table1 %>%
#         inner_join(filtered_table2, by = "region_sector") %>%
#         select(region_sector, !!sym(paste0("rank_", year)), 
#                !!sym(paste0("WPop", year)), !!sym(paste0("WGDPperPOP", year)), 
#                !!sym(paste0("WOutperGDP", year)), !!sym(paste0("WInperOut", year)), 
#                !!sym(paste0("WEmisperIn", year)), !!sym(column_name)) %>%
#         arrange(!!sym(paste0("rank_", year)))  # Order by rank for the specific year
#       
#       # Save the result_table in the list with a key combining state and year
#       state_sectoral_ref[[paste0(state, "_", year)]] <- result_table
#     }
#   }
#   
#   return(state_sectoral_ref)
# }

