
shinyServer(function(input, output, session){
  
  #########################################################################################################################
  ## Dow Jones ############################################################################################################
  
  output$comp_graph_dj = renderPlotly({
    
    index_name1 = input$index_name1
    index_name2 = input$index_name2
    coin_name1 = is.coin(input$coin_name1)
    coin_name2 = is.coin(input$coin_name2)
    coluna = switch(input$coluna_dj, "Day movement (Open x close values)" = "day_movement",
                    "Day volatility (High x low values)" = "volatility")
    
    min = min(input$date_dj)
    max = max(input$date_dj)
    
    data = filter(all_values, (index == index_name1 & name %in% coin_name1) | 
                    (index == index_name2 & name %in% coin_name2)) %>%
      select(date, name, index, coluna)
    
    ggplot(data, aes(x = data[,"date"], y = data[,coluna])) + geom_line(aes(color = data[,"index"])) + 
      scale_x_date(date_breaks = "1 year", limits = c(min, max)) + xlab("Day") + ylab(coluna)
  
    })

  output$corr_graph_dj = renderPlotly({
    
    index_name1 = input$index_name1
    index_name2 = input$index_name2
    coin_name1 = is.coin(input$coin_name1)
    coin_name2 = is.coin(input$coin_name2)
    coluna = switch(input$coluna_dj, "Day movement (Open x close values)" = "day_movement",
                    "Day volatility (High x low values)" = "volatility")
    
    min = min(input$date_dj)
    max = max(input$date_dj)
    
    data_coins = filter(all_values, date>= min & date<=max) %>%
      filter(., index == index_name1 | index == index_name2)%>%
      filter(., name %in% coin_name1 | name %in% coin_name2)%>%
      select("date", "index", coluna) %>%
      spread(., key = "index", value = coluna) %>%
      select(., -date) 
    
    ggplot(data_coins, aes(x = data_coins[,index_name1], y = data_coins[,index_name2])) + geom_point() + geom_smooth(method = "lm") +
      xlab(index_name1) + ylab(index_name2) + ggtitle(paste("Correlation between", index_name1, "and", index_name2, coluna))
    
  })
  
  output$pvalue_dj = renderInfoBox({
    
    index_name1 = input$index_name1
    index_name2 = input$index_name2
    coin_name1 = is.coin(input$coin_name1)
    coin_name2 = is.coin(input$coin_name2)
    coluna = switch(input$coluna_dj, "Day movement (Open x close values)" = "day_movement",
                    "Day volatility (High x low values)" = "volatility")
    
    min = min(input$date_dj)
    max = max(input$date_dj)
    
    data_coins = filter(all_values, date>= min & date<=max) %>%
      filter(., index == index_name1 | index == index_name2)%>%
      filter(., name %in% coin_name1 | name %in% coin_name2)%>%
      select("date", "index", coluna) %>%
      spread(., key = "index", value = coluna) %>%
      select(., -date) 
    
    model = lm(data_coins[,index_name2] ~ data_coins[,index_name1])
    sm_model = summary(model)
    
    p_value = sm_model$coefficients[2,4]
    
    subtitle = ifelse(p_value>0.05, paste("No correlation between",index_name1, "and", index_name2), "")
    
    infoBox(title = "T-test p-value", value = p_value, subtitle = subtitle,
            color = "light-blue", fill = TRUE)
  })
  
  output$corr_box_dj = renderInfoBox({
    
    index_name1 = input$index_name1
    index_name2 = input$index_name2
    coin_name1 = is.coin(input$coin_name1)
    coin_name2 = is.coin(input$coin_name2)
    coluna = switch(input$coluna_dj, "Day movement (Open x close values)" = "day_movement",
                    "Day volatility (High x low values)" = "volatility")
    
    min = min(input$date_dj)
    max = max(input$date_dj)
    
    data_coins = filter(all_values, date>= min & date<=max) %>%
      filter(., index == index_name1 | index == index_name2)%>%
      filter(., name %in% coin_name1 | name %in% coin_name2)%>%
      select("date", "index", coluna) %>%
      spread(., key = "index", value = coluna) %>%
      select(., -date) 
    
    model = lm(data_coins[,index_name2] ~ data_coins[,index_name1])
    sm_model = summary(model)
    
    p_value = sm_model$coefficients[2,4]
    
    beta0 = model[1]$coefficients[[1]]
    beta1 = model[1]$coefficients[[2]]
    
    if(p_value>0.05){
      infoBox(title = "", fill = F)
    } else{
      infoBox(title = "Equation", value = paste0(round(beta0,4), " + ", round(beta1,4), "x"),
              color = "light-blue", fill = TRUE)
    }
  })
  
  
  output$r2_dj = renderInfoBox({
    
    index_name1 = input$index_name1
    index_name2 = input$index_name2
    coin_name1 = is.coin(input$coin_name1)
    coin_name2 = is.coin(input$coin_name2)
    coluna = switch(input$coluna_dj, "Day movement (Open x close values)" = "day_movement",
                    "Day volatility (High x low values)" = "volatility")
    
    min = min(input$date_dj)
    max = max(input$date_dj)
    
    data_coins = filter(all_values, date>= min & date<=max) %>%
      filter(., index == index_name1 | index == index_name2)%>%
      filter(., name %in% coin_name1 | name %in% coin_name2)%>%
      select("date", "index", coluna) %>%
      spread(., key = "index", value = coluna) %>%
      select(., -date) 
    
    model = lm(data_coins[,index_name2] ~ data_coins[,index_name1])
    sm_model = summary(model)
    
    p_value = sm_model$coefficients[2,4]
    
    R_2 = sm_model$adj.r.squared
    
    if(p_value>0.05){
      infoBox(title = "", fill = F)
    } else{
      infoBox(title = "Coefficient of Determination R^2", value = paste0("R^2 = ", round(R_2,4)),
              color = "light-blue", fill = TRUE)
    }
    
  })
  
  
  output$error_graph_dj = renderPlot({
    
    index_name1 = input$index_name1
    index_name2 = input$index_name2
    coin_name1 = is.coin(input$coin_name1)
    coin_name2 = is.coin(input$coin_name2)
    coluna = switch(input$coluna_dj, "Day movement (Open x close values)" = "day_movement",
                    "Day volatility (High x low values)" = "volatility")
    
    min = min(input$date_dj)
    max = max(input$date_dj)
    
    data_coins = filter(all_values, date>= min & date<=max) %>%
      filter(., index == index_name1 | index == index_name2)%>%
      filter(., name %in% coin_name1 | name %in% coin_name2)%>%
      select("date", "index", coluna) %>%
      spread(., key = "index", value = coluna) %>%
      select(., -date) 
    
    model = lm(data_coins[,index_name2] ~ data_coins[,index_name1])
    plot(model$fitted, model$residuals, xlab = "Fitted values", ylab = "Residuals", main = "Residuals")
    
  })
  
  output$qq_graph_dj = renderPlot({
    
    index_name1 = input$index_name1
    index_name2 = input$index_name2
    coin_name1 = is.coin(input$coin_name1)
    coin_name2 = is.coin(input$coin_name2)
    coluna = switch(input$coluna_dj, "Day movement (Open x close values)" = "day_movement",
                    "Day volatility (High x low values)" = "volatility")
    
    min = min(input$date_dj)
    max = max(input$date_dj)
    
    data_coins = filter(all_values, date>= min & date<=max) %>%
      filter(., index == index_name1 | index == index_name2)%>%
      filter(., name %in% coin_name1 | name %in% coin_name2)%>%
      select("date", "index", coluna) %>%
      spread(., key = "index", value = coluna) %>%
      select(., -date) 
    
    model = lm(data_coins[,index_name2] ~ data_coins[,index_name1])
    
    qqnorm(model$residuals)
    qqline(model$residuals)
    
  })
  
  #########################################################################################################################
  ## Cointelegraph ########################################################################################################   
  
  output$corr_graph_ct = renderPlotly({
    
    index_name = input$index_ct
    coin_name = data_ct$coins_list
    content_ = input$content_ct
    coluna_ = input$column_ct
    
    data_ct_graph = filter(data_ct, content %in% content_, coins_list %in% coin_name, index %in% index_name)
    data_ct_graph = as.data.frame(data_ct_graph)
    
    ggplot(data_ct_graph, aes(y = data_ct_graph[,"volatility"], x = data_ct_graph[,coluna_])) + 
      geom_point(aes(color = content)) + geom_smooth(method = "lm") +
      xlab(coluna_) + ylab("Volatility") + ggtitle(paste0("Volatility as a function of ", coluna_))
  })
  
  output$pvalue_ct = renderInfoBox({
    
    index_name = input$index_ct
    coin_name = data_ct$coins_list
    content_ = input$content_ct
    coluna_ = input$column_ct
    
    data_ct_graph = filter(data_ct, content %in% content_, coins_list %in% coin_name, index %in% index_name)
    data_ct_graph = as.data.frame(data_ct_graph)
    
    model = lm(data_ct_graph[data_ct_graph$content %in% content_,"volatility"] ~ data_ct_graph[data_ct_graph$content %in% content_,coluna_])
    sm_model = summary(model)
    
    p_value = sm_model$coefficients[2,4]
    
    subtitle = ifelse(p_value>0.05, paste("No correlation between Volatility and", coluna_), "")
    
    infoBox(title = "T-test p-value", value = p_value, subtitle = subtitle,
            color = "light-blue", fill = TRUE)
  })
  
  output$corr_box_ct = renderInfoBox({
    
    index_name = input$index_ct
    coin_name = data_ct$coins_list
    content_ = input$content_ct
    coluna_ = input$column_ct
    
    data_ct_graph = filter(data_ct, content %in% content_, coins_list %in% coin_name, index %in% index_name)
    data_ct_graph = as.data.frame(data_ct_graph)
    
    model = lm(data_ct_graph[data_ct_graph$content %in% content_,"volatility"] ~ data_ct_graph[data_ct_graph$content %in% content_,coluna_])
    sm_model = summary(model)
    
    p_value = sm_model$coefficients[2,4]
    
    beta0 = model[1]$coefficients[[1]]
    beta1 = model[1]$coefficients[[2]]
    
    if(p_value>0.05){
      infoBox(title = "", fill = F)
    } else{
      infoBox(title = "Equation", value = paste0(round(beta0,6), " + ", round(beta1,6), "x"),
              color = "light-blue", fill = TRUE)
    }
  })
  
  
  output$r2_ct = renderInfoBox({
    
    index_name = input$index_ct
    coin_name = data_ct$coins_list
    content_ = input$content_ct
    coluna_ = input$column_ct
    
    data_ct_graph = filter(data_ct, content %in% content_, coins_list %in% coin_name, index %in% index_name)
    data_ct_graph = as.data.frame(data_ct_graph)
    
    model = lm(data_ct_graph[data_ct_graph$content %in% content_,"volatility"] ~ data_ct_graph[data_ct_graph$content %in% content_,coluna_])
    sm_model = summary(model)
    
    p_value = sm_model$coefficients[2,4]
    
    R_2 = sm_model$adj.r.squared
    
    if(p_value>0.05){
      infoBox(title = "", fill = F)
    } else{
      infoBox(title = "Coefficient of Determination R^2", value = paste0("R^2 = ", round(R_2,4)),
              color = "light-blue", fill = TRUE)
    }
    
  })
  
  
  output$error_graph_ct = renderPlot({
    
    index_name = input$index_ct
    coin_name = data_ct$coins_list
    content_ = input$content_ct
    coluna_ = input$column_ct
    
    data_ct_graph = filter(data_ct, content %in% content_, coins_list %in% coin_name, index %in% index_name)
    data_ct_graph = as.data.frame(data_ct_graph)
    
    model = lm(data_ct_graph[data_ct_graph$content %in% content_,"volatility"] ~ data_ct_graph[data_ct_graph$content %in% content_,coluna_])
    
    plot(model$fitted, model$residuals, xlab = "Fitted values", ylab = "Residuals", main = "Residuals")
    
  })
  
  output$qq_graph_ct = renderPlot({
    
    index_name = input$index_ct
    coin_name = data_ct$coins_list
    content_ = input$content_ct
    coluna_ = input$column_ct
    
    data_ct_graph = filter(data_ct, content %in% content_, coins_list %in% coin_name, index %in% index_name)
    data_ct_graph = as.data.frame(data_ct_graph)
    
    model = lm(data_ct_graph[data_ct_graph$content %in% content_,"volatility"] ~ data_ct_graph[data_ct_graph$content %in% content_,coluna_])
    
    qqnorm(model$residuals)
    qqline(model$residuals)
    
  })
  
  
  #########################################################################################################################
  ## Reddit ###############################################################################################################   
  
  output$corr_graph_rc = renderPlotly({
    
    index_name = input$index_rc
    coin_name = data_rc$coin
    content_ = input$content_rc
    coluna_ = input$column_rc
    
    data_rc_graph = filter(data_rc, content %in% content_, coin %in% coin_name, index %in% index_name)
    data_rc_graph = as.data.frame(data_rc_graph)
    
    ggplot(data_rc_graph, aes(y = data_rc_graph[,"volatility"], x = data_rc_graph[,coluna_])) + 
      geom_point(aes(color = content)) + geom_smooth(method = "lm") +
      xlab(coluna_) + ylab("Volatility") + ggtitle(paste0("Volatility as a function of ", coluna_))
  })
  
  output$pvalue_rc = renderInfoBox({
    
    index_name = input$index_rc
    coin_name = data_rc$coin
    content_ = input$content_rc
    coluna_ = input$column_rc
    
    data_rc_graph = filter(data_rc, content %in% content_, coin %in% coin_name, index %in% index_name)
    data_rc_graph = as.data.frame(data_rc_graph)
    
    model = lm(data_rc_graph[data_rc_graph$content %in% content_,"volatility"] ~ data_rc_graph[data_rc_graph$content %in% content_,coluna_])
    sm_model = summary(model)
    
    p_value = sm_model$coefficients[2,4]
    
    subtitle = ifelse(p_value>0.05, paste("No correlation between Volatility and", coluna_), "")
    
    infoBox(title = "T-test p-value", value = p_value, subtitle = subtitle,
            color = "light-blue", fill = TRUE)
  })
  
  output$corr_box_rc = renderInfoBox({
    
    index_name = input$index_rc
    coin_name = data_rc$coin
    content_ = input$content_rc
    coluna_ = input$column_rc
    
    data_rc_graph = filter(data_rc, content %in% content_, coin %in% coin_name, index %in% index_name)
    data_rc_graph = as.data.frame(data_rc_graph)
    
    model = lm(data_rc_graph[data_rc_graph$content %in% content_,"volatility"] ~ data_rc_graph[data_rc_graph$content %in% content_,coluna_])
    sm_model = summary(model)
    
    p_value = sm_model$coefficients[2,4]
    
    beta0 = model[1]$coefficients[[1]]
    beta1 = model[1]$coefficients[[2]]
    
    if(p_value>0.05){
      infoBox(title = "", fill = F)
    } else{
      infoBox(title = "Equation", value = paste0(round(beta0,6), " + ", round(beta1,6), "x"),
              color = "light-blue", fill = TRUE)
    }
  })
  
  
  output$r2_rc = renderInfoBox({
    
    index_name = input$index_rc
    coin_name = data_rc$coin
    content_ = input$content_rc
    coluna_ = input$column_rc
    
    data_rc_graph = filter(data_rc, content %in% content_, coin %in% coin_name, index %in% index_name)
    data_rc_graph = as.data.frame(data_rc_graph)
    
    model = lm(data_rc_graph[data_rc_graph$content %in% content_,"volatility"] ~ data_rc_graph[data_rc_graph$content %in% content_,coluna_])
    sm_model = summary(model)
    
    p_value = sm_model$coefficients[2,4]
    
    R_2 = sm_model$adj.r.squared
    
    if(p_value>0.05){
      infoBox(title = "", fill = F)
    } else{
      infoBox(title = "Coefficient of Determination R^2", value = paste0("R^2 = ", round(R_2,4)),
              color = "light-blue", fill = TRUE)
    }
    
  })
  
  
  output$error_graph_rc = renderPlot({
    
    index_name = input$index_rc
    coin_name = data_rc$coin
    content_ = input$content_rc
    coluna_ = input$column_rc
    
    data_rc_graph = filter(data_rc, content %in% content_, coin %in% coin_name, index %in% index_name)
    data_rc_graph = as.data.frame(data_rc_graph)
    
    model = lm(data_rc_graph[data_rc_graph$content %in% content_,"volatility"] ~ data_rc_graph[data_rc_graph$content %in% content_,coluna_])
    
    plot(model$fitted, model$residuals, xlab = "Fitted values", ylab = "Residuals", main = "Residuals")
    
  })
  
  output$qq_graph_rc = renderPlot({
    
    index_name = input$index_rc
    coin_name = data_rc$coin
    content_ = input$content_rc
    coluna_ = input$column_rc
    
    data_rc_graph = filter(data_rc, content %in% content_, coin %in% coin_name, index %in% index_name)
    data_rc_graph = as.data.frame(data_rc_graph)
    
    model = lm(data_rc_graph[data_rc_graph$content %in% content_,"volatility"] ~ data_rc_graph[data_rc_graph$content %in% content_,coluna_])
    
    qqnorm(model$residuals)
    qqline(model$residuals)
    
  })
 
  
})