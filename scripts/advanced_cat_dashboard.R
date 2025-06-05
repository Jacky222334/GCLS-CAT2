# =============================================================================
# Advanced CAT Dashboard for GCLS-G (Native HTML/JavaScript Version)
# Comprehensive Computerized Adaptive Testing Implementation
# =============================================================================

# Load available packages
suppressPackageStartupMessages({
  library(plotly)
  library(ggplot2)
  library(dplyr)
  library(DT)
})

# =============================================================================
# CAT Algorithm Implementation
# =============================================================================

# Item Response Theory functions
irt_probability <- function(theta, a, b) {
  # 2PL IRT model probability
  exp_val <- exp(a * (theta - b))
  exp_val / (1 + exp_val)
}

item_information <- function(theta, a, b) {
  # Item information function
  p <- irt_probability(theta, a, b)
  a^2 * p * (1 - p)
}

# CAT item selection using Maximum Information
select_next_item <- function(theta, available_items, item_params) {
  if (length(available_items) == 0) return(NULL)
  
  information_values <- sapply(available_items, function(item) {
    item_information(theta, 
                    item_params$discrimination[item], 
                    item_params$difficulty[item])
  })
  
  selected_item <- available_items[which.max(information_values)]
  return(selected_item)
}

# Theta estimation using Maximum Likelihood
update_theta <- function(responses, administered_items, item_params, 
                        theta_range = seq(-4, 4, by = 0.01)) {
  
  if (length(responses) == 0) return(0)
  
  log_likelihood <- function(theta) {
    ll <- 0
    for (i in 1:length(responses)) {
      item <- administered_items[i]
      a <- item_params$discrimination[item]
      b <- item_params$difficulty[item]
      
      # Convert response to binary (assuming 1-5 scale, >3 = success)
      response <- as.numeric(responses[i] > 3)
      
      p <- irt_probability(theta, a, b)
      if (response == 1) {
        ll <- ll + log(p + 1e-10)  # Add small constant to avoid log(0)
      } else {
        ll <- ll + log(1 - p + 1e-10)
      }
    }
    return(ll)
  }
  
  likelihood_values <- sapply(theta_range, log_likelihood)
  return(theta_range[which.max(likelihood_values)])
}

# Complete CAT administration
cat_administration <- function(true_responses = NULL, item_params, 
                              max_items = 20, se_threshold = 0.30, min_items = 5) {
  
  administered_items <- c()
  responses <- c()
  theta_estimates <- c()
  se_estimates <- c()
  available_items <- 1:nrow(item_params)
  current_theta <- 0
  
  cat("Starting CAT Administration...\n")
  cat("Maximum items:", max_items, "| SE threshold:", se_threshold, "\n\n")
  
  for (item_count in 1:max_items) {
    # Select next item
    next_item <- select_next_item(current_theta, available_items, item_params)
    if (is.null(next_item)) break
    
    # Simulate or get response
    if (!is.null(true_responses)) {
      response <- true_responses[next_item]
    } else {
      # Simulate response based on current theta
      prob <- irt_probability(current_theta, 
                             item_params$discrimination[next_item], 
                             item_params$difficulty[next_item])
      response <- ifelse(runif(1) < prob, sample(4:5, 1), sample(1:3, 1))
    }
    
    # Update test state
    administered_items <- c(administered_items, next_item)
    responses <- c(responses, response)
    available_items <- setdiff(available_items, next_item)
    
    # Update theta estimate
    current_theta <- update_theta(responses, administered_items, item_params)
    theta_estimates <- c(theta_estimates, current_theta)
    
    # Calculate standard error
    total_info <- sum(sapply(administered_items, function(item) {
      item_information(current_theta, 
                      item_params$discrimination[item], 
                      item_params$difficulty[item])
    }))
    se <- ifelse(total_info > 0, 1 / sqrt(total_info), 1.0)
    se_estimates <- c(se_estimates, se)
    
    # Progress report
    cat("Item", item_count, "- Item:", next_item, 
        "| Response:", response, 
        "| Theta:", round(current_theta, 3), 
        "| SE:", round(se, 3), "\n")
    
    # Check stopping criteria
    if (item_count >= min_items && se < se_threshold) {
      cat("\nStopping criterion met: SE =", round(se, 3), "<", se_threshold, "\n")
      break
    }
  }
  
  cat("\nCAT completed!\n")
  cat("Items administered:", length(administered_items), "/", max_items, "\n")
  cat("Final theta estimate:", round(current_theta, 3), "\n")
  cat("Final SE:", round(tail(se_estimates, 1), 3), "\n")
  
  return(list(
    administered_items = administered_items,
    responses = responses,
    theta_estimates = theta_estimates,
    se_estimates = se_estimates,
    final_theta = current_theta,
    final_se = tail(se_estimates, 1),
    n_items_used = length(administered_items)
  ))
}

