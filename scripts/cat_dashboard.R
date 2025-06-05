# =============================================================================
# Interactive CAT Dashboard for GCLS-G Testing
# Real-time Visualization of Computerized Adaptive Testing
# =============================================================================

library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(tidyverse)
library(psych)

# Source CAT functions (assuming they're in a separate file)
source("cat_demonstration.R")

# =============================================================================
# UI Definition
# =============================================================================

ui <- dashboardPage(
  dashboardHeader(title = "GCLS-G CAT Dashboard"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("CAT Testing", tabName = "cat_test", icon = icon("play-circle")),
      menuItem("Performance Analysis", tabName = "performance", icon = icon("chart-line")),
      menuItem("Item Pool", tabName = "item_pool", icon = icon("database")),
      menuItem("Settings", tabName = "settings", icon = icon("cogs"))
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .content-wrapper, .right-side {
          background-color: #f4f4f4;
        }
        .box {
          border-radius: 5px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .progress-bar {
          background-color: #3c8dbc;
        }
        .item-text {
          font-size: 16px;
          line-height: 1.5;
          margin: 15px 0;
        }
        .response-buttons {
          margin: 20px 0;
        }
        .response-buttons button {
          margin: 5px;
          padding: 10px 20px;
          font-size: 14px;
        }
      "))
    ),
    
    tabItems(
      # CAT Testing Tab
      tabItem(tabName = "cat_test",
        fluidRow(
          # Test Progress Panel
          box(
            title = "CAT Assessment Progress", status = "primary", solidHeader = TRUE,
            width = 12, height = "200px",
            fluidRow(
              column(4,
                valueBoxOutput("items_administered", width = NULL)
              ),
              column(4,
                valueBoxOutput("current_theta", width = NULL)
              ),
              column(4,
                valueBoxOutput("standard_error", width = NULL)
              )
            ),
            br(),
            div(style = "padding: 0 15px;",
              progressBar(id = "test_progress", value = 0, total = 20, 
                         title = "Assessment Progress", display_pct = TRUE)
            )
          )
        ),
        
        fluidRow(
          # Current Item Panel
          column(8,
            box(
              title = "Current Assessment Item", status = "info", solidHeader = TRUE,
              width = NULL, height = "400px",
              div(id = "item_container",
                div(class = "item-text", 
                  h4("Welcome to the GCLS-G Computerized Adaptive Test"),
                  p("This adaptive assessment will select the most informative items based on your responses. 
                    The test will automatically stop when sufficient precision is reached, typically after 10-15 items."),
                  p("Click 'Start Assessment' to begin.")
                ),
                div(class = "response-buttons", id = "response_area",
                  actionButton("start_test", "Start Assessment", 
                             class = "btn-success btn-lg", style = "margin-top: 20px;")
                )
              )
            )
          ),
          
          # Real-time Results Panel
          column(4,
            box(
              title = "Real-time Results", status = "warning", solidHeader = TRUE,
              width = NULL, height = "400px",
              plotlyOutput("theta_plot", height = "200px"),
              br(),
              tableOutput("current_stats")
            )
          )
        ),
        
        fluidRow(
          # Item Selection Visualization
          box(
            title = "Item Information Curve", status = "success", solidHeader = TRUE,
            width = 6, height = "350px",
            plotlyOutput("information_plot", height = "300px")
          ),
          
          # Response History
          box(
            title = "Response History", status = "primary", solidHeader = TRUE,
            width = 6, height = "350px",
            DT::dataTableOutput("response_history", height = "300px")
          )
        )
      ),
      
      # Performance Analysis Tab
      tabItem(tabName = "performance",
        fluidRow(
          box(
            title = "CAT vs Full Test Comparison", status = "primary", solidHeader = TRUE,
            width = 12,
            actionButton("run_simulation", "Run Performance Simulation", 
                        class = "btn-primary", style = "margin-bottom: 15px;"),
            plotlyOutput("performance_plot")
          )
        ),
        
        fluidRow(
          box(
            title = "Efficiency Metrics", status = "info", solidHeader = TRUE,
            width = 6,
            tableOutput("efficiency_table")
          ),
          
          box(
            title = "Precision Analysis", status = "warning", solidHeader = TRUE,
            width = 6,
            plotlyOutput("precision_plot")
          )
        )
      ),
      
      # Item Pool Tab
      tabItem(tabName = "item_pool",
        fluidRow(
          box(
            title = "GCLS-G Item Parameters", status = "primary", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("item_parameters_table")
          )
        ),
        
        fluidRow(
          box(
            title = "Discrimination vs Difficulty", status = "info", solidHeader = TRUE,
            width = 6,
            plotlyOutput("item_scatter")
          ),
          
          box(
            title = "Item Information Functions", status = "success", solidHeader = TRUE,
            width = 6,
            plotlyOutput("item_information_curves")
          )
        )
      ),
      
      # Settings Tab
      tabItem(tabName = "settings",
        fluidRow(
          box(
            title = "CAT Algorithm Settings", status = "primary", solidHeader = TRUE,
            width = 6,
            numericInput("max_items", "Maximum Items:", value = 20, min = 5, max = 38),
            numericInput("se_threshold", "SE Threshold:", value = 0.30, min = 0.1, max = 0.5, step = 0.05),
            numericInput("min_items", "Minimum Items:", value = 5, min = 3, max = 15),
            checkboxInput("use_exposure_control", "Use Exposure Control", value = FALSE),
            actionButton("apply_settings", "Apply Settings", class = "btn-success")
          ),
          
          box(
            title = "Simulation Parameters", status = "info", solidHeader = TRUE,
            width = 6,
            numericInput("n_simulations", "Number of Simulations:", value = 100, min = 10, max = 500),
            selectInput("stopping_rule", "Stopping Rule:",
                       choices = list("Standard Error" = "se", 
                                    "Fixed Length" = "fixed",
                                    "Hybrid" = "hybrid")),
            numericInput("initial_theta", "Initial Theta:", value = 0, min = -3, max = 3, step = 0.1),
            actionButton("reset_settings", "Reset to Defaults", class = "btn-warning")
          )
        )
      )
    )
  )
)

# =============================================================================
# Server Logic
# =============================================================================

server <- function(input, output, session) {
  
  # Reactive values for test state
  values <- reactiveValues(
    test_active = FALSE,
    current_item = 1,
    administered_items = c(),
    responses = c(),
    theta_estimates = c(),
    se_estimates = c(),
    available_items = 1:38,
    current_theta = 0,
    item_count = 0,
    test_complete = FALSE
  )
  
  # Initialize item parameters
  item_params <- reactive({
    data.frame(
      item = 1:38,
      discrimination = runif(38, 0.8, 2.5),
      difficulty = rnorm(38, 0, 1),
      factor = rep(1:7, times = c(7,5,5,4,5,6,6)),
      subscale = rep(c("Psychological Functioning", "Genitalia", "Social Gender Role",
                      "Physical & Emotional Intimacy", "Chest", 
                      "Other Secondary Sex", "Life Satisfaction"), 
                    times = c(7,5,5,4,5,6,6))
    )
  })
  
  # Sample GCLS items for demonstration
  gcls_items <- c(
    "I was happy with my body",
    "I felt comfortable with my genitalia",
    "I felt that others saw me as my true gender",
    "I felt comfortable being intimate with others",
    "I was satisfied with my chest/breast area",
    "I was comfortable with my voice",
    "I felt satisfied with my life overall"
  )
  
  # Start Test Event
  observeEvent(input$start_test, {
    values$test_active <- TRUE
    values$current_item <- 1
    values$administered_items <- c()
    values$responses <- c()
    values$theta_estimates <- c()
    values$se_estimates <- c()
    values$available_items <- 1:38
    values$current_theta <- input$initial_theta
    values$item_count <- 0
    values$test_complete <- FALSE
    
    # Select first item
    next_item <- select_next_item(values$current_theta, values$available_items, item_params())
    values$current_item <- next_item
    
    # Update UI with first item
    output$item_container <- renderUI({
      div(
        div(class = "item-text",
          h4(paste("Item", values$item_count + 1)),
          p(paste("Subscale:", item_params()$subscale[next_item])),
          p(gcls_items[((next_item - 1) %% 7) + 1])  # Cycle through sample items
        ),
        div(class = "response-buttons",
          lapply(1:5, function(i) {
            label <- c("Always", "Often", "Sometimes", "Rarely", "Never")[i]
            actionButton(paste0("response_", i), label, 
                        class = paste0("btn-response btn-", c("success", "info", "warning", "danger", "default")[i]))
          })
        )
      )
    })
  })
  
  # Response Event Handlers
  lapply(1:5, function(i) {
    observeEvent(input[[paste0("response_", i)]], {
      if (values$test_active && !values$test_complete) {
        # Record response
        values$responses <- c(values$responses, i)
        values$administered_items <- c(values$administered_items, values$current_item)
        values$available_items <- setdiff(values$available_items, values$current_item)
        values$item_count <- values$item_count + 1
        
        # Update theta estimate
        if (length(values$responses) > 0) {
          values$current_theta <- update_theta(values$responses, values$administered_items, item_params())
          values$theta_estimates <- c(values$theta_estimates, values$current_theta)
        }
        
        # Calculate SE
        if (length(values$responses) >= 3) {
          total_info <- sum(sapply(values$administered_items, function(item) {
            item_information(values$current_theta, 
                           item_params()$discrimination[item], 
                           item_params()$difficulty[item])
          }))
          se <- 1 / sqrt(total_info)
          values$se_estimates <- c(values$se_estimates, se)
        } else {
          values$se_estimates <- c(values$se_estimates, 1.0)
        }
        
        # Check stopping criteria
        current_se <- tail(values$se_estimates, 1)
        if (current_se < input$se_threshold || values$item_count >= input$max_items) {
          values$test_complete <- TRUE
          
          # Show completion message
          output$item_container <- renderUI({
            div(class = "item-text",
              h3("Assessment Complete!", style = "color: green;"),
              p(paste("Items administered:", values$item_count)),
              p(paste("Final theta estimate:", round(values$current_theta, 2))),
              p(paste("Standard error:", round(current_se, 3))),
              p(paste("GCLS score:", round(mean(values$responses), 2))),
              actionButton("restart_test", "Start New Assessment", class = "btn-primary")
            )
          })
        } else {
          # Select next item
          next_item <- select_next_item(values$current_theta, values$available_items, item_params())
          values$current_item <- next_item
          
          # Update UI with next item
          output$item_container <- renderUI({
            div(
              div(class = "item-text",
                h4(paste("Item", values$item_count + 1)),
                p(paste("Subscale:", item_params()$subscale[next_item])),
                p(gcls_items[((next_item - 1) %% 7) + 1])
              ),
              div(class = "response-buttons",
                lapply(1:5, function(j) {
                  label <- c("Always", "Often", "Sometimes", "Rarely", "Never")[j]
                  actionButton(paste0("response_", j), label, 
                              class = paste0("btn-response btn-", c("success", "info", "warning", "danger", "default")[j]))
                })
              )
            )
          })
        }
      }
    })
  })
  
  # Restart Test Event
  observeEvent(input$restart_test, {
    values$test_active <- FALSE
    output$item_container <- renderUI({
      div(class = "item-text",
        h4("Welcome to the GCLS-G Computerized Adaptive Test"),
        p("Click 'Start Assessment' to begin a new assessment."),
        actionButton("start_test", "Start Assessment", class = "btn-success btn-lg")
      )
    })
  })
  
  # Value Boxes
  output$items_administered <- renderValueBox({
    valueBox(
      value = if(values$test_active) values$item_count else 0,
      subtitle = "Items Administered",
      icon = icon("list-ol"),
      color = "blue"
    )
  })
  
  output$current_theta <- renderValueBox({
    valueBox(
      value = if(length(values$theta_estimates) > 0) round(tail(values$theta_estimates, 1), 2) else "0.00",
      subtitle = "Current Theta",
      icon = icon("chart-line"),
      color = "green"
    )
  })
  
  output$standard_error <- renderValueBox({
    valueBox(
      value = if(length(values$se_estimates) > 0) round(tail(values$se_estimates, 1), 3) else "1.000",
      subtitle = "Standard Error",
      icon = icon("crosshairs"),
      color = if(length(values$se_estimates) > 0 && tail(values$se_estimates, 1) < input$se_threshold) "yellow" else "red"
    )
  })
  
  # Progress Bar Update
  observe({
    if (values$test_active) {
      progress_value <- min(values$item_count, input$max_items)
      updateProgressBar(session, "test_progress", value = progress_value, total = input$max_items)
    }
  })
  
  # Real-time Theta Plot
  output$theta_plot <- renderPlotly({
    if (length(values$theta_estimates) > 0) {
      df <- data.frame(
        item = 1:length(values$theta_estimates),
        theta = values$theta_estimates
      )
      
      p <- ggplot(df, aes(x = item, y = theta)) +
        geom_line(color = "blue", size = 1) +
        geom_point(color = "red", size = 2) +
        labs(title = "Theta Convergence", x = "Item", y = "Theta Estimate") +
        theme_minimal()
      
      ggplotly(p)
    }
  })
  
  # Current Statistics Table
  output$current_stats <- renderTable({
    if (values$test_active && length(values$responses) > 0) {
      data.frame(
        Statistic = c("Mean Response", "Response SD", "Precision"),
        Value = c(
          round(mean(values$responses), 2),
          round(sd(values$responses), 2),
          if(length(values$se_estimates) > 0) round(1/tail(values$se_estimates, 1), 1) else "N/A"
        )
      )
    }
  }, striped = TRUE, hover = TRUE)
  
  # Information Plot
  output$information_plot <- renderPlotly({
    if (values$test_active && length(values$administered_items) > 0) {
      theta_range <- seq(-3, 3, by = 0.1)
      current_item <- tail(values$administered_items, 1)
      
      info_values <- sapply(theta_range, function(theta) {
        item_information(theta, 
                        item_params()$discrimination[current_item], 
                        item_params()$difficulty[current_item])
      })
      
      df <- data.frame(theta = theta_range, information = info_values)
      
      p <- ggplot(df, aes(x = theta, y = information)) +
        geom_line(color = "blue", size = 1) +
        geom_vline(xintercept = values$current_theta, color = "red", linetype = "dashed") +
        labs(title = paste("Information Curve - Item", current_item), 
             x = "Theta", y = "Information") +
        theme_minimal()
      
      ggplotly(p)
    }
  })
  
  # Response History Table
  output$response_history <- DT::renderDataTable({
    if (length(values$responses) > 0) {
      data.frame(
        Item = values$administered_items,
        Subscale = item_params()$subscale[values$administered_items],
        Response = values$responses,
        Theta = round(values$theta_estimates, 2),
        SE = round(values$se_estimates, 3)
      )
    }
  }, options = list(pageLength = 10, scrollY = "250px"))
  
  # Item Parameters Table
  output$item_parameters_table <- DT::renderDataTable({
    item_params() %>%
      mutate(
        discrimination = round(discrimination, 2),
        difficulty = round(difficulty, 2)
      )
  }, options = list(pageLength = 15))
  
  # Item Scatter Plot
  output$item_scatter <- renderPlotly({
    p <- ggplot(item_params(), aes(x = difficulty, y = discrimination, color = subscale)) +
      geom_point(size = 3, alpha = 0.7) +
      labs(title = "Item Parameter Space", 
           x = "Difficulty", y = "Discrimination") +
      theme_minimal() +
      theme(legend.position = "bottom")
    
    ggplotly(p)
  })
  
  # Performance Simulation
  observeEvent(input$run_simulation, {
    withProgress(message = 'Running simulation...', value = 0, {
      # Run simplified simulation
      n_sims <- min(input$n_simulations, 50)  # Limit for dashboard responsiveness
      results <- list()
      
      for (i in 1:n_sims) {
        incProgress(1/n_sims, detail = paste("Simulation", i))
        
        # Simulate participant
        participant_data <- sample(1:5, 38, replace = TRUE, prob = c(0.1, 0.2, 0.4, 0.2, 0.1))
        
        # Run CAT
        cat_result <- cat_administration(participant_data, item_params(), 
                                       max_items = input$max_items, 
                                       se_threshold = input$se_threshold)
        
        results[[i]] <- data.frame(
          simulation = i,
          items_used = cat_result$n_items_used,
          final_theta = cat_result$final_theta,
          final_se = cat_result$final_se,
          full_score = mean(participant_data),
          cat_score = mean(cat_result$responses)
        )
      }
      
      simulation_data <- do.call(rbind, results)
      
      # Performance plot
      output$performance_plot <- renderPlotly({
        p <- ggplot(simulation_data, aes(x = full_score, y = cat_score)) +
          geom_point(alpha = 0.6, color = "steelblue") +
          geom_smooth(method = "lm", color = "red", se = FALSE) +
          geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
          labs(title = "CAT vs Full Test Scores", 
               x = "Full Test Score", y = "CAT Score") +
          theme_minimal()
        
        ggplotly(p)
      })
      
      # Efficiency metrics
      output$efficiency_table <- renderTable({
        data.frame(
          Metric = c("Mean Items Used", "Item Reduction", "Correlation", "Mean SE"),
          Value = c(
            round(mean(simulation_data$items_used), 1),
            paste0(round((1 - mean(simulation_data$items_used)/38) * 100, 1), "%"),
            round(cor(simulation_data$full_score, simulation_data$cat_score), 3),
            round(mean(simulation_data$final_se), 3)
          )
        )
      }, striped = TRUE)
      
      # Precision plot
      output$precision_plot <- renderPlotly({
        p <- ggplot(simulation_data, aes(x = final_se)) +
          geom_histogram(bins = 15, fill = "lightblue", alpha = 0.7) +
          geom_vline(xintercept = input$se_threshold, color = "red", linetype = "dashed") +
          labs(title = "Standard Error Distribution", 
               x = "Standard Error", y = "Frequency") +
          theme_minimal()
        
        ggplotly(p)
      })
    })
  })
}

# =============================================================================
# Run the Dashboard
# =============================================================================

# Custom progress bar function
progressBar <- function(id, value, total, title = "", display_pct = FALSE) {
  percentage <- round(value / total * 100)
  
  div(
    h5(title),
    div(class = "progress",
      div(class = "progress-bar", 
          role = "progressbar", 
          style = paste0("width: ", percentage, "%"),
          paste0(value, "/", total, if(display_pct) paste0(" (", percentage, "%)") else "")
      )
    )
  )
}

# Function to update progress bar
updateProgressBar <- function(session, id, value, total) {
  percentage <- round(value / total * 100)
  session$sendCustomMessage("updateProgress", list(
    id = id,
    value = value,
    total = total,
    percentage = percentage
  ))
}

# Add custom JavaScript for progress bar updates
shinyApp(ui = ui, server = server) 