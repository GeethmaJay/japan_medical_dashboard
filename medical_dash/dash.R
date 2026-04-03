library(shiny)
library(tidyverse)
library(plotly)
library(bslib)

# ------------------------------------------------------------
# 1. Load & Standardize
# ------------------------------------------------------------
df_tidy <- read.csv("tidy_population_data_final.csv") %>%
  filter(Year >= 2000) %>%
  rename_with(~ gsub("\\.", " ", .x))

# ------------------------------------------------------------
# 2. UI Layout
# ------------------------------------------------------------
ui <- navbarPage(
  title = span(icon("palette"), " 🏆 Japan Health & Population Analytics Dashboard"),
  theme = bs_theme(version = 5, bootswatch = "lux"),
  
  header = tags$head(
    tags$link(
      href = "https://fonts.googleapis.com/css2?family=Poppins:wght@300;600;800&display=swap",
      rel = "stylesheet"
    ),
    
    tags$style(HTML("
      body {
        background: linear-gradient(135deg, #e0f7fa, #fce4ec);
        font-family: 'Poppins', sans-serif;
      }
      .navbar {
        background: linear-gradient(90deg, #0f2027, #203a43, #2c5364) !important;
      }
      .navbar-brand, .nav-link {
        color: #ffffff !important;
        font-weight: 700 !important;
      }
      .pop-panel {
        background: linear-gradient(135deg, #ff512f, #dd2476);
        color: white;
        padding: 45px;
        border-radius: 25px;
        text-align: center;
        box-shadow: 0 20px 50px rgba(221,36,118,0.5);
      }
      .pop-value {
        font-size: 3.8rem;
        font-weight: 900;
      }
      .card {
        border-radius: 20px;
        padding: 25px;
        margin-bottom: 25px;
        background: linear-gradient(145deg, #ffffff, #f1f2f6);
        box-shadow: 0 10px 30px rgba(0,0,0,0.12);
        transition: 0.3s;
      }
      .card:hover {
        transform: scale(1.02);
      }
      .bg-demo  { border-top: 8px solid #ff9f43; background: #fff7e6; }
      .bg-health { border-top: 8px solid #ff4757; background: #ffe6e6; }
      .bg-infra  { border-top: 8px solid #2ed573; background: #e6fff5; }
      .bg-explore { border-top: 8px solid #3742fa; background: #eef0ff; }
      h2 {
        font-size: 1rem;
        font-weight: 800;
        letter-spacing: 1px;
      }
      .irs--shiny .irs-bar {
        background: #ee0979;
      }
      .irs--shiny .irs-single {
        background: #ee0979;
      }
    "))
  ),
  
  tabPanel("Demographics",
           # --- TOP ROW ---
           fluidRow(
             column(3, div(class="card",
                           h2(icon("calendar-alt"), "Timeline"),
                           sliderInput("year_pivot", "Select Year:",
                                       min = min(df_tidy$Year),
                                       max = max(df_tidy$Year),
                                       value = max(df_tidy$Year),
                                       step = 1, sep = "", animate = TRUE)
             )),
             
             column(5, div(class="pop-panel",
                           span(textOutput("selected_year_txt")),
                           span(class="pop-value", textOutput("total_pop_val")),
                           span("TOTAL POPULATION (MILLIONS)")
             )),
             
             column(4, div(class="card bg-demo",
                           h2(icon("venus-mars"), "Gender Distribution"),
                           plotlyOutput("genderPie", height = "240px")
             ))
           ),
           
           # --- MIDDLE ROW ---
           fluidRow(
             column(6, div(class="card bg-demo",
                           h2(icon("walking"), "Old-Age Dependency"),
                           plotlyOutput("agingTrendPlot", height = "300px")
             )),
             
             column(6, div(class="card bg-demo",
                           h2(icon("chart-line"), "Working Age Population"),
                           plotlyOutput("workingAgePlot", height = "300px")
             ))
           ),
           
           # --- BOTTOM ROW ---
           fluidRow(
             column(4, div(class="card bg-demo",
                           h2(icon("baby"), "Birth Rate"),
                           plotlyOutput("birthRatePlot", height = "260px")
             )),
             column(4, div(class="card bg-demo",
                           h2(icon("child"), "Sex Ratio at Birth"),
                           plotlyOutput("sexRatioPlot", height = "260px")
             )),
             column(4, div(class="card bg-demo",
                           h2(icon("chart-area"), "Quick Insight"),
                           br(),
                           h4("📌 Japan is experiencing:"),
                           tags$ul(
                             tags$li("A declining birth rate"),
                             tags$li("An aging population"),
                             tags$li("Shrinking workforce")
                           )
             ))
           )
  ),
  
  tabPanel("Health & Disease",
           fluidRow(
             column(6, div(class="card bg-health",
                           h2(icon("heartbeat"), "NCD Mortality Risk"),
                           plotlyOutput("ncdMortalityPlot")
             )),
             column(6, div(class="card bg-health",
                           h2(icon("virus"), "Incidence of HIV"),
                           plotlyOutput("hivPlot")
             ))
           ),
           
           fluidRow(
             column(4, div(class="card bg-health",
                           h2(icon("syringe"), "Diabetes Prevalence"),
                           plotlyOutput("diabetesPlot")
             )),
             column(4, div(class="card bg-health",
                           h2(icon("smoking"), "Tobacco Use (Total)"),
                           plotlyOutput("tobaccoPlot")
             )),
             column(4, div(class="card bg-health",
                           h2(icon("users"), "Adolescent Fertility"),
                           plotlyOutput("fertilityPlot")
             ))
           )
  ),
  
  tabPanel("Healthcare Capacity",
           fluidRow(
             column(6, div(class="card bg-infra",
                           h2(icon("hospital"), "Hospital Bed Density"),
                           plotlyOutput("healthCapPlot")
             )),
             column(6, div(class="card bg-infra",
                           h2(icon("shield-virus"), "Immunization (DPT)"),
                           plotlyOutput("vaccinePlot")
             ))
           ),
           
           fluidRow(
             column(12, div(class="card bg-infra",
                            h2(icon("pills"), "Infant Mortality Rate"),
                            plotlyOutput("mortalityPlot")
             ))
           )
  ),
  
  tabPanel("Data Explorer",
           sidebarLayout(
             sidebarPanel(
               div(class="card bg-explore",
                   h2(icon("search"), "Custom Selection"),
                   selectInput("group_select", "Select Category:", choices = unique(df_tidy$Group)),
                   uiOutput("indicator_ui")
               )
             ),
             mainPanel(
               div(class="card",
                   h2(icon("chart-line"), "Historical Trend Viewer"),
                   plotlyOutput("explorerPlot", height = "500px")
               )
             )
           )
  )
)

# ------------------------------------------------------------
# 3. SERVER
# ------------------------------------------------------------
server <- function(input, output) {
  
  theme_ly <- function(p, bg_color) {
    p %>% layout(
      plot_bgcolor = bg_color,
      paper_bgcolor = bg_color,
      margin = list(l=40, r=20, t=20, b=40),
      xaxis = list(gridcolor = 'rgba(255,255,255,0.5)'),
      yaxis = list(gridcolor = 'rgba(255,255,255,0.5)')
    )
  }
  
  output$selected_year_txt <- renderText({
    paste("JAPAN IN", input$year_pivot)
  })
  
  output$total_pop_val <- renderText({
    val <- df_tidy %>%
      filter(`Indicator Name` == "Population, total",
             Year == input$year_pivot) %>%
      pull(Value)
    
    if(length(val) > 0) {
      paste0(format(round(val / 1000000, 2), nsmall = 2), " M")
    } else {
      "Data N/A"
    }
  })
  
  # -------- DEMOGRAPHICS --------
  
  output$genderPie <- renderPlotly({
    gender_data <- df_tidy %>%
      filter(Year == input$year_pivot,
             `Indicator Name` %in% c("Population, male", "Population, female"))
    
    plot_ly(gender_data,
            labels = ~`Indicator Name`,
            values = ~Value,
            type = 'pie',
            hole = 0.7,
            marker = list(colors = c('#00d2ff', '#ff4757'))) %>%
      layout(showlegend = FALSE) %>%
      theme_ly("#fff9f0")
  })
  
  output$workingAgePlot <- renderPlotly({
    work_data <- df_tidy %>%
      filter(grepl("15-64", `Indicator Name`) &
               grepl("total population", tolower(`Indicator Name`)))
    
    plot_ly(work_data,
            x = ~Year, y = ~Value,
            type = 'scatter', mode = 'lines+markers',
            line = list(color = '#ffa502', width = 5, shape = 'spline'),
            marker = list(color = '#ffa502', size = 8)) %>%
      theme_ly("#fff9f0")
  })
  
  output$birthRatePlot <- renderPlotly({
    birth_data <- df_tidy %>%
      filter(grepl("Birth rate, crude", `Indicator Name`))
    
    plot_ly(birth_data,
            x = ~Year, y = ~Value,
            type = 'scatter', mode = 'lines',
            fill = 'tozeroy',
            fillcolor = 'rgba(255, 127, 80, 0.3)',
            line = list(color = '#ff7f50', width = 4)) %>%
      theme_ly("#fff9f0")
  })
  
  output$sexRatioPlot <- renderPlotly({
    sex_ratio_data <- df_tidy %>%
      filter(grepl("Sex ratio at birth", `Indicator Name`))
    
    plot_ly(sex_ratio_data,
            x = ~Year, y = ~Value,
            type = 'scatter', mode = 'lines+markers',
            line = list(color = '#2bcbba', width = 4),
            marker = list(color = '#0fb9b1', size = 8)) %>%
      theme_ly("#fff9f0")
  })
  
  output$agingTrendPlot <- renderPlotly({
    df_tidy %>%
      filter(grepl("old", tolower(`Indicator Name`)) &
               grepl("dependency", tolower(`Indicator Name`))) %>%
      plot_ly(x = ~Year, y = ~Value,
              type = 'scatter', mode = 'lines+markers',
              line = list(color = '#5352ed', width = 4),
              marker = list(color = '#5352ed', size = 8)) %>%
      theme_ly("#fff9f0")
  })
  
  # -------- HEALTH --------
  
  output$hivPlot <- renderPlotly({
    hiv_data <- df_tidy %>%
      filter(grepl("Incidence of HIV", `Indicator Name`))
    
    plot_ly(hiv_data,
            x = ~Year, y = ~Value,
            type = 'bar',
            marker = list(color = '#ff4757')) %>%
      theme_ly("#fff5f5")
  })
  
  output$ncdMortalityPlot <- renderPlotly({
    ncd_total <- df_tidy %>%
      filter(`Indicator Name` == "Mortality from CVD, cancer, diabetes or CRD between exact ages 30 and 70 (%)")
    
    plot_ly(ncd_total,
            x = ~Year, y = ~Value,
            type = 'bar',
            marker = list(color = '#70a1ff')) %>%
      theme_ly("#fff5f5")
  })
  
  output$tobaccoPlot <- renderPlotly({
    tob_total <- df_tidy %>%
      filter(`Indicator Name` == "Prevalence of current tobacco use (% of adults)")
    
    plot_ly(tob_total,
            x = ~Year, y = ~Value,
            type = 'scatter', mode = 'lines+markers',
            line = list(color = '#2ed573', width = 4),
            marker = list(color = '#2ed573', size = 10)) %>%
      theme_ly("#fff5f5")
  })
  
  output$fertilityPlot <- renderPlotly({
    fert_data <- df_tidy %>%
      filter(grepl("Adolescent fertility rate", `Indicator Name`))
    
    plot_ly(fert_data,
            x = ~Year, y = ~Value,
            type = 'scatter', mode = 'lines+markers',
            fill = 'tozeroy',
            fillcolor = 'rgba(190, 46, 221, 0.2)',
            line = list(color = '#be2ed1', width = 3)) %>%
      theme_ly("#fff5f5")
  })
  
  output$diabetesPlot <- renderPlotly({
    df_tidy %>%
      filter(grepl("Diabetes", `Indicator Name`)) %>%
      plot_ly(x = ~Year, y = ~Value,
              type = 'bar',
              marker = list(color = '#ffa502')) %>%
      theme_ly("#fff5f5")
  })
  
  # -------- CAPACITY --------
  
  output$healthCapPlot <- renderPlotly({
    df_tidy %>%
      filter(grepl("Hospital beds", `Indicator Name`)) %>%
      plot_ly(x = ~Year, y = ~Value,
              type = 'bar',
              marker = list(color = '#2ed573')) %>%
      theme_ly("#f0fff4")
  })
  
  output$vaccinePlot <- renderPlotly({
    dpt_data <- df_tidy %>%
      filter(grepl("Immunization, DPT", `Indicator Name`))
    
    plot_ly(dpt_data,
            x = ~Year, y = ~Value,
            type = 'scatter', mode = 'lines+markers',
            line = list(color = '#1e90ff', width = 3),
            marker = list(color = '#1e90ff', size = 8)) %>%
      theme_ly("#f0fff4")
  })
  
  output$mortalityPlot <- renderPlotly({
    df_tidy %>%
      filter(`Indicator Name` == "Mortality rate, infant (per 1,000 live births)") %>%
      plot_ly(x = ~Year, y = ~Value,
              type = 'scatter', mode = 'lines+markers',
              line = list(color = '#ff6b81', width = 4)) %>%
      theme_ly("#f0fff4")
  })
  
  # -------- EXPLORER --------
  
  output$indicator_ui <- renderUI({
    available <- df_tidy %>%
      filter(Group == input$group_select) %>%
      pull(`Indicator Name`) %>%
      unique()
    
    selectInput("ind_select", "Select Indicator:", choices = available)
  })
  
  output$explorerPlot <- renderPlotly({
    req(input$ind_select)
    
    df_tidy %>%
      filter(`Indicator Name` == input$ind_select) %>%
      plot_ly(x = ~Year, y = ~Value,
              type = 'scatter', mode = 'lines+markers',
              line = list(color = '#3742fa', width = 3),
              marker = list(color = '#3742fa', size = 8)) %>%
      theme_ly("#f8f9ff")
  })
}

shinyApp(ui, server)