# =============================================================================
# GCLS-G Item Parameters (Simulated)
# =============================================================================

create_gcls_items <- function() {
  # Create 38-item GCLS-G parameter set with realistic values
  set.seed(42)  # For reproducibility
  
  item_params <- data.frame(
    item = 1:38,
    discrimination = runif(38, 0.8, 2.5),
    difficulty = rnorm(38, 0, 1),
    subscale = rep(c("Psychological Functioning", "Genitalia", "Social Gender Role",
                    "Physical & Emotional Intimacy", "Chest", 
                    "Other Secondary Sex", "Life Satisfaction"), 
                   times = c(7,5,5,4,5,6,6)),
    content = c(
      # Psychological Functioning (7 items)
      "I was happy with my body", "I felt comfortable in my own skin",
      "I felt content with my psychological well-being", "I was satisfied with my mental health",
      "I felt at peace with myself", "I was happy with how I felt emotionally",
      "I felt good about my psychological state",
      
      # Genitalia (5 items)  
      "I felt comfortable with my genitalia", "I was satisfied with my genital area",
      "I felt at ease with my genitals", "I was happy with my genital anatomy",
      "I felt comfortable with my genital functioning",
      
      # Social Gender Role (5 items)
      "I felt that others saw me as my true gender", "I was perceived as my authentic gender",
      "Others recognized me as my real gender", "I felt accepted in my gender role",
      "I was comfortable in social gender situations",
      
      # Physical & Emotional Intimacy (4 items)
      "I felt comfortable being intimate with others", "I was at ease during intimate moments",
      "I felt secure in intimate relationships", "I was comfortable with physical intimacy",
      
      # Chest (5 items)
      "I was satisfied with my chest/breast area", "I felt comfortable with my chest",
      "I was happy with my chest appearance", "I felt at ease with my chest area",
      "I was satisfied with my chest development",
      
      # Other Secondary Sex (6 items)
      "I was comfortable with my voice", "I felt satisfied with my body hair",
      "I was happy with my facial features", "I felt comfortable with my body shape",
      "I was satisfied with my skin texture", "I felt at ease with my physical features",
      
      # Life Satisfaction (6 items)
      "I felt satisfied with my life overall", "I was content with my general well-being",
      "I felt happy with my life situation", "I was satisfied with my quality of life",
      "I felt fulfilled in my daily life", "I was happy with my life circumstances"
    )
  )
  
  return(item_params)
}

# =============================================================================
# Visualization Functions
# =============================================================================

plot_item_information_curves <- function(item_params, selected_items = NULL) {
  theta_range <- seq(-3, 3, by = 0.1)
  
  # Calculate information for all items
  info_data <- expand.grid(theta = theta_range, item = 1:nrow(item_params))
  info_data$information <- mapply(function(theta, item) {
    item_information(theta, 
                    item_params$discrimination[item], 
                    item_params$difficulty[item])
  }, info_data$theta, info_data$item)
  
  info_data$subscale <- item_params$subscale[info_data$item]
  
  # Highlight selected items if provided
  if (!is.null(selected_items)) {
    info_data$selected <- info_data$item %in% selected_items
  }
  
  p <- ggplot(info_data, aes(x = theta, y = information, group = item)) +
    geom_line(alpha = 0.6, color = "steelblue") +
    labs(title = "GCLS-G Item Information Functions",
         x = "Theta (Ability)", 
         y = "Information") +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  if (!is.null(selected_items)) {
    selected_data <- info_data[info_data$item %in% selected_items, ]
    p <- p + geom_line(data = selected_data, color = "red", size = 1.2, alpha = 0.8)
  }
  
  return(ggplotly(p))
}

plot_theta_convergence <- function(cat_result) {
  if (length(cat_result$theta_estimates) == 0) return(NULL)
  
  convergence_data <- data.frame(
    item = 1:length(cat_result$theta_estimates),
    theta = cat_result$theta_estimates,
    se = cat_result$se_estimates,
    upper = cat_result$theta_estimates + 1.96 * cat_result$se_estimates,
    lower = cat_result$theta_estimates - 1.96 * cat_result$se_estimates
  )
  
  p <- ggplot(convergence_data, aes(x = item)) +
    geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.3, fill = "blue") +
    geom_line(aes(y = theta), color = "blue", size = 1.2) +
    geom_point(aes(y = theta), color = "red", size = 2) +
    labs(title = "Theta Estimate Convergence",
         x = "Item Number", 
         y = "Theta Estimate (±95% CI)") +
    theme_minimal()
  
  return(ggplotly(p))
}

