
# GCLS-G CAT Information Function
max_information_selection <- function(theta_current, item_params, administered_items) {
    # Berechne Information für alle verfügbaren Items
    info_values <- sapply(1:nrow(item_params), function(i) {
        if (i %in% administered_items) return(0)  # Bereits verwendete Items ausschließen
        
        a <- item_params$discrimination[i]
        b <- item_params$difficulty[i]
        
        # 2PL Information Function
        p <- 1 / (1 + exp(-a * (theta_current - b)))
        info <- a^2 * p * (1 - p)
        return(info)
    })
    
    # Wähle Item mit höchster Information
    next_item <- which.max(info_values)
    return(list(item = next_item, information = max(info_values)))
}

# Content Balancing für 7 Subskalen
content_balanced_selection <- function(theta, item_params, administered, subscale_counts) {
    # Prüfe Subskalen-Balance
    min_subscale <- which.min(subscale_counts)
    
    if (subscale_counts[min_subscale] < 2) {
        # Erzwinge Item aus unterrepräsentierter Subskala
        subscale_items <- which(item_params$subscale == min_subscale)
        available <- setdiff(subscale_items, administered)
        
        if (length(available) > 0) {
            return(max_information_selection(theta, item_params[available,], c()))
        }
    }
    
    # Standard Maximum Information
    return(max_information_selection(theta, item_params, administered))
}
