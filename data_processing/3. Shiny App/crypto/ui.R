
shinyUI(
  
  dashboardPage(skin = "black",
                
                dashboardHeader(title = "Cryptocurrency volatility"),
                
                dashboardSidebar(
                  sidebarMenu(
                    menuItem("Crypto & Dow Jones", tabName = "dowjones", icon = icon("file-invoice-dolar")),
                    menuItem("Crypto & Cointelegraph", tabName = "cointelegraph", icon = icon("money-check-alt")),
                    menuItem("Crypto & Reddit", tabName = "reddit", icon = icon("money-check-alt"))
                    )),
                
                dashboardBody(
                  tabItems(
                    
                    tabItem(tabName = "dowjones",
                            fluidRow(shiny::column(11, offset = 0.5, h3("Cryptocurrencies and Dow Jones market movements"))),
                            
                            fluidRow(p("-")),
                            
                            fluidRow(shiny::column(4, offset = 0.5,
                                                   checkboxGroupInput("coluna_dj", "Select the type of values", 
                                                                      columns_list, selected = "Day movement (Open x close values)")),
                                     shiny::column(2, offset = 3, selectizeInput("index_name1", "Select first index (x)", index_list, "Dow Jones")),
                                     shiny::column(2, offset = 0.5, selectizeInput("index_name2", "Select second index (y)", index_list, "Bitcoin"))), 
                            fluidRow(shiny::column(4, offset = 0.5, dateRangeInput(inputId = "date_dj", label = "Select dates",
                                                                                   start = as.Date("2018-1-1"), end = as.Date("2018-7-31"),
                                                                                 min = min_date, max = max_date, format = "mm-dd-yyyy")),
                                     shiny::column(2, offset = 3, selectizeInput("coin_name1", "Select first coin (x)", coins_list, "")),
                                     shiny::column(2, offset = 0.5, selectizeInput("coin_name2", "Select second coint (y)", coins_list, ""))),

                            fluidRow(shiny::column(11, offset = 0.5, plotlyOutput("comp_graph_dj"))),
                            
                            fluidRow(p("-")),
                            
                            fluidRow(shiny::column(7, offset = 0.5, plotlyOutput("corr_graph_dj")),
                                     shiny::column(3.5, offset = 0.5, infoBoxOutput("pvalue_dj")),
                                     shiny::column(3.5, offset = 8.5, infoBoxOutput("corr_box_dj")),
                                     shiny::column(3.5, offset = 8.5, infoBoxOutput("r2_dj"))),
                            
                            fluidRow(p("-")),
                            
                            fluidRow(shiny::column(5, offset = 1, plotOutput("error_graph_dj")),
                                     shiny::column(5, offset = 0, plotOutput("qq_graph_dj")))
                            ),
                    
                    tabItem(tabName = "cointelegraph",
                            fluidRow(shiny::column(11, offset = 0.5, h3("Cryptocurrencies market movements x Cointelegraph news"))),
                            
                            fluidRow(p("-")),
                            
                            fluidRow(shiny::column(4, offset = 0.5, checkboxGroupInput("index_ct", "Crypto of interest", 
                                                                      index_list_ct, selected = "Bitcoin")),
                                     shiny::column(4, offset = 0.5, checkboxGroupInput("content_ct", "Type of news", 
                                                                                       content_list_ct, selected = "Positive")),
                                     shiny::column(2, offset = 0.5, selectizeInput("column_ct", "Correlation with:", column_list_ct, "news_n"))),
                            
                            fluidRow(shiny::column(11, offset = 0.5, plotlyOutput("corr_graph_ct"))),
                            
                            fluidRow(p("-")),
                            
                            fluidRow(infoBoxOutput("pvalue_ct"),
                                     infoBoxOutput("corr_box_ct"),
                                     infoBoxOutput("r2_ct")),
                            
                            fluidRow(p("-")),
                            
                            fluidRow(shiny::column(5, offset = 0.5, plotOutput("error_graph_ct")),
                                     shiny::column(5, offset = 1.5, plotOutput("qq_graph_ct")))
                    ),
                    
                    tabItem(tabName = "reddit",
                            fluidRow(shiny::column(11, offset = 0.5, h3("Cryptocurrencies market movements x Reddit posts"))),
                            
                            fluidRow(p("-")),
                            
                            fluidRow(shiny::column(4, offset = 0.5, checkboxGroupInput("index_rc", "Crypto of interest", 
                                                                                       index_list_ct, selected = "Bitcoin")),
                                     shiny::column(4, offset = 0.5, checkboxGroupInput("content_rc", "Type of posts", 
                                                                                       content_list_ct, selected = "Positive")),
                                     shiny::column(2, offset = 0.5, selectizeInput("column_rc", "Correlation with:", column_list_rc, "news_n"))),
                            
                            fluidRow(shiny::column(11, offset = 0.5, plotlyOutput("corr_graph_rc"))),
                            
                            fluidRow(p("-")),
                            
                            fluidRow(infoBoxOutput("pvalue_rc"),
                                     infoBoxOutput("corr_box_rc"),
                                     infoBoxOutput("r2_rc")),
                            
                            fluidRow(p("-")),
                            
                            fluidRow(shiny::column(5, offset = 0.5, plotOutput("error_graph_rc")),
                                     shiny::column(5, offset = 1.5, plotOutput("qq_graph_rc")))
                    )
                    
                    )
                  )
                )
  )