plot_item_selection_pattern <- function(cat_result, item_params) {
  if (length(cat_result$administered_items) == 0) return(NULL)
  
  selection_data <- data.frame(
    order = 1:length(cat_result$administered_items),
    item = cat_result$administered_items,
    subscale = item_params$subscale[cat_result$administered_items],
    difficulty = item_params$difficulty[cat_result$administered_items],
    discrimination = item_params$discrimination[cat_result$administered_items],
    response = cat_result$responses
  )
  
  p <- ggplot(selection_data, aes(x = order, y = difficulty, 
                                 color = subscale, size = discrimination)) +
    geom_point(alpha = 0.8) +
    geom_line(alpha = 0.6, color = "gray50") +
    labs(title = "Item Selection Pattern",
         x = "Selection Order", 
         y = "Item Difficulty",
         size = "Discrimination",
         color = "Subscale") +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  return(ggplotly(p))
}

# =============================================================================
# Performance Analysis Functions
# =============================================================================

run_cat_simulation <- function(item_params, n_simulations = 100, 
                              max_items = 20, se_threshold = 0.30) {
  
  cat("Running", n_simulations, "CAT simulations...\n")
  
  results <- list()
  
  for (i in 1:n_simulations) {
    if (i %% 20 == 0) cat("Simulation", i, "/", n_simulations, "\n")
    
    # Generate true participant responses
    true_theta <- rnorm(1, 0, 1)
    true_responses <- sapply(1:nrow(item_params), function(item) {
      prob <- irt_probability(true_theta, 
                             item_params$discrimination[item], 
                             item_params$difficulty[item])
      ifelse(runif(1) < prob, sample(4:5, 1), sample(1:3, 1))
    })
    
    # Run CAT
    cat_result <- cat_administration(true_responses, item_params, 
                                    max_items, se_threshold, min_items = 5)
    
    # Calculate full test score
    full_score <- mean(true_responses)
    cat_score <- mean(cat_result$responses)
    
    results[[i]] <- data.frame(
      simulation = i,
      true_theta = true_theta,
      estimated_theta = cat_result$final_theta,
      theta_error = abs(true_theta - cat_result$final_theta),
      items_used = cat_result$n_items_used,
      final_se = cat_result$final_se,
      full_score = full_score,
      cat_score = cat_score,
      efficiency = (38 - cat_result$n_items_used) / 38,
      correlation = cor(c(true_theta, cat_result$final_theta), c(true_theta, cat_result$final_theta))
    )
  }
  
  simulation_data <- do.call(rbind, results)
  
  cat("\n=== Simulation Results ===\n")
  cat("Mean items used:", round(mean(simulation_data$items_used), 1), "/", 38, "\n")
  cat("Item reduction:", round(mean(simulation_data$efficiency) * 100, 1), "%\n")
  cat("Mean SE:", round(mean(simulation_data$final_se), 3), "\n")
  cat("Theta correlation:", round(cor(simulation_data$true_theta, simulation_data$estimated_theta), 3), "\n")
  cat("Score correlation:", round(cor(simulation_data$full_score, simulation_data$cat_score), 3), "\n")
  
  return(simulation_data)
}

plot_simulation_results <- function(simulation_data) {
  # Efficiency plot
  p1 <- ggplot(simulation_data, aes(x = items_used)) +
    geom_histogram(bins = 15, fill = "lightblue", alpha = 0.7, color = "black") +
    geom_vline(xintercept = mean(simulation_data$items_used), 
               color = "red", linetype = "dashed", size = 1) +
    labs(title = "Distribution of Items Used",
         x = "Number of Items", y = "Frequency") +
    theme_minimal()
  
  # Correlation plot
  p2 <- ggplot(simulation_data, aes(x = true_theta, y = estimated_theta)) +
    geom_point(alpha = 0.6, color = "steelblue") +
    geom_smooth(method = "lm", color = "red", se = FALSE) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray") +
    labs(title = "True vs Estimated Theta",
         x = "True Theta", y = "Estimated Theta") +
    theme_minimal()
  
  # SE distribution
  p3 <- ggplot(simulation_data, aes(x = final_se)) +
    geom_histogram(bins = 15, fill = "lightgreen", alpha = 0.7, color = "black") +
    geom_vline(xintercept = 0.30, color = "red", linetype = "dashed", size = 1) +
    labs(title = "Standard Error Distribution",
         x = "Final Standard Error", y = "Frequency") +
    theme_minimal()
  
  # Score correlation
  p4 <- ggplot(simulation_data, aes(x = full_score, y = cat_score)) +
    geom_point(alpha = 0.6, color = "purple") +
    geom_smooth(method = "lm", color = "red", se = FALSE) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray") +
    labs(title = "Full Test vs CAT Score",
         x = "Full Test Score", y = "CAT Score") +
    theme_minimal()
  
  return(list(
    efficiency = ggplotly(p1),
    theta_correlation = ggplotly(p2),
    se_distribution = ggplotly(p3),
    score_correlation = ggplotly(p4)
  ))
}

# =============================================================================
# Main Dashboard Function
# =============================================================================

run_advanced_cat_dashboard <- function() {
  cat("\n")
  cat("===============================================\n")
  cat("  GCLS-G Advanced CAT Dashboard\n") 
  cat("  Computerized Adaptive Testing Analysis\n")
  cat("===============================================\n\n")
  
  # Initialize item parameters
  item_params <- create_gcls_items()
  
  # Display menu
  repeat {
    cat("\n--- Main Menu ---\n")
    cat("1. View GCLS-G Item Parameters\n")
    cat("2. Run Single CAT Assessment\n")
    cat("3. Run Performance Simulation\n")
    cat("4. Generate Item Information Plots\n")
    cat("5. Export Results to HTML\n")
    cat("6. Exit\n")
    
    choice <- as.numeric(readline("Choose option (1-6): "))
    
    if (choice == 1) {
      cat("\n=== GCLS-G Item Parameters ===\n")
      print(DT::datatable(item_params %>% 
                         mutate(discrimination = round(discrimination, 2),
                               difficulty = round(difficulty, 2)),
                         options = list(pageLength = 15)))
      
    } else if (choice == 2) {
      cat("\n=== Single CAT Assessment ===\n")
      max_items <- as.numeric(readline("Maximum items (default 20): ") %||% 20)
      se_threshold <- as.numeric(readline("SE threshold (default 0.30): ") %||% 0.30)
      
      cat_result <- cat_administration(NULL, item_params, max_items, se_threshold)
      
      # Generate visualizations
      plots <- list(
        convergence = plot_theta_convergence(cat_result),
        selection = plot_item_selection_pattern(cat_result, item_params),
        information = plot_item_information_curves(item_params, cat_result$administered_items)
      )
      
      cat("\nGenerating interactive plots...\n")
      print(plots$convergence)
      print(plots$selection)
      print(plots$information)
      
    } else if (choice == 3) {
      cat("\n=== Performance Simulation ===\n")
      n_sims <- as.numeric(readline("Number of simulations (default 100): ") %||% 100)
      max_items <- as.numeric(readline("Maximum items (default 20): ") %||% 20)
      se_threshold <- as.numeric(readline("SE threshold (default 0.30): ") %||% 0.30)
      
      simulation_data <- run_cat_simulation(item_params, n_sims, max_items, se_threshold)
      sim_plots <- plot_simulation_results(simulation_data)
      
      cat("\nGenerating simulation plots...\n")
      print(sim_plots$efficiency)
      print(sim_plots$theta_correlation) 
      print(sim_plots$se_distribution)
      print(sim_plots$score_correlation)
      
    } else if (choice == 4) {
      cat("\n=== Item Information Analysis ===\n")
      info_plot <- plot_item_information_curves(item_params)
      print(info_plot)
      
    } else if (choice == 5) {
      cat("\n=== Export Results ===\n")
      cat("This would generate HTML reports with all visualizations.\n")
      cat("Feature available in full Shiny version.\n")
      
    } else if (choice == 6) {
      cat("Exiting CAT Dashboard. Goodbye!\n")
      break
      
    } else {
      cat("Invalid choice. Please select 1-6.\n")
    }
  }
}

# =============================================================================
# Launch Dashboard
# =============================================================================

cat("GCLS-G Advanced CAT Dashboard Loaded!\n")
cat("Available functions:\n")
cat("- run_advanced_cat_dashboard()  : Start interactive menu\n")
cat("- create_gcls_items()          : Generate item parameters\n") 
cat("- cat_administration()         : Run single CAT\n")
cat("- run_cat_simulation()         : Run performance analysis\n")
cat("\nTo start: run_advanced_cat_dashboard()\n\n")

# Auto-start dashboard
run_advanced_cat_dashboard() 